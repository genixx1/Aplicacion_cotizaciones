import 'package:flutter/material.dart';

class TemaApp {
  // Paleta de colores Novotrace
  static const Color azulOscuro = Color(0xFF003d82);
  static const Color azulElectrico = Color(0xFF00a8e8);
  static const Color azulClaro = Color(0xFF4FC3F7);
  static const Color grisClaro = Color(0xFFF5F7FA);
  static const Color grisOscuro = Color(0xFF37474F);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color verdeExito = Color(0xFF00C853);
  static const Color rojoAlerta = Color(0xFFD32F2F);
  static const Color naranjaAccento = Color(0xFFFF6F00);

  static ThemeData get tema {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: azulOscuro,
        primary: azulOscuro,
        secondary: azulElectrico,
        surface: blanco,
      ),
      scaffoldBackgroundColor: grisClaro,

      appBarTheme: const AppBarTheme(
        backgroundColor: azulOscuro,
        foregroundColor: blanco,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: blanco,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      cardTheme: CardThemeData(
        color: blanco,
        elevation: 2,
        shadowColor: const Color(0x1F000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: azulElectrico,
          foregroundColor: blanco,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: azulOscuro,
          side: const BorderSide(color: azulOscuro, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: blanco,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: azulElectrico, width: 2),
        ),
        labelStyle: const TextStyle(
          color: grisOscuro,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: azulElectrico,
        foregroundColor: blanco,
        elevation: 4,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: azulOscuro,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: azulOscuro,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: azulOscuro,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: grisOscuro,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: grisOscuro),
        bodyMedium: TextStyle(fontSize: 14, color: grisOscuro),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: blanco,
        ),
      ),
    );
  }
}
