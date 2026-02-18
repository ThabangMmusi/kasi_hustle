import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/services/theme_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService _themeService;

  ThemeBloc({required ThemeService themeService})
    : _themeService = themeService,
      super(const ThemeState(ThemeMode.system)) {
    on<LoadTheme>(_onLoadTheme);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final mode = await _themeService.getThemeMode();
    emit(ThemeState(mode));
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await _themeService.setThemeMode(event.themeMode);
    emit(ThemeState(event.themeMode));
  }
}
