import 'package:flutter/material.dart';
import 'rotation_lock.dart';

class LandscapeOnlyGate extends StatefulWidget {
  final Widget child;
  const LandscapeOnlyGate({super.key, required this.child});

  @override
  State<LandscapeOnlyGate> createState() => _LandscapeOnlyGateState();
}

class _LandscapeOnlyGateState extends State<LandscapeOnlyGate> {
  bool? autoRotateEnabled;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await RotationLock.isAutoRotateEnabled();
    if (mounted) setState(() => autoRotateEnabled = v);
  }

  @override
  Widget build(BuildContext context) {
    final o = MediaQuery.of(context).orientation;

    if (o == Orientation.portrait) {
      final locked = (autoRotateEnabled == false);

      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.screen_rotation, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    locked ? "Rotation is locked" : "Landscape required",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    locked
                        ? "Turn ON Auto-rotate (disable Portrait Lock),\nthen rotate your device to Landscape."
                        : "Rotate your device to Landscape.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (locked)
                    ElevatedButton(
                      onPressed: () async => RotationLock.openDisplaySettings(),
                      child: const Text("Open Display Settings"),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _load,
                    child: const Text("I fixed it — retry"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}