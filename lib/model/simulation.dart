
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
   * to show how fisheries grow
   */
  factory Simulation.oneLonelyFishery(int seed)
  {
//

    Fishery hawaii = new Fishery([ //center (37.52998825,11.96250725)
                                       new Point(20.0, -158.0),
                                       new Point(20.0, -157.0),
                                       new Point(19.0, -157.0),
                                       new Point(19.0, -158.0)]);
    hawaii.bioMass=100.0;
    hawaii.maxCapacity=1000.0;
    hawaii.name = "Fishery";

    Simulation sim = new Simulation._internal(seed);
    sim.fisheries.add(hawaii);

    return sim;


  }


  /**
   * two fisheries, fishermen wise up and go to the best one
   */
  factory Simulation.chooseRichest(int seed,[int fishermen=25])
  {
//

    Fishery north = new Fishery([ //-11.781268, -77.289216
                                       new Point(-11.072754, -79.173688),
                                       new Point(-10.572754, -78.673688),
                                       new Point(-10.072754, -79.173688),
                                       new Point(-10.572754, -79.573688)]);
    //starts full
    north.bioMass=1000.0;
    north.maxCapacity=1000.0;
    north.name = "Lima North";
    Fishery south = new Fishery([ //-11.781268, -77.289216
                                       new Point(-14.072754, -79.173688),
                                       new Point(-13.572754, -78.673688),
                                       new Point(-13.072754, -79.173688),
                                       new Point(-13.572754, -79.573688)]);
    //starts full
    south.bioMass=10.0;
    south.maxCapacity=10.0;
    south.name = "Lima south";

    Simulation sim = new Simulation._internal(seed);
    sim.fisheries.add(north);
    sim.fisheries.add(south);

    Port lima = new Port({north:0.0,south:0.0},-12.072754, -77.173688);

    for(int i=0; i<fishermen;i++)
    {
      sim.fishermen.add(new Fisherman(lima,sim.random.nextDouble()/180.0,
                                      sim.random,1.0,2.0));
    }

    //no costs
    sim.costs = new GlobalCosts(1.0,0.0,{north:0.0,south:0.0});

    return sim;


  }


  /**
   * two fisheries, one is richer but farther. change oil prices to see the difference
   */
  factory Simulation.gasPolicy(int seed,{int fishermen:25,double oilCosts:0.5} )
  {

//42,-87.5
    Fishery close = new Fishery([ //-11.781268, -77.289216
                                    new Point(42,-87.0),
                                    new Point(42,-87.5),
                                    new Point(42.5,-87.5),
                                    new Point(42.5,-87.0)]);
    //poor but close
    close.bioMass=1000.0;
    close.maxCapacity=1000.0;
    close.name = "South Lake Michigan";

    Fishery far = new Fishery([ //-11.781268, -77.289216
                                  new Point(44,-87.0),
                                  new Point(44,-87.5),
                                  new Point(44.5,-87.5),
                                  new Point(44.5,-87.0)]);
    //rich but far
    far.bioMass=2000.0;
    far.maxCapacity=2000.0;
    far.name = "North Lake Michigan";


    Simulation sim = new Simulation._internal(seed);
    sim.fisheries.add(far);
    sim.fisheries.add(close);


    Port chicago = new Port({close:52.0,far:260.0},41.879847, -87.593503);

    for(int i=0; i<fishermen;i++)
    {
      sim.fishermen.add(new Fisherman(chicago,sim.random.nextDouble()/180.0,
                                      sim.random,1.0,2.0));
    }

    //no costs
    sim.costs = new GlobalCosts(100.0,oilCosts,{close:0.0,far:0.0});

    return sim;



  }




  /**
   * Showing how fishermen exhaust the fishery
   */
  factory Simulation.overfishing(int seed,[int fishermen=25])
  {
//

    Fishery jFishery = new Fishery([ //center (37.52998825,11.96250725)
                                     new Point(32.5, 139.5),
                                     new Point(33.0, 140.0),
                                     new Point(33.5, 139.5),
                                     new Point(33.0, 139.0)]);
    //starts full
    jFishery.bioMass=1000.0;
    jFishery.maxCapacity=1000.0;
    jFishery.name = "Izu Islands";

    Simulation sim = new Simulation._internal(seed);
    sim.fisheries.add(jFishery);

    Port tokyo = new Port({jFishery:0.0},35.314133, 139.393694);

    for(int i=0; i<fishermen;i++)
    {
      sim.fishermen.add(new Fisherman(tokyo,sim.random.nextDouble()/200.0,
                                      sim.random,1.0,2.0));
    }

    //no costs
    sim.costs = new GlobalCosts(1.0,0.0,{jFishery:0.0});

    return sim;


  }


  /**
   * builds the 4 fisheries scenario
   */
  factory Simulation.original(int seed,[int fishermen=100])
  {

    Fishery fishery1 = new Fishery([ //center (37.52998825,11.96250725)
                                       new Point(37.548665, 12.248152),
                                       new Point(37.718324, 11.880110),
                                       new Point( 37.570438, 11.665876),
                                       new Point(37.282526, 12.055891)]);
    fishery1.bioMass=800.0;
    fishery1.maxCapacity=4000.0;
    fishery1.name = "Marsala";

    Fishery fishery2 = new Fishery([ //center (36.803354,12.35252175)
                                       new Point(36.989121, 12.418440),
                                       new Point(36.874957, 12.127302),
                                       new Point( 36.557917, 12.341535),
                                       new Point(36.791421, 12.522810)]);
    fishery2.bioMass=800.0;
    fishery2.maxCapacity=800.0;
    fishery2.name = "Pantelleria";



    Fishery fishery3 = new Fishery([ //center (36.673479,13.4415415)
                                       new Point(36.918886, 13.533552),
                                       new Point(36.681366, 13.830183),
                                       new Point( 36.456365, 13.374250),
                                       new Point(36.637299, 13.028181)]);
    fishery3.bioMass=100.0;
    fishery3.maxCapacity=1000.0;
    fishery3.name = "Agrigento";


    Fishery fishery4 = new Fishery([ //center (35.93753425,12.9279305)
                                       new Point(36.164216, 12.995222),
                                       new Point(35.893227, 13.247907),
                                       new Point( 35.697182, 12.890852),
                                       new Point(35.995512, 12.577741)]);
    fishery4.bioMass=100.0;
    fishery4.maxCapacity=1000.0;
    fishery4.name = "Lampedusa";

    Simulation sim = new Simulation._internal(seed);
    sim.fisheries.add(fishery1);
    sim.fisheries.add(fishery2);
    sim.fisheries.add(fishery3);
    sim.fisheries.add(fishery4);


    //Mazara del Vallo
    //fishery1--> 56km
    //fishery2--> 96km
    //fishery3--> 132km
    //fishery4--> 193km
    Port port = new Port({fishery1:56.0,fishery2:96.0,fishery3:132.0,fishery4:193.0},
                         37.649350, 12.582516);
    sim.ports.add(port);
    //port (37.649350, 12.582516)
    for(int i=0; i<fishermen;i++)
    {
      sim.fishermen.add(new Fisherman(port,sim.random.nextDouble()/200.0,
                                      sim.random,1.0,2.0));
    }
    sim.costs = new GlobalCosts(1.0,0.0,{fishery1:0.0,fishery2:0.0,fishery3:0.0,fishery4:0.0});



    return sim;


  }

  /**
   * doesn't populate anything, just call scheduleAgents()
   */
  Simulation._internal(int seed):
  random = new Random(seed);

  /**
   * tell the agents when to act. This is basically the "start" method and needs to be called from the outside
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
    if(fishermen.length==0)
      return;

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