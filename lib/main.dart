import 'package:flutter/material.dart';
import 'package:infrared_plugin/infrared_plugin.dart';

void main() => runApp(const IrControlApp());

const ink = Color(0xFF101516);
const panel = Color(0xFF1A2223);
const muted = Color(0xFF9BA8A6);
const mint = Color(0xFFB8F36B);

class IrControlApp extends StatelessWidget {
  const IrControlApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'IR Control',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mint,
        brightness: Brightness.dark,
        surface: panel,
      ),
      useMaterial3: true,
    ),
    home: const RemoteScreen(),
  );
}

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  final _infrared = InfraredPlugin();
  bool _checking = true;
  bool _hasEmitter = false;
  bool _sending = false;
  List<List<int>> _ranges = [];
  String _activity = 'Comprobando emisor infrarrojo';

  // Perfil NIKAI confirmado por el usuario con el TCL 50P7K. Los botones
  // adicionales siguen el mapa publicado para TCL 55T8B con control RC833.
  static const _codes = <String, int>{
    'Encendido': 0x0D5F2A,
    'Silencio': 0x0C0F3F,
    'Fuente': 0x05CFA3,
    'Inicio': 0x0F7F08,
    'Atrás': 0x0D8F27,
    'Ajustes': 0x030FCF,
    'Arriba': 0x0A6F59,
    'Abajo': 0x0A7F58,
    'Izquierda': 0x0A9F56,
    'Derecha': 0x0A8F57,
    'OK': 0x00BFF4,
    'Volumen −': 0x0D1F2E,
    'Volumen +': 0x0D0F2F,
    'Canal −': 0x0D3F2C,
    'Canal +': 0x0D2F2D,
    'TV / guía': 0x0E5F1A,
    'Info': 0x0C3F3C,
    'Netflix': 0x010FEF,
    'YouTube': 0x01DFE2,
    'TCL Channel': 0x01CFE3,
    '1': 0x0CEF31,
    '2': 0x0CDF32,
    '3': 0x0CCF33,
    '4': 0x0CBF34,
    '5': 0x0CAF35,
    '6': 0x0C9F36,
    '7': 0x0C8F37,
    '8': 0x0C7F38,
    '9': 0x0C6F39,
    '0': 0x0CFF30,
    'Rojo': 0x0FFF00,
    'Verde': 0x017FE8,
    'Amarillo': 0x01BFE4,
    'Azul': 0x027FD8,
  };

  bool get _canSend => _hasEmitter && !_sending;

  @override
  void initState() {
    super.initState();
    _checkEmitter();
  }

  Future<void> _checkEmitter() async {
    try {
      final available = await _infrared.hasIrEmitter();
      final ranges = available
          ? await _infrared.getCarrierFrequencies()
          : <List<int>>[];
      if (!mounted) return;
      setState(() {
        _hasEmitter = available;
        _ranges = ranges;
        _checking = false;
        _activity = available
            ? 'Listo · TCL 50P7K · perfil infrarrojo verificado'
            : 'Este teléfono no reporta un emisor IR integrado';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _activity = 'No se pudo consultar el emisor en este dispositivo';
      });
    }
  }

  Future<void> _send(String command) async {
    if (!_canSend) return;
    final code = _codes[command];
    if (code == null) return;
    setState(() {
      _sending = true;
      _activity = 'Enviando $command…';
    });
    try {
      final pattern = <int>[4000, 4000];
      for (var bit = 23; bit >= 0; bit--) {
        pattern
          ..add(500)
          ..add((code & (1 << bit)) != 0 ? 1000 : 2000);
      }
      pattern
        ..add(500)
        ..add(8500);
      await _infrared.transmitInts(frequency: 38000, pattern: pattern);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _activity = '$command enviado al TCL 50P7K';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _activity = 'No se pudo enviar $command: $error';
      });
    }
  }

  Widget _key(String label, IconData icon, {bool accent = false}) =>
      _RemoteButton(
        label: label,
        icon: icon,
        accent: accent,
        enabled: _canSend,
        onPressed: () => _send(label),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(),
                const SizedBox(height: 16),
                _deviceCard(),
                const SizedBox(height: 18),
                _remoteBody(),
                const SizedBox(height: 16),
                _statusCard(),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _topBar() => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: mint,
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.settings_remote_rounded, color: ink),
      ),
      const SizedBox(width: 11),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IR CONTROL',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Control remoto',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Comprobar emisor IR',
        onPressed: _checking ? null : _checkEmitter,
        icon: const Icon(Icons.refresh_rounded, color: muted),
      ),
    ],
  );

  Widget _deviceCard() => Container(
    padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: mint.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.tv_rounded, color: mint),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TCL 50P7K',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 3),
              Text(
                'Google TV · perfil guardado',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle_rounded, color: mint, size: 19),
      ],
    ),
  );

  Widget _remoteBody() => Container(
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
                color: mint,
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
            _PowerKey(enabled: _canSend, onPressed: () => _send('Encendido')),
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
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'ACCESOS DIRECTOS',
            style: TextStyle(
              color: muted.withValues(alpha: .9),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
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
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'TECLADO NUMÉRICO',
            style: TextStyle(
              color: muted.withValues(alpha: .9),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
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
              : _DigitButton(
                  digit: digit,
                  enabled: _canSend,
                  onPressed: () => _send(digit),
                ),
        )
        .toList(),
  );

  Widget _colorKey(String label, Color color) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FilledButton(
        onPressed: _canSend ? () => _send(label) : null,
        style: FilledButton.styleFrom(
          backgroundColor: color.withValues(alpha: .16),
          foregroundColor: color,
          disabledBackgroundColor: panel,
          disabledForegroundColor: muted,
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
          color: panel,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 9, bottom: 3),
              child: Icon(icon, color: muted, size: 16),
            ),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: muted,
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
      onPressed: _canSend ? () => _send(label) : null,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 22),
    ),
  );

  Widget _navigationPad() => Column(
    children: [
      const Text(
        'NAVEGACIÓN',
        style: TextStyle(
          color: muted,
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
                onPressed: _canSend ? () => _send('OK') : null,
                style: FilledButton.styleFrom(
                  backgroundColor: mint,
                  disabledBackgroundColor: const Color(0xFF35403F),
                  foregroundColor: ink,
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

  Widget _direction(String label, IconData icon) => _RemoteButton(
    label: label,
    icon: icon,
    enabled: _canSend,
    onPressed: () => _send(label),
    circular: true,
  );

  Widget _shortcut(String label, Color color) => _ShortcutButton(
    label: label,
    color: color,
    enabled: _canSend,
    onPressed: () => _send(label),
  );

  Widget _statusCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
    ),
    child: Row(
      children: [
        if (_checking)
          const SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(strokeWidth: 2, color: mint),
          )
        else
          Icon(
            _hasEmitter ? Icons.circle : Icons.error_outline_rounded,
            color: _hasEmitter ? mint : Colors.redAccent,
            size: 12,
          ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _checking
                    ? 'Buscando emisor IR'
                    : _hasEmitter
                    ? 'Emisor IR disponible'
                    : 'Emisor IR no detectado',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _activity,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: muted, fontSize: 10, height: 1.3),
              ),
              if (_ranges.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Frecuencia compatible: ${_ranges.map((r) => '${r[0]}–${r[1]} Hz').join(', ')}',
                  style: const TextStyle(color: muted, fontSize: 9),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _RemoteButton extends StatelessWidget {
  const _RemoteButton({
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
        backgroundColor: accent ? mint : panel,
        foregroundColor: accent ? ink : Colors.white,
        disabledBackgroundColor: const Color(0xFF202928),
        disabledForegroundColor: const Color(0xFF65716F),
        shape: const CircleBorder(),
      ),
      icon: Icon(icon, size: circular ? 29 : 20),
    ),
  );
}

class _PowerKey extends StatelessWidget {
  const _PowerKey({required this.enabled, required this.onPressed});
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
        disabledBackgroundColor: panel,
        disabledForegroundColor: muted,
        shape: const CircleBorder(),
      ),
      icon: const Icon(Icons.power_settings_new_rounded, size: 23),
    ),
  );
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({
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
      disabledBackgroundColor: panel,
      disabledForegroundColor: muted,
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

class _DigitButton extends StatelessWidget {
  const _DigitButton({
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
      backgroundColor: panel,
      foregroundColor: Colors.white,
      disabledBackgroundColor: const Color(0xFF202928),
      disabledForegroundColor: muted,
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
