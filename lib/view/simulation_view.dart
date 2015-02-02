/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of view;

typedef SimulationPresentation PresentationFactory();

/**
 *  The root of the view
 */
class SimulationView
{

  final PresentationFactory factory;

  SimulationPresentation presentation;

  MouseTrackingMap map;

  DivElement container;

  List<FisheryView> fisheries = [];

  FishermenView fishermen;

  ControlBar control;

  final String simulationName;

  final LatLng mapCenter;

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

  SimulationView.overfished(String selector):
  this._internal(()=>new SimulationPresentation.overfished(new DateTime.now().millisecondsSinceEpoch),selector,
                 new LatLng(34.0, 139.0));

  SimulationView.gasPolicy(String selector):
  this._internal(()=>new SimulationPresentation.gasPolicy(new DateTime.now().millisecondsSinceEpoch),selector,
                 new LatLng(42.433653, -87.044186));



  SimulationView.oneLonelyFishery(String selector):
  this._internal(()=>new SimulationPresentation.oneLonelyFishery(new DateTime.now().millisecondsSinceEpoch),selector,
                 new LatLng(20.0, -157.5));

  SimulationView.chooseRichest(String selector):
  this._internal(()=>new SimulationPresentation.chooseRichest(new DateTime.now().millisecondsSinceEpoch),selector,
                 new LatLng(-12, -78));

  SimulationView.original(String selector):
  this._internal(()=>new SimulationPresentation.original(new DateTime.now().millisecondsSinceEpoch),selector,
                 new LatLng(36.649350, 12.582516));

  /**
   * creates the map, the views for agents and place them on the map
   */
  buildView() {
    //create a div element for the control bar
    DivElement controlContainer = new DivElement();
    container.append(controlContainer);
    control = new ControlBar(controlContainer, presentation, simulationName,reset);


    DivElement mapContainer = new DivElement();
    MapOptions mapOptions = new MapOptions()
      ..zoom = 7
      ..scaleControl = false
      ..zoomControl = false
      ..streetViewControl = false
      ..mapTypeId = MapTypeId.HYBRID
    ;
    map = new MouseTrackingMap(mapContainer, mapOptions);
    container.append(new BRElement());
    container.append(mapContainer);
    mapContainer.style.height = "360px";
    mapContainer.style.width = "640px";
    mapContainer.dispatchEvent(new Event("resize"));
    //so the dispatch event is necessary to avoid ugly grey areas when resetting
    map.center = mapCenter;

    //fishery views
    int i = 0;
    for (FisheryPresentation fishery in presentation.fisheries.values)
    {
      FisheryView view = new FisheryView(fishery, defaultColors[i]);
      fisheries.add(view);
      print(defaultColors[i]);
      i++;
      //add the view to the map as well
      view.addToMap(map);
    }
    //fishermen markers
    if (presentation.fishermen != null)
      fishermen = new FishermenView(presentation.fishermen, map);
  }

  SimulationView._internal(this.factory, String selector, this.mapCenter)
  :
  simulationName = selector.substring(1)
  {
    visualRefresh = true;
    presentation = factory();


    //main container is the only thing that survives a reset!
    container = querySelector(selector);
    container.style.width = "700px";
    container.style.marginLeft = "auto";
    container.style.marginRight = "auto";




    buildView();


  }

  /**
   * kill views, create new presentation
   */
  void reset()
  {
    for(FisheryView f in fisheries)
      f.kill();
    fisheries.clear();
    if(fishermen != null)
      fishermen.kill();
    fishermen = null;

    control.kill();
    control = null;

    map.kill();
    map = null;

    //kill the visuals
    for(Element e in container.children)
      e.remove();

    //now rebuild
    presentation = factory();
    buildView();


  }

  void step()=>presentation.step();

}