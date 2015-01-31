/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of model;

/**
 * the one who fishes
 */
class Fisherman
{

  /**
   * just a marker for fishermen to say they are in port
   */
  static final  Fishery AT_PORT = new Fishery(null);


  /**
   * place fishing in this turn. If null the fisherman is at port
   */
  Fishery location = AT_PORT;

  /**
   * fisherman expected bio-masses for each possible fishery
   */
  final Map<Fishery,double> expectedBio = new HashMap();

  /**
   * homebase of the fisherman
   */
  final Port port;

  /**
   * the percentage of biomass fished each day by this fisherman
   */
  final double ability;

  double dailyCatch =0.0;

  Fisherman(this.port, this.ability, Random random, double minExpectedBio, double maxExpectedBio)
  {
    //populate at random the expected bios
    for(Fishery fishery in port.distances.keys)
    {
      expectedBio[fishery]= random.nextDouble()*(maxExpectedBio-minExpectedBio) + minExpectedBio;
    }
  }


  /**
   * select the most profitable fishery (or randomly mistep with given probability)
   */
  void chooseFishery(GlobalCosts costs, Random random, double errorProbability)
  {
    dailyCatch =0.0;

    //go through all fisheries, choose the one that is most profitable
    location=AT_PORT;
    double bestPi=0.0;
    List<Fishery> choices = new List.from(distances.keys);
    choices.shuffle(random);
    choices.forEach((fishery){
      double expectedPi = _expectedProfits(
          costs.bioMassPrice,expectedBio[fishery],costs.oilPricePerKm,
          distances[fishery],costs.tariffs[fishery]);
      if(expectedPi>bestPi || random.nextDouble() < errorProbability)
      {
        bestPi = expectedPi;
        location = fishery;
      }

    });

    //if you have chosen one, fish from it
    if(location != AT_PORT) {
      double bio = location.fishHere(ability);
      //update expected bio
      expectedBio[location] = bio;
      //strictly speaking the fishing doesn't occur till later but there is no error now so we can just count it
      dailyCatch = bio*ability;
    }

    //done!


  }


  double _expectedProfits(double price, double expectedBio, double oilPrice, double distance, double tariff)=>
  price*ability*expectedBio-oilPrice*distance-tariff;

  Map<Fishery,double> get distances => port.distances;


}


/**
 * Coordinates of where "home" is.
 */
class Port
{


  final Point location;

  /**
   * stores the fisheries the agent from this port can fish into
   */
  final Map<Fishery,double> distances;


  Port(this.distances,double x, double y)
  :
  location = new Point(x,y);


  static const double DEFAULT_JITTER_VARIANCE = .01;

  double jitterVariance = DEFAULT_JITTER_VARIANCE;


  //todo move this in presentation
  /**
   * just a helper to get random location around the  port
   */
  Point jitterLocation(Random random)=>new Point(
      location.x+random.nextDouble()*jitterVariance,
      location.y+random.nextDouble()*jitterVariance);


}


/**
 * this is an object to coordinate and centralize oil costs and fishery-specific costs without having to keep separate
 * copies for each fisherman. It also holds the biomass price
 */
class GlobalCosts
{

  double bioMassPrice;

  double oilPricePerKm;

  final Map<Fishery, double> tariffs;

  GlobalCosts(
      this.bioMassPrice, this.oilPricePerKm, this.tariffs);



}
