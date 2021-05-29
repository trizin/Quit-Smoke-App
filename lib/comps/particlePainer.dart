import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quitsmoke/comps/particle.dart';
import 'package:quitsmoke/comps/particleSpawner.dart';

class ParticlePainterWidget extends StatefulWidget {
  final Size widgetSize;
  ParticlePainterWidget({Key key, this.widgetSize}) : super(key: key);

  @override
  _ParticlePainterWidgetState createState() => _ParticlePainterWidgetState();
}

class _ParticlePainterWidgetState extends State<ParticlePainterWidget> {
  Timer _timer;
  ValueNotifier<double> _time;

  ParticleSpawner particles;

  @override
  void initState() {
    super.initState();

    particles = new ParticleSpawner(size: widget.widgetSize);
    particles.createParticles(3);

    _time = ValueNotifier(0);

    // Setup timer.
    final begin = DateTime.now();
    _timer = Timer.periodic(
      Duration(
        microseconds: 1e6 ~/ 60, // 60 FPS
      ),
      (_) {
        _time.value += 1;
        if (_time.value % 70 == 0) {
          particles.createParticles(3);
        }

        particles.updateParticles();
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _time.dispose();
    super.dispose();
  }

  void createParticles(Size size) {
    final random = Random();
    double initialX = size.width / 2;
    double initialY = size.height / 2;

    for (int i = 0; i < 100; i++) {
      particles.particles.add(Particle(
        xval: initialX,
        yval: initialY,
        vvalX: random.nextDouble() * 2,
        vvalY: random.nextDouble() * 2,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        willChange: true,
        painter: ParticlePainter(particleCount: 5, particles: particles),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}
