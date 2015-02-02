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


    //populate marker list
    presentation.locations.forEach((f,l)
                                   {
                                     MarkerOptions options = new MarkerOptions()
                                       ..map=map
                                       ..draggable=false
                                       ..position=new LatLng(l.x,l.y);
                                     fishermen[f]=new Marker(options);
                                   });
    //listen to changes
    subscription= presentation.movementStream.listen(
            (e)=>updatePositions(e.movements));





  }



  updatePositions(Map<Fisherman,MATH.Point> movements)
  {
    movements.forEach((f,l)
                      {
                        fishermen[f].position=new LatLng(l.x,l.y);
                      });


  }


  kill()
  {
    subscription.cancel();
  }

}



