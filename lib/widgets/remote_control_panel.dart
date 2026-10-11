import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'remote_buttons.dart';

class RemoteControlPanel extends StatelessWidget {
  const RemoteControlPanel({
    super.key,
    required this.enabled,
    required this.onCommand,
  });

  final bool enabled;
  final ValueChanged<String> onCommand;

  Widget _key(String label, IconData icon, {bool accent = false}) =>
      RemoteIconButton(
        label: label,
        icon: icon,
        accent: accent,
        enabled: enabled,
        onPressed: () => onCommand(label),
      );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 17, 16, 18),
    decoration: BoxDecoration(
      color: const Color(0xFF151C1D),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: Colors.white.withValues(alpha: .07)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            _key('Fuente', Icons.input_rounded),
            const Spacer(),
            const Text(
              'NIKAI · 38 kHz',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            _key('Silencio', Icons.volume_off_rounded),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _rocker(
                'Volumen',
                'Volumen +',
                'Volumen −',
                Icons.volume_up_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _rocker(
                'Canal',
                'Canal +',
                'Canal −',
                Icons.live_tv_rounded,
              ),
            ),
            const SizedBox(width: 10),
            PowerButton(enabled: enabled, onPressed: () => onCommand('Encendido')),
          ],
        ),
        const SizedBox(height: 22),
        _navigationPad(),
        const SizedBox(height: 17),
        Row(
          children: [
            Expanded(child: _key('Inicio', Icons.home_rounded)),
            const SizedBox(width: 9),
            Expanded(child: _key('Atrás', Icons.arrow_back_rounded)),
            const SizedBox(width: 9),
            Expanded(child: _key('Ajustes', Icons.tune_rounded)),
          ],
        ),
        const SizedBox(height: 16),
        _sectionLabel('ACCESOS DIRECTOS'),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(child: _shortcut('Netflix', const Color(0xFFDC3D45))),
            const SizedBox(width: 8),
            Expanded(child: _shortcut('YouTube', const Color(0xFFE85050))),
            const SizedBox(width: 8),
            Expanded(child: _shortcut('TCL Channel', const Color(0xFF4DA5F5))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _key('TV / guía', Icons.live_tv_outlined)),
            const SizedBox(width: 9),
            Expanded(child: _key('Info', Icons.info_outline_rounded)),
          ],
        ),
        const SizedBox(height: 17),
        _sectionLabel('TECLADO NUMÉRICO'),
        const SizedBox(height: 8),
        _numberPad(),
        const SizedBox(height: 14),
        Row(
          children: [
            _colorKey('Rojo', const Color(0xFFFF5C63)),
            _colorKey('Verde', const Color(0xFF56D69B)),
            _colorKey('Amarillo', const Color(0xFFFFD65C)),
            _colorKey('Azul', const Color(0xFF5CA7FF)),
          ],
        ),
      ],
    ),
  );

  Widget _sectionLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.muted.withValues(alpha: .9),
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    ),
  );

  Widget _numberPad() => GridView.count(
    crossAxisCount: 3,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 7,
    crossAxisSpacing: 7,
    childAspectRatio: 2.1,
    children: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '']
        .map(
          (digit) => digit.isEmpty
              ? const SizedBox.shrink()
              : DigitButton(
                  digit: digit,
                  enabled: enabled,
                  onPressed: () => onCommand(digit),
                ),
        )
        .toList(),
  );

  Widget _colorKey(String label, Color color) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FilledButton(
        onPressed: enabled ? () => onCommand(label) : null,
        style: FilledButton.styleFrom(
          backgroundColor: color.withValues(alpha: .16),
          foregroundColor: color,
          disabledBackgroundColor: AppColors.panel,
          disabledForegroundColor: AppColors.muted,
          minimumSize: const Size(0, 38),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );

  Widget _rocker(String title, String upper, String lower, IconData icon) =>
      Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 9, bottom: 3),
              child: Icon(icon, color: AppColors.muted, size: 16),
            ),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            _rockerButton(upper, Icons.add_rounded),
            Container(height: 1, color: Colors.white.withValues(alpha: .07)),
            _rockerButton(lower, Icons.remove_rounded),
          ],
        ),
      );

  Widget _rockerButton(String label, IconData icon) => SizedBox(
    height: 37,
    width: double.infinity,
    child: IconButton(
      tooltip: label,
      onPressed: enabled ? () => onCommand(label) : null,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 22),
    ),
  );

  Widget _navigationPad() => Column(
    children: [
      const Text(
        'NAVEGACIÓN',
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.6,
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: 204,
        height: 204,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: _direction('Arriba', Icons.keyboard_arrow_up_rounded),
            ),
            Positioned(
              bottom: 0,
              child: _direction('Abajo', Icons.keyboard_arrow_down_rounded),
            ),
            Positioned(
              left: 0,
              child: _direction('Izquierda', Icons.keyboard_arrow_left_rounded),
            ),
            Positioned(
              right: 0,
              child: _direction('Derecha', Icons.keyboard_arrow_right_rounded),
            ),
            SizedBox(
              width: 72,
              height: 72,
              child: FilledButton(
                onPressed: enabled ? () => onCommand('OK') : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  disabledBackgroundColor: const Color(0xFF35403F),
                  foregroundColor: AppColors.ink,
                  shape: const CircleBorder(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _direction(String label, IconData icon) => RemoteIconButton(
    label: label,
    icon: icon,
    enabled: enabled,
    onPressed: () => onCommand(label),
    circular: true,
  );

  Widget _shortcut(String label, Color color) => ShortcutButton(
    label: label,
    color: color,
    enabled: enabled,
    onPressed: () => onCommand(label),
  );
}
