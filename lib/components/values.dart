import 'package:flutter/material.dart';

class Value extends StatelessWidget {
  final TextEditingController? controller;
  final String value;

  const Value({super.key, required this.value, this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value),
          SizedBox(
            width: 60,
            height: 25,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
            ),
          ),
        ],
      ),
    );
  }
}

class Values extends StatelessWidget {
  final TextEditingController? controller;
  final String value;

  const Values({super.key, required this.value, this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(value),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          height: 25,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
          ),
        ),
      ],
    );
  }
}
