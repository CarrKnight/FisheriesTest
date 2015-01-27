/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of view;


/**
 *  The root of the view
 */
class SimulationView
{

  final SimulationPresentation presentation;

  GMap map;

  /**

   */
  final List<String> defaultColors =
  [
      "green",
      "red",
      "blue",
      "yellow",
      "black",
      "white",
  ];


  SimulationView.original(int seed,String selector):
  this._internal(new SimulationPresentation.original(seed),selector);

  /**
   * creates the map, the views for agents and place them on the map
   */
  SimulationView._internal(this.presentation, String selector)
  {
    visualRefresh = true;
    final mapOptions = new MapOptions()
      ..zoom = 8
      ..center = new LatLng(37.649350, 12.582516)
      ..mapTypeId = MapTypeId.SATELLITE
    ;
    final map = new GMap(querySelector(selector), mapOptions);


  //fishery views
    int i=0;
    for(FisheryPresentation fishery in presentation.fisheries.values)
    {
      FisheryView view = new FisheryView(fishery,defaultColors[i]);
      print(defaultColors[i]);
      i++;
      //add the view to the map as well
      view.polygon.map = map;
    }


  }

  void step()=>presentation.step();

}