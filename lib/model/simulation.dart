
/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of model;

/*

The container of everything that goes on in the model. Basically a schedule + lists of agents + randomizer

 */


class Simulation
{


  final Schedule schedule = new Schedule();

  final List<Fishery> fisheries = new List();

  final List<Fisherman> fishermen = new List();

  final List<Port> ports = new List();

  GlobalCosts costs;

  final Random random;

  static const ANNEALING_PROBABILITY = .01;




  /**
   * builds the 4 fisheries scenario
   */
  factory Simulation.original(int seed,[int fishermen=100])
  {

    Fishery fishery1 = new Fishery([
                                       new Point(37.548665, 12.248152),
                                       new Point(37.718324, 11.880110),
                                       new Point( 37.570438, 11.665876),
                                       new Point(37.282526, 12.055891)]);
    fishery1.bioMass=60.0;
    fishery1.maxCapacity=100.0;
    fishery1.name = "one";

    Fishery fishery2 = new Fishery([
                                       new Point(36.989121, 12.418440),
                                       new Point(36.874957, 12.127302),
                                       new Point( 36.557917, 12.341535),
                                       new Point(36.791421, 12.522810)]);
    fishery2.bioMass=80.0;
    fishery2.maxCapacity=80.0;
    fishery2.name = "two";



    Fishery fishery3 = new Fishery([
                                       new Point(36.918886, 13.533552),
                                       new Point(36.681366, 13.830183),
                                       new Point( 36.456365, 13.374250),
                                       new Point(36.637299, 13.028181)]);
    fishery3.bioMass=10.0;
    fishery3.maxCapacity=400.0;
    fishery3.name = "three";


    Fishery fishery4 = new Fishery([
                                       new Point(36.164216, 12.995222),
                                       new Point(35.893227, 13.247907),
                                       new Point( 35.697182, 12.890852),
                                       new Point(35.995512, 12.577741)]);
    fishery4.bioMass=10.0;
    fishery4.maxCapacity=100.0;
    fishery4.name = "four";

    Simulation sim = new Simulation._internal(seed);
    sim.fisheries.add(fishery1);
    sim.fisheries.add(fishery2);
    sim.fisheries.add(fishery3);
    sim.fisheries.add(fishery4);


    return sim;


  }

  /**
   * doesn't populate anything, just call scheduleAgents()
   */
  Simulation._internal(int seed):
  random = new Random(seed);

  /**
   * tell the agents when to act
   */
  scheduleAgents(){
    //schedule all the fisheries to replenish daily
    for(Fishery fishery in fisheries) {
      //reset counters in the morning
      schedule.scheduleRepeating(Phase.DAWN, (s)=> fishery.resetCounters());
      //update biomass in the evening
      schedule.scheduleRepeating(
          Phase.REPLENISHING, (s) => fishery.updateBioMass(
          ));
    }

    //schedule all fishermen to choose where to fish
    for(Fisherman fisherman in fishermen)
    {
      schedule.scheduleRepeating(Phase.FISHING,(s)=>
      fisherman.chooseFishery(costs,random, ANNEALING_PROBABILITY));
    }


    //little bit of information spreading
    schedule.scheduleRepeating(Phase.GOSSIPING,(s)=>propagateInformation());


  }


  /**
   * each fisherman tells his neighbor in the [fishermen] list about the biomass it found
   */
  propagateInformation()
  {
    for(int i=1; i<fishermen.length;i++)
    {
      Fisherman talker = fishermen.elementAt(i);
      //if the talker has been somewhere
      if (talker.location != null)
      {
        //then the listener will learn the correct biome
        Fisherman listener = fishermen.elementAt(i - 1);
        listener.expectedBio[talker.location]=talker.location.bioMass;
      }
    }

    //do it once more for the first and last, closing the circle
    Fisherman talker = fishermen.first;
    if (talker.location != null)
    {
      //then the listener will learn the correct biome
      Fisherman listener = fishermen.last;
      listener.expectedBio[talker.location]=talker.location.bioMass;
    }

  }




}