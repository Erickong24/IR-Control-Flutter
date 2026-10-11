import 'package:infrared_plugin/infrared_plugin.dart';

class InfraredService {
  final InfraredPlugin _plugin = InfraredPlugin();

  Future<bool> hasEmitter() => _plugin.hasIrEmitter();

  Future<List<List<int>>> getCarrierFrequencies() =>
      _plugin.getCarrierFrequencies();

  Future<void> transmitCode(int code) {
    final pattern = <int>[4000, 4000];
    for (var bit = 23; bit >= 0; bit--) {
      pattern
        ..add(500)
        ..add((code & (1 << bit)) != 0 ? 1000 : 2000);
    }
    pattern
      ..add(500)
      ..add(8500);

    return _plugin.transmitInts(frequency: 38000, pattern: pattern);
  }
}
