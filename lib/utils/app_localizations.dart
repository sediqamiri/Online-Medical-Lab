import 'package:flutter/material.dart';

class AppLocalizations {
  static const List<Locale> supportedLocales = [Locale('en'), Locale('fa')];

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      DefaultMaterialLocalizations.delegate;

  static List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static LocaleResolutionCallback localeResolutionCallback =
      (Locale? locale, Iterable<Locale> supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      };
}
