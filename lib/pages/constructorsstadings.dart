import 'package:flutter/material.dart';

import '../models/result.dart';

class ConstructorStanding {
  final Constructor constructor;

  double points;

  ConstructorStanding({
    required this.constructor,
    this.points = 0.0,
  });
}

class ConstructorStandingsList extends StatelessWidget {
  const ConstructorStandingsList({
    super.key,
    required this.constructorStandings,
  });

  final List<ConstructorStanding> constructorStandings;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: constructorStandings.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text(
            (index + 1).toString(),
            style: const TextStyle(fontSize: 30),
          ),
          title: Text(constructorStandings[index].constructor.name),
          trailing: Text(constructorStandings[index].points.toString()),
        );
      },
    );
  }
}
