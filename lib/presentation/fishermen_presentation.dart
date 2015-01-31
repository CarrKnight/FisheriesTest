/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of presentation;


/*this is organized as follows:
the fishermEn presentation object holds the location-map of all fishermen and
streams to view the location updates.
It also holds a map of fishermAn presentation. These are used to stream
personal data of a single fisherman to view. Usually for tooltip reasons
*/


class FishermenMovementEvent
{
  /**
   * a list of all the fishermen who moved last day.
   */
  final HashMap<Fisherman, Point> movements;

  FishermenMovementEvent(this.movements);


}

class FishermenDataEvent
{
  final double dailyCatch;

  FishermenDataEvent(this.dailyCatch);


}

class FishermanEvent
{
  final double dailyCatch;

  final String fishery;

  final double ability;

  FishermanEvent(this.dailyCatch, this.fishery, this.ability);

}


class FishermenPresentation
{

  /**
   * the list of every fisherman to his location.
   */
  final HashMap<Fisherman,Point> locations = new HashMap();

  /**
   * a reference to the list of all fishermen
   */
  final List<Fisherman> roster;

  final HashMap<Fisherman,Point> _updates = new HashMap();

  final HashMap<Fisherman,Fishery> _modelLocation = new HashMap();

  /**
   * randomizer, from simulation hopefully
   */
  final Random random;

  StreamController<FishermenMovementEvent> _movementStreamer = new StreamController();
  StreamController<FishermenDataEvent> _dataStreamer = new StreamController();


  double _totalCatch;

  /**
   * a link to the roster is all we need
   */
  relocate(Fisherman fisherman) {
    Point place = fisherman.location == Fisherman.AT_PORT ?
                  fisherman.port.jitterLocation(random) :
                  fisherman.location.randomPointInBetween(random);
    locations[fisherman] = place;
    //keep track of updates only if you are listened to
    if(_movementStreamer.hasListener)
      _updates[fisherman]=place;
    //remember its model location
    _modelLocation[fisherman] = fisherman.location;


  }

  FishermenPresentation(this.roster,this.random)
  {
    //populate maps!
    for(Fisherman fisherman in roster)
    {
      relocate(fisherman);
    }
    //make sure we populated it correctly
    assert(_modelLocation.length==locations.length);
    assert(roster.length==locations.length);
  }


  present()
  {

    _totalCatch = 0.0;
    _updates.clear();
    //check for movements
    for(Fisherman fisherman in roster)
    {

      Fishery location = fisherman.location;
      //if you moved, notice it
      if(_modelLocation[fisherman] != location)
        relocate(fisherman);

      _totalCatch += fisherman.dailyCatch;
    }

    //stream
    if(_movementStreamer.hasListener)
    {
      FishermenMovementEvent e = new FishermenMovementEvent(new HashMap.from(_updates));
      _movementStreamer.add(e);
    }
    if(_dataStreamer.hasListener)
    {
      FishermenDataEvent e = new FishermenDataEvent(totalCatch);
      _dataStreamer.add(e);
    }



  }


  double get  totalCatch => _totalCatch;

  Stream<FishermenMovementEvent> get movementStream => _movementStreamer.stream;




}