import 'package:flutter/material.dart';

import '../models/result.dart';

class DriverName extends StatelessWidget {
  const DriverName({
    super.key,
    required this.driver,
    required this.constructor,
  });

  final Driver driver;
  final Constructor constructor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("${driver.givenName} ${driver.familyName}"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            constructor.name,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
