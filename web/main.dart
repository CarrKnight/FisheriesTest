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


  new SimulationView.oneLonelyFishery(
  "#lonely");

  new SimulationView.overfished(
  "#overfishing");

  new SimulationView.chooseRichest(
  "#richest");



  new SimulationView.original(
  "#final");



  new SimulationView.gasPolicy(
  "#gaspolicy");



}
