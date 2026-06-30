import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orb_state_provider.dart';

/// JARVIS-style holographic orb. Renders a GLSL fragment shader and
/// animates its "energy" uniform based on [orbStateProvider].
class HolographicOrb extends ConsumerStatefulWidget {
  const HolographicOrb({super.key, this.size = 220});

  final double size;

  @override
  ConsumerState<HolographicOrb> createState() => _HolographicOrbState();
}

class _HolographicOrbState extends ConsumerState<HolographicOrb>
    with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  late final Ticker _ticker;
  double _elapsed = 0;
  double _currentEnergy = 0.15;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker((elapsed) {
      setState(() => _elapsed = elapsed.inMilliseconds / 1000.0);
    })
      ..start();
  }

  Future<void> _loadShader() async {
    final program =
        await ui.FragmentProgram.fromAsset('assets/shaders/orb.frag');
    setState(() => _shader = program.fragmentShader());
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orbState = ref.watch(orbStateProvider);
    final targetEnergy = energyForState(orbState);
    // Smooth toward target energy each frame instead of snapping —
    // avoids a jarring pop when state changes (e.g. listening -> thinking).
    _currentEnergy += (targetEnergy - _currentEnergy) * 0.08;

    if (_shader == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    _shader!
      ..setFloat(0, widget.size)
      ..setFloat(1, widget.size)
      ..setFloat(2, _elapsed)
      ..setFloat(3, _currentEnergy)
      ..setFloat(4, 0.30) // R
      ..setFloat(5, 0.70) // G
      ..setFloat(6, 1.00); // B — cyan-ish "holographic" tone

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(painter: _ShaderPainter(_shader!)),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter(this.shader);
  final ui.FragmentShader shader;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) => true;
}
