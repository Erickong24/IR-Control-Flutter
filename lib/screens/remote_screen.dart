import 'package:flutter/material.dart';

import '../data/tcl_remote_codes.dart';
import '../services/infrared_service.dart';
import '../theme/app_colors.dart';
import '../widgets/device_card.dart';
import '../widgets/ir_status_card.dart';
import '../widgets/remote_control_panel.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  final _infrared = InfraredService();
  bool _checking = true;
  bool _hasEmitter = false;
  bool _sending = false;
  List<List<int>> _ranges = [];
  String _activity = 'Comprobando emisor infrarrojo';

  bool get _canSend => _hasEmitter && !_sending;

  @override
  void initState() {
    super.initState();
    _checkEmitter();
  }

  Future<void> _checkEmitter() async {
    try {
      final available = await _infrared.hasEmitter();
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
    final code = TclRemoteCodes.values[command];
    if (code == null) return;
    setState(() {
      _sending = true;
      _activity = 'Enviando $command…';
    });
    try {
      await _infrared.transmitCode(code);
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
                const DeviceCard(),
                const SizedBox(height: 18),
                RemoteControlPanel(enabled: _canSend, onCommand: _send),
                const SizedBox(height: 16),
                IrStatusCard(
                  checking: _checking,
                  hasEmitter: _hasEmitter,
                  activity: _activity,
                  ranges: _ranges,
                ),
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
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.settings_remote_rounded, color: AppColors.ink),
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
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Comprobar emisor IR',
        onPressed: _checking ? null : _checkEmitter,
        icon: const Icon(Icons.refresh_rounded, color: AppColors.muted),
      ),
    ],
  );
}
