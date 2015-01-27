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
   * this is very far from accurate, just need a point that may or may not be in there though
   */
  Point<double> randomPointInBetween(Random random){

    //x
    int dimensions = path.length;
    double alpha = random.nextDouble();
    double x = path[random.nextInt(dimensions)].x * alpha + path[random.nextInt(dimensions)].x *(1-alpha) ;
    x/=2;

    alpha = random.nextDouble();
    double y = path[random.nextInt(dimensions)].y* alpha + path[random.nextInt(dimensions)].y *(1-alpha) ;
    y/=2;

    return new Point(x,y);
  }

  /**
   * grow a bit the biomass
   */
  void replenish()
  {

    //here I just use the logistic-growth hypothesis by Soulie' and Thebaud
    double adjustedGrowthRate = 1.0 + growthRate *(1.0-bioMassRatio);
    bioMass = min(maxCapacity,adjustedGrowthRate*bioMass);

  }


}