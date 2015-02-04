/*
 * This code is open-source, MIT license. See the LICENSE file
 */
part of policy;




/**
 * a policy is anything applied every day to the simulation object. Extends Phenotype to deal with
 * maximization/GA
 */
abstract class Policy extends Phenotype<double>
{

  void simulationStart(Simulation sim);

  void apply(Simulation sim);


}


/**
 * forces oil price to be the same always
 */
class FixedOilPrice extends Policy
{



  double get oilPrice => genes[0];


  FixedOilPrice(){}

  FixedOilPrice.random(Random random){
    genes = new List<double>(1);
    for (int i = 0; i < 1; i++) {
      genes[i] = random.nextDouble()*(5.0); //from 0 to 5
    }

  }


  double mutateGene(double gene, num strength) {
    return max(0.0,gene - strength/10.0);
  }

  void simulationStart(Simulation sim)
  {
    sim.costs.oilPricePerKm = oilPrice;

  }

  void apply(Simulation sim) {
    sim.costs.oilPricePerKm = oilPrice;
  }



}



/**
 * oil prices have two levels, one set when biomass is below a critical level and one set when it goes back above an acceptable level
 */
class TwoStepOilPrice extends Policy
{

  double get oilPriceAcceptable => genes[0];

  double get oilPriceCritical => genes[1];

  double get criticalThreshold => genes[2];

  double get acceptableThreshold => genes[3];

  bool critical = false;

  final Random random;

  TwoStepOilPrice(this.random);


  TwoStepOilPrice.Random(this.random) {
    genes = new List<double>(4);
    for (int i = 0; i < 2; i++) {
      genes[i] = random.nextDouble()*(5.0); //from 0 to 5
    }
    genes[2] = random.nextDouble()*(8000.0);
    genes[3] = max(genes[2],random.nextDouble()*(8000.0));

  }


  double mutateGene(double gene, num strength) {
    if(random.nextBool())
      return max(0.0, gene + strength * gene * random.nextDouble()/10.0 );
    else
      return max(0.0, gene - strength * gene * random.nextDouble()/10.0 );

  }

  updateFlag( double biomeLeft)
  {
    if(critical)
    {
      if (biomeLeft > acceptableThreshold)
        critical = false;
    }
    else
    {
      if (biomeLeft < criticalThreshold)
        critical = true;
    }
  }


  void simulationStart(Simulation sim)
  {
    apply(sim);


  }

  void apply(Simulation sim) {
    updateFlag(sim.biomeLeft());
    if(critical)
      sim.costs.oilPricePerKm = oilPriceCritical;
    else
      sim.costs.oilPricePerKm = oilPriceAcceptable;

  }

  num computeHammingDistance(Phenotype<double> other) {
    int length = genes.length;
    int similarCount = 0;

    for (int i = 0; i < genes.length; i++) {
      //1% distant
      if ( (genes[i] - other.genes[i]).abs() < .01 * genes[i] ) {
        similarCount++;
      }
    }
    return (1 - similarCount / length);
  }


}

