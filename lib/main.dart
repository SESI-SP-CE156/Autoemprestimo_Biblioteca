import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Portuguese date formatting
  await initializeDateFormatting('pt_BR', null);

  // Desktop window manager setup
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      await windowManager.ensureInitialized();
      const windowOptions = WindowOptions(
        size: Size(1280, 800),
        minimumSize: Size(800, 600),
        center: true,
        title: 'Biblioteca SESI-SP - Totem de Autoatendimento',
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (_) {
      // Graceful fallback if running in tests or headless environments
    }
  }

  runApp(
    const ProviderScope(
      child: BibliotecaApp(),
    ),
  );
}
