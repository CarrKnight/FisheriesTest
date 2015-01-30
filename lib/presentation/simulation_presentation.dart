
/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of presentation;

/**
 * the root presentation, holding and streaming the simulation itself
 */
class SimulationPresentation
{

  /**
   * simulation object
   */
  final Simulation simulation;

  final Map<Fishery,FisheryPresentation> fisheries = new Map();

  final StreamController<SimulationEvent> streamer = new StreamController();


  SimulationPresentation._internal(this.simulation) {

    //schedule the simulation
    simulation.scheduleAgents();

    //create the presentations for fisheries
    for(Fishery fishery in simulation.fisheries)
    {
      FisheryPresentation presentation  = new FisheryPresentation(fishery);
      fisheries[fishery] =  presentation;

      //schedule the presentations to stream
      simulation.schedule.scheduleRepeating(Phase.GUI,(s)=>presentation.endOfDay());

    }

    //now schedule the general stream
    simulation.schedule.scheduleRepeating(Phase.GUI,endOfDay);




  }


  /**
   * creates the usual 4 fisheries scenario to present
   */
  SimulationPresentation.original(int seed,[int fishermen=100]):
  this._internal(new Simulation.original(seed,fishermen));


  /**
   * Fishermen go to the richest
   */
  SimulationPresentation.chooseRichest(int seed,[int fishermen=25]):
  this._internal(new Simulation.chooseRichest(seed,fishermen));

  /**
   *  Oil price policy
   */
  SimulationPresentation.gasPolicy(int seed,
                                   {int fishermen:25, double oilCost:2.0}):
  this._internal(new Simulation.gasPolicy(seed,fishermen:fishermen,oilCosts:oilCost));

  /**
   * one fishery, untouched
   */
  SimulationPresentation.oneLonelyFishery(int seed):
  this._internal(new Simulation.oneLonelyFishery(seed));

  /**
   * one fishery, overfished
   */
  SimulationPresentation.overfished(int seed):
  this._internal(new Simulation.overfishing(seed));

  /**
   * stream bio masses, if listened to
   */
  void endOfDay(Schedule s)
  {

    if(!streamer.hasListener)
      return;

    int day = s.day;
    Map<Fishery,double> bioMasses = new Map();
    for(Fishery fishery in fisheries.keys)
    {
      bioMasses[fishery] = fishery.bioMass;
    }

    streamer.add(new SimulationEvent(day,bioMasses));
  }


  Stream<SimulationEvent> get stream => streamer.stream;


  /**
   * step one day
   */
  void step(){
    simulation.schedule.simulateDay();
  }

}


/**
 * an event object to stream: so far just a map of fisheries to their current biomass
 */
class SimulationEvent
{

  final int day;

  final Map<Fishery,double> bioMasses;

  SimulationEvent(this.day, this.bioMasses);


}