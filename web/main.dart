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


  SimulationView view = new SimulationView.original(new DateTime.now().millisecondsSinceEpoch,
  "#map_canvas");

  new Timer.periodic(new Duration(milliseconds:10),(t){

    view.step();

  });


}


void main2() {
  visualRefresh = true;
  final mapOptions = new MapOptions()
    ..zoom = 8
    ..center = new LatLng(37.649350, 12.582516)
    ..mapTypeId = MapTypeId.SATELLITE
  ;
  final map = new GMap(querySelector("#map_canvas"), mapOptions);



  Fishery fishery = new Fishery([
  new MATH.Point(37.548665, 12.248152),
  new MATH.Point(37.718324, 11.880110),
  new MATH.Point( 37.570438, 11.665876),
  new MATH.Point(37.282526, 12.055891)]);

  FisheryPresentation presentation = new FisheryPresentation(fishery);

  FisheryView view = new FisheryView(presentation,"red");

  view.addToMap(map);

  new Timer.periodic(new Duration(seconds:1),(t){

    fishery.bioMass /=2;
    presentation.endOfDay();

  });



}


void main1() {
  visualRefresh = true;
  final mapOptions = new MapOptions()
    ..zoom = 8
    ..center = new LatLng(37.649350, 12.582516)
    ..mapTypeId = MapTypeId.SATELLITE
  ;
  final map = new GMap(querySelector("#map_canvas"), mapOptions);

// -  37.718324, 11.880110 - 37.570438, 11.665876 -  37.282526, 12.055891
  //zona 1
  List<LatLng> coordinates = [
  new LatLng(37.548665, 12.248152),
  new LatLng(37.718324, 11.880110),
  new LatLng( 37.570438, 11.665876),
  new LatLng(37.282526, 12.055891)
  ];

  PolygonOptions zona1Opt = new PolygonOptions();
  zona1Opt.paths = coordinates;
  zona1Opt.strokeColor= '#FF0000';
  zona1Opt.strokeWeight= 2;
  zona1Opt.fillColor= '#FF0000';
  zona1Opt.fillOpacity= 0.35;
  zona1Opt.strokeOpacity= 0.8;

  Polygon zona1 = new  Polygon(zona1Opt);
  zona1.map=map;

  print(zona1.get("fillColor"));
  zona1.set("fillColor","green");
  print(zona1.get("fillColor"));






}