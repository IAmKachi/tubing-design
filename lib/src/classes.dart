import 'dart:math';

double area(double diameter) => (pi * pow(diameter, 2)) / 4;

class Depth {
  const Depth({required double depth}) : _depth = depth;

  final double _depth;

  double get depth => _depth;
  double get depthIn => _depth * 12;
}

class Tubing {
  const Tubing({
    required double od,
    required double id,
    required double weight,
    required double yieldStr,
  })  : _od = od,
        _id = id,
        _weight = weight,
        _yieldStr = yieldStr;

  final double _od;
  final double _id;
  final double _weight;
  final double _yieldStr;

  double get od => _od;
  double get id => _id;
  double get weight => _weight;
  double get weightIn => _weight / 12;
  double get maxYieldStr => _yieldStr;
  double get maxAllowableYieldStr => _yieldStr * 0.7;
  double get insideTubingArea => area(_id);
  double get outerTubingArea => area(_od);
  double get crossSection => outerTubingArea - insideTubingArea;
  double get momentOfInertia => pi * (pow(od, 4) - pow(id, 4)) / 64;
  double get R => od / id;
}

class Casing {
  const Casing({required double od, required double id})
      : _id = id,
        _od = od;

  final double _od;
  final double _id;

  double get od => _od;
  double get id => _id;
}

class Packer {
  const Packer({required double bore}) : _bore = bore;

  final double _bore;

  double get bore => _bore;
  double get packerArea => area(bore);
}

class Pressure extends Depth {
  const Pressure({
    required double surfTubingPressure,
    required double annTubingPressure,
    // densities
    required double killFluidDensity,
    required double acidDensity,
    required Tubing tubing,
    required double depth,
  })  : _surfTubingPressure = surfTubingPressure,
        _annTubingPressure = annTubingPressure,
        _killFluidDensity = killFluidDensity,
        _acidDensity = acidDensity,
        _tubing = tubing,
        super(depth: depth);

  final double _surfTubingPressure;
  final double _annTubingPressure;
  final double _killFluidDensity;
  final double _acidDensity;
  final Tubing _tubing;

  double initialConditions({bool balloon = false}) {
    double pressure = 0.052 * _killFluidDensity * depth;
    return balloon ? pressure / 2 : pressure;
  }

  List<double> finalConditions({bool balloon = false}) {
    double pI = _surfTubingPressure + 0.052 * _acidDensity * depth;
    double pO = _annTubingPressure + 0.052 * _killFluidDensity * depth;

    if (balloon) {
      pI = (_surfTubingPressure + pI) / 2;
      pO = (_annTubingPressure + pO) / 2;
    }

    return [pI, pO];
  }

  double internalPressureDiff({bool balloon = false}) {
    return finalConditions(balloon: balloon)[0] -
        initialConditions(balloon: balloon);
  }

  double outerPressureDiff({bool balloon = false}) {
    return finalConditions(balloon: balloon)[1] -
        initialConditions(balloon: balloon);
  }

  double get fluidWeightInTubing =>
      _acidDensity * _tubing.insideTubingArea / 231;

  double get fluidWeightOutsideTubing =>
      _killFluidDensity * _tubing.outerTubingArea / 231;
}

class Temperature {
  const Temperature({
    required List<double> initialTemp,
    required List<double> finalTemp,
  })  : _initialTemp = initialTemp,
        _finalTemp = finalTemp;

  /// contains initial temperature: [surface, bottom]
  final List<double> _initialTemp;

  /// contains final temperature: [surface, bottom]
  final List<double> _finalTemp;

  double get avgInitialTemp => _initialTemp.reduce((temp, el) => temp + el) / 2;
  double get avgFinalTemp => _finalTemp.reduce((temp, el) => temp + el) / 2;
  double get tempDiff => avgFinalTemp - avgInitialTemp;
}

class Constants {
  const Constants({
    required Casing casing,
    required Tubing tubing,
    double E = 30e6,
    double Y = 0.3,
    double B = 0.0000069,
  })  : _casing = casing,
        _tubing = tubing,
        _e = E,
        _y = Y,
        _b = B;

  final Casing _casing;
  final Tubing _tubing;
  final double _e;
  final double _y;
  final double _b;

  // take care of setters later
  double get elasticModulus => _e;
  double get poissonRatio => _y;
  double get r => (_casing.id - _tubing.od) / 2;
  double get expansionCoef => _b;
}

