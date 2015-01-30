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
   * place fishing in this turn. If null the fisherman is at port
   */
  Fishery location = null;

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

    //go through all fisheries, choose the one that is most profitable
    location=null;
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
    if(location != null) {
      double bio = location.fishHere(ability);
      //update expected bio
      expectedBio[location] = bio;

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


  static const double JITTER_VARIANCE = .001;


  //todo move this in presentation
  /**
   * just a helper to get random location around the  port
   */
  Point jitterLocation(Random random)=>new Point(
      location.x+random.nextDouble()*JITTER_VARIANCE,
      location.y+random.nextDouble()*JITTER_VARIANCE);


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
