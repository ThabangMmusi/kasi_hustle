import 'package:flutter/material.dart';

class SearchFocusController {
  static final SearchFocusController _instance =
      SearchFocusController._internal();
  factory SearchFocusController() => _instance;
  SearchFocusController._internal();

  final ValueNotifier<int> _focusRequests = ValueNotifier<int>(0);
  ValueNotifier<int> get focusRequests => _focusRequests;

  void requestFocus() {
    _focusRequests.value++;
  }
}