class Forces {
  const Forces({
    required Tubing tubing,
    required Packer packer,
    required Pressure pressure,
    required Temperature temp,
    required Constants constants,
    bool anchored = false,
  })  : _tubing = tubing,
        _packer = packer,
        _pressure = pressure,
        _temp = temp,
        _constant = constants,
        _anchored = anchored;

  final Tubing _tubing;
  final Packer _packer;
  final Pressure _pressure;
  final Temperature _temp;
  final Constants _constant;
  final bool _anchored;

  double piston() {
    double e = _constant.elasticModulus;

    double factor = _pressure.depthIn / (e * _tubing.crossSection);
    double firstTerm = (_packer.packerArea - _tubing.insideTubingArea) *
        _pressure.internalPressureDiff();
    double secondTerm = (_packer.packerArea - _tubing.outerTubingArea) *
        _pressure.outerPressureDiff();

    return -factor * (firstTerm - secondTerm);
  }

  double helicalBuckling() {
    double e = _constant.elasticModulus;
    double i = _tubing.momentOfInertia;
    double r = _constant.r;

    double factor = pow(r, 2) * pow(_packer.packerArea, 2) / (8 * e * i);
    double term =
        _pressure.internalPressureDiff() - _pressure.outerPressureDiff();
    double numerator = pow(term, 2).toDouble();
    double sumOfWeights = _tubing.weightIn +
        _pressure.fluidWeightInTubing -
        _pressure.fluidWeightOutsideTubing;

    return -factor * numerator / sumOfWeights;
  }

  double ballooning() {
    double e = _constant.elasticModulus;
    double y = _constant.poissonRatio;
    double r = _tubing.R;

    double factor = 2 * _pressure.depthIn * y / e;
    double numerator = _pressure.internalPressureDiff(balloon: true) -
        pow(r, 2) * _pressure.outerPressureDiff(balloon: true);
    double denominator = pow(r, 2) - 1;

    return -factor * numerator / denominator;
  }

  double temperature() {
    return _constant.expansionCoef * _pressure.depthIn * _temp.tempDiff;
  }

  double get totalLength => _anchored
      ? ballooning() + temperature()
      : piston() + helicalBuckling() + ballooning() + temperature();

  // double get totalAnchoredLength => ballooning() + temperature();
  // double totalLength({bool anchored = false}) {
  //   return anchored
  //       ? ballooning() + temperature()
  //       : piston() + helicalBuckling() + ballooning() + temperature();
  // }

  // double equivalentTensionLoad({bool anchored = false}) {
  //   double e = _constant.elasticModulus;
  //   double aS = _tubing.crossSection;
  //   double depth = _pressure.depthIn;

  //   return totalLength(anchored: anchored) * e * aS / depth;
  // }
  double get equivalentTensionLoad =>
      totalLength *
      _constant.elasticModulus *
      _tubing.crossSection /
      _pressure.depthIn;

  // double totalTensionLoad({bool anchored = false}) =>
  //     equivalentTensionLoad() + (_pressure.depth * _tubing.weight);
  double get totalTensionLoad =>
      equivalentTensionLoad.abs() + (_pressure.depth * _tubing.weight);

  bool get isItFeasible => totalTensionLoad < _tubing.maxAllowableYieldStr;

  double get feasibleByHowMuch => isItFeasible
      ? (totalTensionLoad - _tubing.maxAllowableYieldStr).abs() *
          100 /
          _tubing.maxAllowableYieldStr
      : (totalTensionLoad - _tubing.maxAllowableYieldStr) *
          100 /
          _tubing.maxAllowableYieldStr;
}

// void main() {
//   const tubing = Tubing(od: 2.875, id: 2.441, weight: 6.5);
//   const casing = Casing(od: 7, id: 6.094);
//   const packer = Packer(bore: 4);
//   const pressure = Pressure(
//       surfTubingPressure: 6000,
//       annTubingPressure: 2500,
//       killFluidDensity: 9,
//       acidDensity: 9.5,
//       tubing: tubing,
//       depth: 14400);
//   const temp = Temperature(initialTemp: [74, 290], finalTemp: [70, 90]);

//   const force = Forces(
//       tubing: tubing,
//       packer: packer,
//       pressure: pressure,
//       temp: temp,
//       constants: Constants(casing: casing, tubing: tubing));

//   print('Piston: ${force.piston()}');
//   print('Helical: ${force.helicalBuckling()}');
//   print('Ballooning: ${force.ballooning()}');
//   print('Temperature: ${force.temperature()}');
// }
