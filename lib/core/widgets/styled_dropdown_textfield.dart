import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/utils/debouncer.dart';
import 'package:kasi_hustle/core/widgets/base_list_item_widget.dart';
import 'package:kasi_hustle/core/widgets/custom_scroll_behavior.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';
import 'package:kasi_hustle/core/widgets/styled_text_input.dart';

class StyledDropDownTextfield<T> extends StatefulWidget {
  final List<AppListItem<T>>? initialList;
  final BorderRadiusGeometry? overlayBorderRadius;
  final String? hintText;
  final Widget? suffixIconOverride;
  final Widget? prefixIcon;
  final Widget? noItemFoundWidget;
  final String? label;
  final Future<List<AppListItem<T>>> Function(String query)? futureSearch;
  final T? value;
  final ValueChanged<T?>? onSelectionChanged;
  final int minStringLengthForFutureSearch;
  final int maxItemsInView;
  final ValueChanged<String>? onInputChanged;
  final String? errorText;
  final bool isRequired;

  const StyledDropDownTextfield({
    super.key,
    this.initialList,
    this.label,
    this.futureSearch,
    this.onSelectionChanged,
    this.noItemFoundWidget,
    this.overlayBorderRadius = Corners.smBorder,
    this.suffixIconOverride,
    this.prefixIcon,
    this.maxItemsInView = 4,
    this.minStringLengthForFutureSearch = 0,
    this.hintText,
    this.value,
    this.onInputChanged,
    this.errorText,
    this.isRequired = false,
  }) : assert(
         initialList != null || futureSearch != null,
         'Either initialList or futureSearch must be provided.',
       );

  @override
  State<StyledDropDownTextfield<T>> createState() =>
      _StyledDropDownTextfieldState<T>();
}

