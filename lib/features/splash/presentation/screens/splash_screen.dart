import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _motionAsset = 'assets/images/auth/fluid_launch.webp';
const _stillAsset = 'assets/images/auth/fluid_launch_still.webp';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Asteria',
      child: ColoredBox(
        color: const Color(0xff100d1c),
        child: SizedBox.expand(
          child: MediaQuery.disableAnimationsOf(context)
              ? _StillMark(onFinished: onFinished)
              : _FluidMark(onFinished: onFinished),
        ),
      ),
    );
  }
}

class _StillMark extends StatelessWidget {
  const _StillMark({required this.onFinished});

  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) onFinished();
    });
    return Image.asset(
      _stillAsset,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
    );
  }
}

class _FluidMark extends StatefulWidget {
  const _FluidMark({required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<_FluidMark> createState() => _FluidMarkState();
}

class _FluidMarkState extends State<_FluidMark> {
  ui.Image? _frame;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_play());
  }

  Future<void> _play() async {
    ui.Codec? codec;
    try {
      final data = await rootBundle.load(_motionAsset);
      if (!mounted) return;
      codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final clock = Stopwatch()..start();
      var elapsed = Duration.zero;
      for (var index = 0; mounted && index < codec.frameCount; index++) {
        final next = await codec.getNextFrame();
        if (!mounted) {
          next.image.dispose();
          return;
        }
        final previous = _frame;
        setState(() => _frame = next.image);
        await WidgetsBinding.instance.endOfFrame;
        previous?.dispose();
        elapsed += next.duration;
        final remaining = elapsed - clock.elapsed;
        if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      codec?.dispose();
      if (mounted) widget.onFinished();
    }
  }

  @override
  void dispose() {
    _frame?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Image.asset(
        _stillAsset,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      );
    }
    return RawImage(image: _frame, fit: BoxFit.cover);
  }
}
