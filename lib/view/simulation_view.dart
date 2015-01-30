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

  MouseTrackingMap map;

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

  SimulationView.overfished(int seed,String selector):
  this._internal(new SimulationPresentation.overfished(seed),selector,
                 new LatLng(35.0, 139.0));

  SimulationView.gasPolicy(int seed,String selector):
  this._internal(new SimulationPresentation.gasPolicy(seed),selector,
                 new LatLng(42.433653, -87.044186));



  SimulationView.oneLonelyFishery(int seed,String selector):
  this._internal(new SimulationPresentation.oneLonelyFishery(seed),selector,
                 new LatLng(19.5, -157.5));

  SimulationView.chooseRichest(int seed,String selector):
  this._internal(new SimulationPresentation.chooseRichest(seed),selector,
                 new LatLng(-11.781268, -77.289216));

  SimulationView.original(int seed,String selector):
  this._internal(new SimulationPresentation.original(seed),selector,
                 new LatLng(36.649350, 12.582516));

  /**
   * creates the map, the views for agents and place them on the map
   */
  SimulationView._internal(this.presentation, String selector, LatLng mapCenter)
  {
    visualRefresh = true;
    final mapOptions = new MapOptions()
      ..zoom = 8
      ..center = mapCenter
      ..mapTypeId = MapTypeId.HYBRID
    ;
    final map = new MouseTrackingMap(querySelector(selector), mapOptions);


  //fishery views
    int i=0;
    for(FisheryPresentation fishery in presentation.fisheries.values)
    {
      FisheryView view = new FisheryView(fishery,defaultColors[i]);
      print(defaultColors[i]);
      i++;
      //add the view to the map as well
      view.addToMap(map);
    }


  }

  void step()=>presentation.step();

}