import 'package:flutter/material.dart';
import 'package:quitsmoke/comps/particleSpawner.dart';

class ParticlePainter extends CustomPainter {
  ParticlePainter({
    required this.particleCount,
    required this.particles,
  })  : mPaint = new Paint(),
        bgPaint = new Paint()..color = Color.fromARGB(120, 145, 132, 245),
        super(repaint: particles);

  final int particleCount;
  int particleRadius = 3;
  int sprayRadius = 100;

  ParticleSpawner particles;
  Paint mPaint;
  Paint bgPaint;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles.particles) {
      _drawParticle(particle, canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  _drawParticle(Particle particle, Canvas canvas) {
    canvas.drawOval(
      Rect.fromLTWH(particle.x, particle.y, particle.r, particle.r),
      Paint()..color = particle.color,
    );
  }
}

class Particle {
  Particle({
    required double xval,
    required double yval,
    required double vvalX,
    required double vvalY,
    this.color = Colors.black,
    double? avalX,
    double? avalY,
  })  : x = xval,
        y = yval,
        vX = vvalX,
        vY = vvalY;

  double vX;
  double vY;

  double x;
  double y;
  double r = 3;
  final Color color;

  update() {
    x += vX;
    y += vY;

    vX *= 0.99;
    vY *= 0.99;
  }
}