class _StyledDropDownTextfieldState<T> extends State<StyledDropDownTextfield<T>>
    with WidgetsBindingObserver {
  late TextEditingController _controller;
  late GlobalKey _textFieldKey;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  List<AppListItem<T>> _filteredList = [];
  bool _isLoading = false;
  final Debouncer _debouncer = Debouncer(const Duration(milliseconds: 300));
  late ScrollController _scrollController;
  // This flag helps prevent _onTextChanged from re-filtering or deselecting
  // when the text is being programmatically set by an item tap or value update.
  bool _isProgrammaticallySettingText = false;

  AppListItem<T>? get _currentlySelectedItem {
    if (widget.value == null) return null;
    final itemsToSearch = <AppListItem<T>>[];
    if (widget.initialList != null) itemsToSearch.addAll(widget.initialList!);
    if (_filteredList.isNotEmpty && _filteredList != widget.initialList) {
      itemsToSearch.addAll(_filteredList);
    }

    for (var item in itemsToSearch.toSet()) {
      // toSet to handle potential duplicates if filteredList can contain initialList items
      if (item.value == widget.value) return item;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _textFieldKey = GlobalKey(
      debugLabel: 'StyledDropDownTFKey_${identityHashCode(this)}',
    );
    WidgetsBinding.instance.addObserver(this);
    _controller = TextEditingController();
    _scrollController = ScrollController();
    _updateControllerTextFromWidgetValue(isInit: true);
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_onTextChanged);

    if (widget.initialList != null &&
        (widget.futureSearch == null ||
            widget.minStringLengthForFutureSearch == 0)) {
      _filteredList = List.from(widget.initialList!);
    }
  }

  @override
  void didUpdateWidget(StyledDropDownTextfield<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool valueChanged = widget.value != oldWidget.value;
    bool listChanged = widget.initialList != oldWidget.initialList;

    if (valueChanged || listChanged) {
      _updateControllerTextFromWidgetValue();
    }
    if (listChanged && _focusNode.hasFocus) {
      _performSearchOrFilter(_controller.text, forceFilterInitial: true);
    } else if (listChanged &&
        widget.initialList != null &&
        !_focusNode.hasFocus) {
      _filteredList =
          widget.initialList
              ?.where(
                (item) => item.title.toLowerCase().contains(
                  _controller.text.toLowerCase(),
                ),
              )
              .toList() ??
          [];
    }
  }

  void _updateControllerTextFromWidgetValue({bool isInit = false}) {
    final selectedItem = _currentlySelectedItem;
    final String newText =
        selectedItem?.title ??
        (isInit &&
                widget.initialList?.any((i) => i.value == widget.value) ==
                    false &&
                _controller.text.isNotEmpty
            ? _controller.text
            : '');

    if (_controller.text != newText) {
      _isProgrammaticallySettingText = true;
      _controller.text = newText;
      if (mounted) {
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
      _isProgrammaticallySettingText = false;
    }
  }

  void _handleFocusChange() {
    log('[_handleFocusChange] hasFocus: ${_focusNode.hasFocus}');
    if (!mounted) return;
    if (_focusNode.hasFocus) {
      _showOverlay();
      _performSearchOrFilter(_controller.text, forceFilterInitial: true);
    } else {
      final String textBeforeDelay =
          _controller.text; // Capture text before delay
      Future.delayed(const Duration(milliseconds: 250), () {
        // Your working delay
        if (mounted && !_focusNode.hasFocus) {
          log(
            '[_handleFocusChange] Removing overlay after delay. Text before delay: "$textBeforeDelay", current text: "${_controller.text}"',
          );
          // Only remove overlay and potentially clear text if the text hasn't changed
          // (implying no successful item tap selection occurred during the delay)
          if (_overlayEntry != null && _controller.text == textBeforeDelay) {
            final selectedItemAfterDelay =
                _currentlySelectedItem; // Re-check selected item
            if (selectedItemAfterDelay == null &&
                _controller.text.isNotEmpty &&
                widget.value == null) {
              log(
                '[_handleFocusChange] Clearing text field as no selection was made.',
              );
              _isProgrammaticallySettingText = true;
              _controller.clear();
              _isProgrammaticallySettingText = false;
              widget.onInputChanged?.call('');
            } else if (selectedItemAfterDelay != null &&
                _controller.text != selectedItemAfterDelay.title) {
              // This case might be redundant if _updateControllerTextFromWidgetValue handles widget.value changes
              log(
                '[_handleFocusChange] Reverting text to selected item title after focus loss.',
              );
              _isProgrammaticallySettingText = true;
              _controller.text = selectedItemAfterDelay.title;
              if (mounted) {
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              }
              _isProgrammaticallySettingText = false;
            }
            _removeOverlay();
          } else if (_overlayEntry != null &&
              _controller.text != textBeforeDelay) {
            log(
              '[_handleFocusChange] Text changed during delay (likely item selected), not clearing. Removing overlay.',
            );
            _removeOverlay(); // Still remove overlay if focus is lost
          } else if (_overlayEntry != null) {
            _removeOverlay(); // Default remove if conditions not met but overlay exists
          }
        }
      });
    }
  }

  void _onTextChanged() {
    if (_isProgrammaticallySettingText) {
      log('[_onTextChanged] Suppressed: Programmatic text change.');
      return;
    }
    log('[_onTextChanged] User typed: "${_controller.text}"');
    if (!mounted) return;

    widget.onInputChanged?.call(_controller.text);

    if (_focusNode.hasFocus) {
      _debouncer.run(() {
        if (mounted) _performSearchOrFilter(_controller.text);
      });
    }

    // If user types and text no longer matches the selected value's title, clear the selection
    if (widget.value != null) {
      final selected = _currentlySelectedItem;
      if (selected == null ||
          _controller.text.toLowerCase() != selected.title.toLowerCase()) {
        log(
          '[_onTextChanged] Text differs from selected value, calling onSelectionChanged(null)',
        );
        widget.onSelectionChanged?.call(null);
      }
    }
  }

  Future<void> _performSearchOrFilter(
    String query, {
    bool forceFilterInitial = false,
  }) async {
    /* ... (same as your version) ... */
    log(
      '[_performSearchOrFilter] query: "$query", forceFilterInitial: $forceFilterInitial',
    );
    if (!_focusNode.hasFocus && query.isNotEmpty && !forceFilterInitial) {
      _updateOverlayList([]);
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    if (_overlayEntry != null && mounted) {
      try {
        _overlayEntry!.markNeedsBuild();
      } catch (e) {
        log('[Err] markNeedsBuild: $e');
      }
    }
    List<AppListItem<T>> resultList = [];
    try {
      if (widget.futureSearch != null &&
          query.length >= widget.minStringLengthForFutureSearch) {
        resultList = await widget.futureSearch!(query);
      } else if (widget.initialList != null) {
        if (query.isEmpty &&
            (forceFilterInitial ||
                widget.minStringLengthForFutureSearch == 0)) {
          resultList = List.from(widget.initialList!);
        } else if (query.isNotEmpty) {
          resultList = widget.initialList!
              .where(
                (item) =>
                    item.title.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
        }
      }
    } catch (e, s) {
      _handleError(e, s);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _updateOverlayList([]);
      return;
    }
    if (mounted) {
      _isLoading = false;
      _updateOverlayList(resultList);
    }
  }

  void _updateOverlayList(List<AppListItem<T>> list) {
    /* ... (same as your version) ... */
    log('[_updateOverlayList] new list length: ${list.length}');
    if (!mounted) return;
    setState(() {
      _filteredList = list;
    });
    if (_overlayEntry != null && mounted) {
      try {
        _overlayEntry!.markNeedsBuild();
      } catch (e) {
        log('[Err] markNeedsBuild in update: $e');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _scrollController.dispose();
    _controller.dispose();
    _debouncer.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay() {
    /* ... (same as your version, with check for stale overlay) ... */
    log('[_showOverlay]');
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    if (mounted && _textFieldKey.currentContext != null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else if (mounted) {
      log('[_showOverlay] TFKey context null, delaying');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _textFieldKey.currentContext != null) {
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context).insert(_overlayEntry!);
        } else {
          log('[_showOverlay] TFKey context still null after frame');
        }
      });
    }
  }

  void _removeOverlay() {
    /* ... (same as your version) ... */
    log(
      '[_removeOverlay] overlay is ${_overlayEntry != null ? "present" : "null"}',
    );
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        log('[Err] Removing overlay: $e');
      }
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    /* ... (same as your version, ParentData fix was good) ... */
    log('[_createOverlayEntry]');
    if (_textFieldKey.currentContext == null) {
      log('[_createOverlayEntry] TFKey context null');
      return OverlayEntry(builder: (context) => const SizedBox.shrink());
    }
    final RenderBox textFieldRenderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Size textFieldSize = textFieldRenderBox.size;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return OverlayEntry(
      opaque: false,
      builder: (context) => Positioned(
        width: textFieldSize.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, textFieldSize.height + 2.0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _focusNode.unfocus();
            },
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: widget.overlayBorderRadius ?? Corners.smBorder,
                boxShadow: Shadows.medium,
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                  width: Strokes.thin,
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                shape: RoundedRectangleBorder(
                  borderRadius: widget.overlayBorderRadius ?? Corners.smBorder,
                ),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: _calculateOverlayHeight(),
                  ),
                  child: _isLoading
                      ? _buildLoadingIndicator()
                      : (_filteredList.isEmpty && _controller.text.isNotEmpty)
                      ? (widget.noItemFoundWidget ??
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(Insets.med),
                                child: Text(
                                  "No results found",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ))
                      : _buildListView(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateOverlayHeight() {
    /* ... (same as your version) ... */
    final double itemHeight = Sizes.listItem;
    if (_isLoading) return itemHeight * 1.5;
    if (_filteredList.isEmpty && _controller.text.isNotEmpty) {
      return itemHeight * 1.5;
    }
    if (_filteredList.isEmpty &&
        _controller.text.isEmpty &&
        widget.minStringLengthForFutureSearch > 0 &&
        widget.futureSearch != null) {
      return 0.0;
    }
    final itemCount = _filteredList.length;
    if (itemCount == 0) return 0.0;
    final displayCount = itemCount > widget.maxItemsInView
        ? widget.maxItemsInView
        : itemCount;
    return (displayCount * itemHeight) + (displayCount > 0 ? Insets.xs : 0.0);
  }

  Widget _buildLoadingIndicator() {
    /* ... (same as your version) ... */
    return SizedBox(
      height: Sizes.listItem * 1.5,
      child: Center(
        child: StyledLoadSpinner.small(
          valueColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ScrollConfiguration(
      behavior: const CustomScrollBehavior(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: _filteredList.length,
        itemExtent: 36, // Changed from Sizes.listItem to a fixed height
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final item = _filteredList[index];
          bool isSelected = widget.value == item.value;
          return BaseListItemWidget(
            isSelected: isSelected,
            showDivider: index > 0, // Show divider for all but the first item
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            onPress: () {
              _handleItemSelection(item);
            }, // Changed from _onListItemTap
          );
        },
      ),
    );
  }

  // This is YOUR working version of item tap logic
  void _handleItemSelection(AppListItem<T> item) {
    log(
      '[StyledDropDownTextfield] _handleItemSelection for: ${item.title}, (YOUR WORKING LOGIC)',
    );
    if (!mounted) return;

    _isProgrammaticallySettingText =
        true; // Prevent _onTextChanged from interfering
    _controller.text = item.title;
    // if (_controller.hasClients) {
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    // }
    _isProgrammaticallySettingText = false;

    // Only call if value actually changes to prevent redundant BLoC events if tapping same item
    if (widget.value != item.value) {
      widget.onSelectionChanged?.call(item.value);
    }

    // This was your key working part: microtask for unfocus AND immediate overlay removal
    Future.microtask(() {
      if (mounted) {
        _focusNode
            .unfocus(); // This will trigger _handleFocusChange which has its own delayed remove
        _removeOverlay(); // But you also had an immediate remove here which seemed to be key for you
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CompositedTransformTarget(
      link: _layerLink,
      child: StyledTextInput(
        key: _textFieldKey,
        controller: _controller,
        focusNode: _focusNode,
        label: widget.label,
        hintText: widget.hintText ?? "Type to search...",
        prefixIcon: widget.prefixIcon,
        errorText: widget.errorText,
        isRequired: widget.isRequired,
        suffixWidget:
            widget.suffixIconOverride ??
            Icon(
              Ionicons.chevron_down_outline,
              color: _focusNode.hasFocus
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: IconSizes.xs - 2,
            ),
        onSubmitted: (value) {
          log(
            "[onSubmitted] value='$value', filteredListCount=${_filteredList.length}",
          );
          if (_filteredList.isNotEmpty) {
            AppListItem<T> itemToSelect = _filteredList.first;
            if (_controller.text.isNotEmpty) {
              final exactMatch = _filteredList.firstWhere(
                (item) =>
                    item.title.toLowerCase() == _controller.text.toLowerCase(),
                orElse: () => _filteredList.first,
              );
              if (exactMatch.title.toLowerCase() ==
                  _controller.text.toLowerCase()) {
                itemToSelect = exactMatch;
              }
            }
            _handleItemSelection(
              itemToSelect,
            ); // Uses your working selection logic
          } else if (_controller.text.isEmpty &&
              widget.initialList != null &&
              widget.initialList!.isNotEmpty) {
            if (!_focusNode.hasFocus) {
              _focusNode.requestFocus();
            } else {
              _performSearchOrFilter('', forceFilterInitial: true);
            }
          } else {
            _focusNode.unfocus();
          }
        },
      ),
    );
  }

  // Update error handling to use logger
  void _handleError(dynamic error, StackTrace? stackTrace) {
    log('Error in StyledDropDownTextfield: $error');
    if (stackTrace != null) {
      log('Stack trace: $stackTrace');
    }
  }
}

class AppListItem<T> extends Equatable {
  final String title;
  final T value;
  const AppListItem(this.title, {required this.value});
  @override
  List<Object?> get props => [title, value];
}
