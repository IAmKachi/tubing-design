import 'package:flutter/material.dart';
import '../components/values.dart';
import 'result.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final tubingOD = TextEditingController();
  final tubingID = TextEditingController();
  final tubingWeight = TextEditingController();
  final yieldStr = TextEditingController();
  final casingOD = TextEditingController();
  final casingID = TextEditingController();
  final packerBore = TextEditingController();
  final surfTubingPressure = TextEditingController();
  final annTubingPressure = TextEditingController();
  final killFluidDensity = TextEditingController();
  final acidDensity = TextEditingController();
  final elasticModulus = TextEditingController();
  final poissonRatio = TextEditingController();
  final depth = TextEditingController();
  final iniSurfTemp = TextEditingController();
  final iniBotTemp = TextEditingController();
  final finalSurfTemp = TextEditingController();
  final finalBotTemp = TextEditingController();

  void getResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Results(
          tubingOD: tubingOD.text,
          tubingID: tubingID.text,
          tubingWeight: tubingWeight.text,
          yieldStr: yieldStr.text,
          casingOD: casingOD.text,
          casingID: casingID.text,
          packerBore: packerBore.text,
          surfTubingPressure: surfTubingPressure.text,
          annTubingPressure: annTubingPressure.text,
          killFluidDensity: killFluidDensity.text,
          acidDensity: acidDensity.text,
          iniSurfTemp: iniSurfTemp.text,
          iniBotTemp: iniBotTemp.text,
          finalSurfTemp: finalSurfTemp.text,
          finalBotTemp: finalBotTemp.text,
          depth: depth.text,
          elasticModulus: elasticModulus.text,
          poissonRatio: poissonRatio.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            // Tubing Data
            const Center(
              child: Text(
                'Tubing Data',
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Value(
                  value: 'OD (in)',
                  controller: tubingOD,
                ),
                Value(
                  value: 'ID (in)',
                  controller: tubingID,
                ),
                Value(
                  value: 'Weight (lb/ft)',
                  controller: tubingWeight,
                ),
                Value(
                  value: 'Yield Strength (lbs)',
                  controller: yieldStr,
                )
              ],
            ),

            // Casing Data
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Casing Data',
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Value(
                  value: 'OD (in)',
                  controller: casingOD,
                ),
                Value(
                  value: 'ID (in)',
                  controller: casingID,
                ),
              ],
            ),

            // Packer Data
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Packer Data',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Value(
                  value: 'Bore diameter (in)',
                  controller: packerBore,
                ),
              ],
            ),

            // Pressure Data
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Pressure Data',
              ),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                Values(
                  value: 'Tubing Pressure at Surface (psi):',
                  controller: surfTubingPressure,
                ),
                const SizedBox(height: 5),
                Values(
                  value: 'Tubing Pressure at Annulus (psi):',
                  controller: annTubingPressure,
                ),
                const SizedBox(height: 5),
                Values(
                  value: 'Kill fluid density (ppg):',
                  controller: killFluidDensity,
                ),
                const SizedBox(height: 5),
                Values(
                  value: 'Acid density (ppg):',
                  controller: acidDensity,
                ),
                Values(
                  value: 'Depth (ft):',
                  controller: depth,
                ),
              ],
            ),

            // Temperature
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Temperature',
              ),
            ),

            // initial temperature
            const SizedBox(height: 10),

            Row(
              children: [
                const Text('Initial (deg F)'),
                Value(
                  value: 'Surface',
                  controller: iniSurfTemp,
                ),
                Value(
                  value: 'Bottom',
                  controller: iniBotTemp,
                ),
              ],
            ),

            // final temperatures
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Final (deg F)  '),
                Value(
                  value: 'Surface',
                  controller: finalSurfTemp,
                ),
                Value(
                  value: 'Bottom',
                  controller: finalBotTemp,
                ),
              ],
            ),

            // Constants
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Constants',
              ),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                Values(
                  value: 'Elastic Modulus:',
                  controller: elasticModulus,
                ),
                const SizedBox(height: 5),
                Values(
                  value: 'Poisson Ratio:',
                  controller: poissonRatio,
                ),
              ],
            ),

            // Calculate button
            TextButton(
              onPressed: getResults,
              child: const Text('Calculate!'),
            ),
          ],
        ),
      ),
    );
  }
}
