/*
 * This code is open-source, MIT license. See the LICENSE file
 */
part of view;


/**
 * A map of markers to positions
 */
class FishermenView
{


  /**
   * the fishermen and their markers
   */
  final Map<Fisherman,Marker> fishermen = new HashMap();


  final FishermenPresentation presentation;

  final MouseTrackingMap map;


  StreamSubscription subscription;




  FishermenView(this.presentation, this.map) {

    print("view built!");


    GSymbol icon = new GSymbol();
    //grabbed from flaticon
    icon.path = '''
    M426.332,346.654l-338.86-19.263c-6.803-0.386-9.647,4.16-6.307,10.104l49.885,88.923
		c3.334,5.943,11.645,10.808,18.461,10.808h256.13c6.816,0,13.643-5.435,15.171-12.085l15.117-65.699
		C437.455,352.796,433.139,347.045,426.332,346.654z
		M117.688,314.262c0,0,145.926,8.623,146.353,8.564c4.753,0,8.604-3.852,8.604-8.603V93.712
		c0-4.751-3.852-8.603-8.604-8.603c-4.191,0-57.61,43.541-112.438,129.847C107.52,284.349,95.987,312.002,117.688,314.262z
		M291.682,324.066c2.023,0.124,112.63,6.51,112.63,6.51c7.732,0.438,10.641-4.538,6.466-11.06L299.541,133.064
		c0,0-3.926-7.857-8.746-7.857c-4.337,0-6.968,3.519-6.968,7.857c0,0,0,137.413,0,183.217
		C283.827,320.547,287.354,323.801,291.682,324.066z
    ''';
    icon.fillColor="white";
    icon.fillOpacity=1.0;
    icon.strokeColor="black";
    icon.strokeWeight=1.0;
    icon.scale = .05;


    //populate marker list
    presentation.locations.forEach((f,l)
                                   {


                                     MarkerOptions options = new MarkerOptions()
                                       ..map=map
                                       ..draggable=false
                                       ..icon = icon
                                       ..position=new LatLng(l.x,l.y);
                                     var marker = new Marker(options);
                                     fishermen[f]= marker;
                                   });
    //listen to changes
    subscription= presentation.movementStream.listen(
            (e)=>updatePositions(e.movements));





  }



  updatePositions(Map<Fisherman,MATH.Point> movements)
  {
    movements.forEach((f,l)
                      {
                        Marker marker = fishermen[f];
                        marker.position=new LatLng(l.x,l.y);
                      });


  }



  kill()
  {
    subscription.cancel();
  }

}



