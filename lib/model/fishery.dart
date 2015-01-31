/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of model;
class Fishery
{



  final List<Point<double>> path;

  Fishery(this.path);

  String name = "fishery";

  double maxCapacity = 100.0;

  double growthRate = 0.05;

  double bioMass = 50.0;

  double get bioMassRatio =>    bioMass/maxCapacity;

  /**
   * how much of the biomass is to be fished out today
   */
  double bioMassFished = 0.0;

  /**
   * inner variable to store what the biomass will be after everything is fished out
   */
  double _biomassToBeFished = 0.0;

  int fishermenHere =0;

  /***
   * simple info growth - fished
   */
  double netBiomassChange = 0.0;


  //todo move this in presentation:
  /**
   * this is very far from accurate, just need a point that may or may not be in there though
   */
  Point<double> randomPointInBetween(Random random){

    //x
    int dimensions = path.length;
    double alpha = random.nextDouble();
    double x = path[random.nextInt(dimensions)].x * alpha + path[random.nextInt(dimensions)].x *(1-alpha) ;

    alpha = random.nextDouble();
    double y = path[random.nextInt(dimensions)].y* alpha + path[random.nextInt(dimensions)].y *(1-alpha) ;

    return new Point(x,y);
  }


  void resetCounters()
  {

    fishermenHere = 0;
    bioMassFished = 0.0;
    netBiomassChange = 0.0;
  }

  /**
   * first compute the effect of fishing on the biomass, then
   * grow a bit the biomass
   */
  void updateBioMass()
  {
    double oldBioMass = bioMass;
    bioMass -= _biomassToBeFished;

    bioMassFished = _biomassToBeFished;
    _biomassToBeFished = 0.0;



    //here I just use the logistic-growth hypothesis by Soulie' and Thebaud(2005)
    double adjustedGrowthRate = 1.0 + growthRate *(1.0-bioMassRatio);
    bioMass = min(maxCapacity,adjustedGrowthRate*bioMass);

    if(bioMass<.005)
      bioMass=0.0;

    netBiomassChange += bioMass - oldBioMass;
  }


  /**
   * a fisherman comes to fish here. The effect are not computed till the end of the day.
   * the function returns current biomass.
   */
  double fishHere(double fishermanAbility)
  {
    fishermenHere++;
    _biomassToBeFished += fishermanAbility * bioMass;
    return  bioMass;

  }



}


