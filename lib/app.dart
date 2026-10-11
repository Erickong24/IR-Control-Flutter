import 'package:flutter/material.dart';

import 'screens/remote_screen.dart';
import 'theme/app_colors.dart';

class IrControlApp extends StatelessWidget {
  const IrControlApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'IR Control',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mint,
        brightness: Brightness.dark,
        surface: AppColors.panel,
      ),
      useMaterial3: true,
    ),
    home: const RemoteScreen(),
  );
}
