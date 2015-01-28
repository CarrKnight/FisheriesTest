/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of presentation;



/**
 * connector between the model object and the view. Streams info
 */
class FisheryPresentation
{

  /**
   * the object we are presenting
   */
  final Fishery fishery;

  /**
   * the streamer that we fire every day
   */
  final StreamController<FisheryEvent> streamer = new StreamController();




  /**
   * when notified that the day is over, the presentation streams the fishery status. But only if somebody is listening
   */
  FisheryPresentation(this.fishery);

  void endOfDay(){

    if(streamer.hasListener)
      streamer.add(new FisheryEvent(fishery.maxCapacity,fishery.bioMass));
  }


  List<Point> get path => fishery.path;


  Stream<FisheryEvent> get stream => streamer.stream;

  double get bioMassRatio => fishery.bioMassRatio;
  double get bioMass => fishery.bioMass;
  double get maxCapacity => fishery.maxCapacity;
  String get name => fishery.name;


}


/**
 * streamed by fishery presentation
 */
class FisheryEvent
{

  final double maxCapacity;

  final double bioMass;


  FisheryEvent(this.maxCapacity, this.bioMass);


  double get bioMassRatio => bioMass/maxCapacity;

}