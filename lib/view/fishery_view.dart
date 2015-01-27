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
    //start listening
    presentation.stream.listen((e)=>reactToStream(e));
  }


  /***
   * adjust opacity
   */
  void reactToStream(FisheryEvent e)
  {
    polygon.set("fillOpacity",e.bioMassRatio * MAX_OPACITY);

  }

  /**
   * the map itself
   */
  void addToMap(GMap map)
  {
    polygon.map =  map;
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
}