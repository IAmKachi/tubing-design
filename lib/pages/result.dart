import 'package:flutter/material.dart';
import '../src/classes.dart';

String analyze(Forces forces) {
  if (forces.isItFeasible) {
    return 'The total tension force is LESS THAN 30% safety factor by ${forces.feasibleByHowMuch.toStringAsPrecision(4)}%. Thus, this design CAN be used';
  } else {
    return 'The total tension force is GREATER THAN 30% safety factor by ${forces.feasibleByHowMuch.toStringAsPrecision(4)}%. Thus, this design CANNOT be used';
  }
}

class Results extends StatefulWidget {
  final String _tubingOD;
  final String _tubingID;
  final String _tubingWeight;
  final String _casingOD;
  final String _casingID;
  final String _packerBore;
  final String _surfTubingPressure;
  final String _annTubingPressure;
  final String _killFluidDensity;
  final String _acidDensity;
  final String _iniSurfTemp;
  final String _iniBotTemp;
  final String _finalSurfTemp;
  final String _finalBotTemp;
  final String _depth;
  final String _elasticModulus;
  final String _poissonRatio;
  final String _yieldStr;

  const Results({
    super.key,
    required String tubingOD,
    required String tubingID,
    required String tubingWeight,
    required String casingOD,
    required String casingID,
    required String packerBore,
    required String surfTubingPressure,
    required String annTubingPressure,
    required String killFluidDensity,
    required String acidDensity,
    required String iniSurfTemp,
    required String iniBotTemp,
    required String finalSurfTemp,
    required String finalBotTemp,
    required String depth,
    required String elasticModulus,
    required String poissonRatio,
    required String yieldStr,
  })  : _tubingOD = tubingOD,
        _tubingID = tubingID,
        _tubingWeight = tubingWeight,
        _casingOD = casingOD,
        _casingID = casingID,
        _packerBore = packerBore,
        _surfTubingPressure = surfTubingPressure,
        _annTubingPressure = annTubingPressure,
        _killFluidDensity = killFluidDensity,
        _acidDensity = acidDensity,
        _iniSurfTemp = iniSurfTemp,
        _iniBotTemp = iniBotTemp,
        _finalSurfTemp = finalSurfTemp,
        _finalBotTemp = finalBotTemp,
        _depth = depth,
        _elasticModulus = elasticModulus,
        _poissonRatio = poissonRatio,
        _yieldStr = yieldStr;

  double get tubingOD => double.parse(_tubingOD);
  double get tubingID => double.parse(_tubingID);
  double get tubingWeight => double.parse(_tubingWeight);
  double get casingOD => double.parse(_casingOD);
  double get casingID => double.parse(_casingID);
  double get packerBore => double.parse(_packerBore);
  double get surfTubingPressure => double.parse(_surfTubingPressure);
  double get annTubingPressure => double.parse(_annTubingPressure);
  double get killFluidDensity => double.parse(_killFluidDensity);
  double get acidDensity => double.parse(_acidDensity);
  double get iniSurfTemp => double.parse(_iniSurfTemp);
  double get iniBotTemp => double.parse(_iniBotTemp);
  double get finalSurfTemp => double.parse(_finalSurfTemp);
  double get finalBotTemp => double.parse(_finalBotTemp);
  double get depth => double.parse(_depth);
  double? get elasticModulus =>
      double.parse(_elasticModulus == '' ? '30e6' : _elasticModulus);
  double? get poissonRatio =>
      double.parse(_poissonRatio == '' ? '0.3' : _poissonRatio);
  double? get yieldStr =>
      double.tryParse(_yieldStr == '' ? '145000' : _yieldStr);

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  late Tubing tubing;
  late Casing casing;
  late Packer packer;
  late Pressure pressure;
  late Temperature temp;
  late Constants constants;
  late Forces forces;
  bool anchored = false;

  void isAnchored(bool? value) {
    setState(() {
      anchored = value!;

      forces = Forces(
          tubing: tubing,
          packer: packer,
          pressure: pressure,
          temp: temp,
          constants: constants,
          anchored: anchored);
    });
  }

  @override
  void initState() {
    tubing = Tubing(
      od: widget.tubingOD,
      id: widget.tubingID,
      weight: widget.tubingWeight,
      yieldStr: widget.yieldStr ?? 145000,
    );

    casing = Casing(
      od: widget.casingOD,
      id: widget.casingID,
    );

    packer = Packer(bore: widget.packerBore);

    pressure = Pressure(
      surfTubingPressure: widget.surfTubingPressure,
      annTubingPressure: widget.annTubingPressure,
      killFluidDensity: widget.killFluidDensity,
      acidDensity: widget.acidDensity,
      tubing: tubing,
      depth: widget.depth,
    );

    temp = Temperature(
      initialTemp: [widget.iniSurfTemp, widget.iniBotTemp],
      finalTemp: [widget.finalSurfTemp, widget.finalBotTemp],
    );

    constants = Constants(
        casing: casing,
        tubing: tubing,
        E: widget.elasticModulus ?? 30e6,
        Y: widget.poissonRatio ?? 0.3);

    forces = Forces(
        tubing: tubing,
        packer: packer,
        pressure: pressure,
        temp: temp,
        constants: constants);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('FORCES ACTING ON TUBING'),
              Text(
                  'Piston Force: ${forces.piston().toStringAsPrecision(4)} lbs'),
              Text(
                  'Helical Buckling Force: ${forces.helicalBuckling().toStringAsPrecision(4)} lbs'),
              Text(
                  'Ballooning Force: ${forces.ballooning().toStringAsPrecision(4)} lbs'),
              Text(
                  'Temperature Force: ${forces.temperature().toStringAsPrecision(4)} lbs'),

              // is tubing anchored?
              Row(
                children: [
                  const Text('Is tubing anchored?'),
                  const SizedBox(width: 30),
                  Checkbox(value: anchored, onChanged: isAnchored),
                ],
              ),

              // total force
              Text(
                  'Total length displaced: ${forces.totalLength.toStringAsPrecision(4)} in (${(forces.totalLength / 12).toStringAsPrecision(4)} ft)'),

              // Equivalent tension load
              Text(
                  'Equivalent Tension Load: ${forces.equivalentTensionLoad.toStringAsPrecision(7)} lbs'),

              Text(
                  'Total Tension Load: ${forces.totalTensionLoad.toStringAsPrecision(7)} lbs'),

              Text(analyze(forces)),
            ],
          ),
        ),
      ),
    );
  }
}
