/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of view;

/**
 *the view of the fishery. This is basically a google.map Polygon that listens to a stream to alter its opacity
 * over time
 */
class FisheryView
{


  final Polygon polygon;

  final FisheryPresentation presentation;

  static const  double MAX_OPACITY = 0.8;

  //I store this data here so they can be displayed by the tooltip without bothering the presentation
  double lastBioMass = double.NAN;

  double maxCapacity = double.NAN;

  String name = " ";

  FisheryTooltip tip;

  StreamSubscription subscription;

  factory FisheryView(FisheryPresentation presentation, String color)
  {


    //create basic options
    PolygonOptions initialOptions = new PolygonOptions();
    //the paths control the shape of the polygon. Need to turn the Point into latlang
    initialOptions.paths = transformToCoordinates(presentation.path);
    initialOptions.strokeColor= 'black';
    initialOptions.strokeWeight= 2;
    initialOptions.fillColor=color;
    initialOptions.fillOpacity= presentation.bioMassRatio * MAX_OPACITY;
    initialOptions.strokeOpacity= 0.8;
    Polygon polygon = new Polygon(initialOptions);




    return new FisheryView._internal(polygon,presentation);

  }

  /**
   * internal constructor, to deal with dart final weirdness
   */
  FisheryView._internal(this.polygon, this.presentation)
  {
    //grab initial data from fishery
    maxCapacity = presentation.maxCapacity;
    lastBioMass = presentation.bioMass;
    name = presentation.name;



    //start listening
    subscription=
    presentation.stream.listen((e)=>reactToStream(e));
  }


  /***
   * adjust opacity
   */
  void reactToStream(FisheryEvent e)
  {
    //update storage
    lastBioMass = e.bioMass;
    //fill opacity
    polygon.set("fillOpacity",e.bioMassRatio * MAX_OPACITY);

    if(tip!=null)
      tip.updateMessage();
  }

  /**
   * the map itself
   */
  void addToMap(MouseTrackingMap map)
  {
    polygon.map =  map;
    //prepare tooltip
    tip = new FisheryTooltip(map,this);

  }

  static List<LatLng> transformToCoordinates(List<MATH.Point> path)
  {
    List<LatLng> coordinates = new List();
    for(MATH.Point p in path)
    {
      coordinates.add(new LatLng(p.x,p.y));
    }

    return coordinates;
  }

  kill()
  {
    if(tip != null)
      tip.kill();
    subscription.cancel();
  }


}

/**
 * listens to mouseover events and create ugly tooltip for status report when needed
 */
class FisheryTooltip
{

  /**
   * need a link to the map  to turn lat-long into pixel position
   */
  final MouseTrackingMap map;

  /**
   * the map object
   */
  final FisheryView fisheryView;

  /**
   * the actual tooltip
   */
  DivElement tooltipElem;

  StreamSubscription mouseOver;
  StreamSubscription mouseOut;


  FisheryTooltip(this.map, this.fisheryView) {
    //start listening
    mouseOver =
    fisheryView.polygon.onMouseover.listen(_createTemplate);
    mouseOut =
    fisheryView.polygon.onMouseout.listen((e)=>_destroyTemplate());

  }

  void _createTemplate(PolyMouseEvent event)
  {

    //create the tooltip
    tooltipElem = new DivElement();
    //insert span element, this helps resizing
    //message
    updateMessage();
    //style
    tooltipElem
      ..style.display="block"
      ..style.whiteSpace="pre"
      ..style.color = "white"
      ..style.fontSize = "smaller"
      ..style.paddingBottom = "5px";
    //todo turn this into css

    tooltipElem.style
    //   ..padding = "5px"
      ..backgroundColor = "black"
      ..borderRadius = "5px";
    //todo turn this into css

    //get pixel position
    Point location = map.projection.fromLatLngToPoint(event.latLng);




    tooltipElem.style
      ..position = "absolute"
      ..top = "${map.mouseY - 20}px"
      ..left = "${map.mouseX + 20}px";


    //paste it in the document
    document.body.append(tooltipElem);


  }


  void _destroyTemplate()
  {

    tooltipElem.remove();
    tooltipElem = null;
  }

  /**
   * creates/overwrites the text of the tooltip
   */
  void updateMessage(){
    if(tooltipElem != null)
    {
      //create the message
      tooltipElem.children.clear();
      tooltipElem.append(new SpanElement()..text="${fisheryView.name}" ..style.fontSize="larger");
      UListElement list = new UListElement();
      double roundedBioMass = (fisheryView.lastBioMass * 100).round()/100.0;

      list.append(new LIElement()..text="Bio-Mass: ${roundedBioMass}");
      list.append(new LIElement()..text="Max capacity: ${fisheryView.maxCapacity}");
      //put it in the span
      tooltipElem.append(list);


    }
    //todo add span around numbers so they can be colored

  }

  kill()
  {
    if(tooltipElem != null)
      _destroyTemplate();
    mouseOver.cancel();
    mouseOut.cancel();
  }


}