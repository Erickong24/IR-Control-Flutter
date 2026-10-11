import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RemoteIconButton extends StatelessWidget {
  const RemoteIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.accent = false,
    this.circular = false,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool accent;
  final bool circular;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: circular ? 62 : 42,
    height: circular ? 62 : 42,
    child: IconButton(
      tooltip: label,
      onPressed: enabled ? onPressed : null,
      style: IconButton.styleFrom(
        backgroundColor: accent ? AppColors.mint : AppColors.panel,
        foregroundColor: accent ? AppColors.ink : Colors.white,
        disabledBackgroundColor: const Color(0xFF202928),
        disabledForegroundColor: const Color(0xFF65716F),
        shape: const CircleBorder(),
      ),
      icon: Icon(icon, size: circular ? 29 : 20),
    ),
  );
}

class PowerButton extends StatelessWidget {
  const PowerButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 48,
    height: 48,
    child: IconButton.filled(
      tooltip: 'Encendido / espera',
      onPressed: enabled ? onPressed : null,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF432C31),
        foregroundColor: const Color(0xFFFF8A8A),
        disabledBackgroundColor: AppColors.panel,
        disabledForegroundColor: AppColors.muted,
        shape: const CircleBorder(),
      ),
      icon: const Icon(Icons.power_settings_new_rounded, size: 23),
    ),
  );
}

class ShortcutButton extends StatelessWidget {
  const ShortcutButton({
    super.key,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: enabled ? onPressed : null,
    style: FilledButton.styleFrom(
      backgroundColor: color.withValues(alpha: .16),
      foregroundColor: color,
      disabledBackgroundColor: AppColors.panel,
      disabledForegroundColor: AppColors.muted,
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: .24)),
      ),
      textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
    ),
    child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
  );
}

class DigitButton extends StatelessWidget {
  const DigitButton({
    super.key,
    required this.digit,
    required this.enabled,
    required this.onPressed,
  });

  final String digit;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: enabled ? onPressed : null,
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.panel,
      foregroundColor: Colors.white,
      disabledBackgroundColor: const Color(0xFF202928),
      disabledForegroundColor: AppColors.muted,
      minimumSize: const Size(0, 40),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: BorderSide(color: Colors.white.withValues(alpha: .06)),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
    child: Text(digit),
  );
}
