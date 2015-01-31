/*
 * This code is open-source, MIT license. See the LICENSE file
 */

/*
 * This code is open-source, MIT license. See the LICENSE file
 */

import 'dart:html';
import 'dart:math' as MATH;

import 'package:mapspike/model/model.dart';
import 'package:mapspike/presentation/presentation.dart';
import 'package:mapspike/view/view.dart';
import 'package:google_maps/google_maps.dart';
import 'dart:async';


void main()
{


  SimulationView view = new SimulationView.gasPolicy(
      new DateTime.now().millisecondsSinceEpoch,
  "#map_canvas");

  new Timer.periodic(new Duration(milliseconds:80),(t){

    view.step();

  });


}
