import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quitsmoke/comps/particle.dart';

class ParticleSpawner with ChangeNotifier {
  List<Particle> particles = [];
  double initialX;
  double initialY;
  final Size size;
  double degree = 0;
  double sprayRadius = 70;
  ParticleSpawner({this.size});
  createParticles(int count) {
    final random = Random();
    initialX = size.width / 2;
    initialY = size.height / 4.2;

    /*    for (int i = 0; i < 1000; i++) {
      particles.add(Particle(
          xval: initialX,
          yval: initialY,
          vvalX: sin(i / 100) * (random.nextDouble() + 1),
          vvalY: cos(i / 100) * (random.nextDouble() + 1)));
    } */

    for (int i = 0; i < count; i++) {
      degree += 0.01;

      particles.add(Particle(
          color: Colors.lightGreen.withAlpha(random.nextInt(125)),
          xval: initialX,
          yval: initialY,
          vvalX: sin(random.nextDouble() * 100),
          vvalY: cos(random.nextDouble() * 100)));
    }
  }

  updateParticles() {
    for (var particle in particles) {
      particle.update();
    }
    particles.removeWhere((element) =>
        (initialX - element.x).abs() > sprayRadius ||
        (initialY - element.y).abs() > sprayRadius ||
        (element.vX.abs() < 0.1 && element.vY.abs() < 0.1));

    notifyListeners();
  }
}
