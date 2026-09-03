import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/entities.dart';

class AppPreferencesState {
  const AppPreferencesState({
    this.language = AppLanguage.english,
    this.themeMode = ThemeMode.system,
  });

  final AppLanguage language;
  final ThemeMode themeMode;

  AppPreferencesState copyWith({
    AppLanguage? language,
    ThemeMode? themeMode,
  }) =>
      AppPreferencesState(
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
      );
}

class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit() : super(const AppPreferencesState());

  void setLanguage(AppLanguage language) {
    emit(state.copyWith(language: language));
  }

  void setThemeMode(ThemeMode themeMode) {
    emit(state.copyWith(themeMode: themeMode));
  }
}
