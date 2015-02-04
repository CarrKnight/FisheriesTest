/*
 * This code is open-source, MIT license. See the LICENSE file
 */

import 'package:mapspike/model/model.dart';
import 'package:mapspike/policy/policy.dart';
import 'package:darwin/darwin.dart';
import 'dart:math';
import 'dart:async';

bestTwoPrice()
{

  //create the randomizer
  Random random = new Random(new DateTime.now().millisecondsSinceEpoch);

  //create first generation, at random
  Generation<TwoStepOilPrice> firstGeneration = new Generation();
  while (firstGeneration.members.length < 30)
  {
    var member = new TwoStepOilPrice.Random(random);
    firstGeneration.members.add(member);

  }

  //create the evaluator (defined below)
  PhenotypeEvaluator eval = new XRunsAverageCatch(random);

  //create the breeder, use the default one
  GenerationBreeder breeder = new GenerationBreeder(()=>new TwoStepOilPrice(random));
  breeder.elitismCount = 1;
  breeder.crossoverPropability = 0.80;


  GeneticAlgorithm algorithm = new GeneticAlgorithm(firstGeneration,eval,breeder);
  //10 generations max
  algorithm.MAX_EXPERIMENTS=100 * 10;



  algorithm.runUntilDone().then((_) {
    // Print all members of the last generation when done.
    algorithm.generations.last.members
    .forEach((Phenotype ph) => print("${ph.genesAsString}"));
  });;



}



bestPIDPrice()
{

  //create the randomizer
  Random random = new Random(new DateTime.now().millisecondsSinceEpoch);

  //create first generation, at random
  Generation<PIDPolicy> firstGeneration = new Generation();
  while (firstGeneration.members.length < 30)
  {
    var member = new PIDPolicy.Random(random);
    firstGeneration.members.add(member);

  }

  //create the evaluator (defined below)
  PhenotypeEvaluator eval = new XRunsAverageCatch(random);

  //create the breeder, use the default one
  GenerationBreeder breeder = new GenerationBreeder(()=>new PIDPolicy(random));
  breeder.elitismCount = 2;
  breeder.crossoverPropability = 0.90;


  GeneticAlgorithm algorithm = new GeneticAlgorithm(firstGeneration,eval,breeder);
  //30 generations max
  algorithm.MAX_EXPERIMENTS=30 * 30;



  algorithm.runUntilDone().then((_) {
    // Print all members of the last generation when done.
    algorithm.generations.last.members
    .forEach((Phenotype ph) => print("${ph.genesAsString}"));
  });;



}

bestPIDTariff()
{

  //create the randomizer
  Random random = new Random(new DateTime.now().millisecondsSinceEpoch);

  //create first generation, at random
  Generation<PIDWithTariff> firstGeneration = new Generation();
  while (firstGeneration.members.length < 30)
  {
    var member = new PIDWithTariff.Random(random);
    firstGeneration.members.add(member);

  }

  //create the evaluator (defined below)
  PhenotypeEvaluator eval = new XRuns(random);

  //create the breeder, use the default one
  GenerationBreeder breeder = new GenerationBreeder(()=>new PIDWithTariff(random));
  breeder.elitismCount = 2;
  breeder.crossoverPropability = 0.90;


  GeneticAlgorithm algorithm = new GeneticAlgorithm(firstGeneration,eval,breeder);
  //30 generations max
  algorithm.MAX_EXPERIMENTS=30 * 30;



  algorithm.runUntilDone().then((_) {
    // Print all members of the last generation when done.
    algorithm.generations.last.members
    .forEach((Phenotype ph) => print("${ph.genesAsString}"));
  });;



}

bestOnePrice()
{


  XRuns eval = new XRuns(new Random(),10);
  //easy grid search
  for(double price =0.0; price<=5.0; price+=.01)
  {


    FixedOilPrice fixed = new FixedOilPrice();
    fixed.genes = [price];
    eval.evaluate(fixed).then((fitness)
                              {
                                print("price $price; fitness: $fitness");
                              });

  }

}

main()
{
//  bestTwoPrice();
 // bestPIDTariff();
  whichOneIsBest();
}


whichOneIsBest()
{
  Random random = new Random();
  TwoStepOilPrice best1 = new TwoStepOilPrice(random);
  best1.genes = [0.11,3.15,490.0,5681.0];

  PIDPolicy best2 = new PIDPolicy(random);
  best2.genes = [2119.0,0.007873836554991577,0.0017491613096196712];

  FixedOilPrice best3 = new FixedOilPrice();
  best3.genes= [0.17];

  FixedOilPrice noPolicy = new FixedOilPrice();
  noPolicy.genes= [0.00];

  TwoStepOilPrice test = new TwoStepOilPrice(random);
  test.genes= [0.17,0.17,1.0,1.0];

  PIDWithTariff tariff = new PIDWithTariff(random);
  tariff.genes= [2315.0,0.00613312560100617,0.0064407439755037555,659.0,0.008812253906658445,0.0069442501927040375];

  XRunsAverageCatch eval = new XRunsAverageCatch(new Random(),10);

  eval.evaluate(best1).then((fitness)
                            {
                              print("two step fitness: $fitness");
                            });
  eval.evaluate(best2).then((fitness)
                            {
                              print("pid fitness:$fitness");
                            });
  eval.evaluate(best3).then((fitness)
                            {
                              print("fixed fitness: $fitness");
                            });
  eval.evaluate(noPolicy).then((fitness)
                            {
                              print("no policy: $fitness");
                            });
  eval.evaluate(test).then((fitness)
                            {
                              print("test fitness: $fitness");
                            });
  eval.evaluate(tariff).then((fitness)
                            {
                              print("tariff fitness: $fitness");
                            });

}


class XRuns extends PhenotypeEvaluator<Policy>
{

  final Random random;


  final int runs;


  XRuns(this.random,[this.runs = 1]);

  Future<num> evaluate(Policy phenotype)
  {

    return new Future<num>((){
      double averageCatch = 0.0;
      for(int i=0; i<runs; i++)
      {

        Simulation sim = new Simulation.original(random.nextInt(10000));
        phenotype.simulationStart(sim);
        sim.scheduleAgents();

        for(int step =0; step<10000; step++)
        {
          sim.schedule.simulateDay();
          phenotype.apply(sim);
          averageCatch+= sim.totalDailyCatch();
        }

      }
      return 1000000 *  runs/(averageCatch); //lower fitness the better
    });

  }
}


class XRunsAverageCatch extends PhenotypeEvaluator<Policy>
{

  final Random random;


  final int runs;


  XRunsAverageCatch(this.random,[this.runs = 1]);

  Future<num> evaluate(Policy phenotype)
  {

    return new Future<num>((){
      double averageCatch = 0.0;
      for(int i=0; i<runs; i++)
      {

        Simulation sim = new Simulation.original(random.nextInt(10000));
        phenotype.simulationStart(sim);
        sim.scheduleAgents();

        for(int step =0; step<10000; step++)
        {
          sim.schedule.simulateDay();
          phenotype.apply(sim);
          averageCatch+= sim.totalDailyCatch();
        }

      }
      return averageCatch/(runs*10000); //lower fitness the better
    });

  }
}

//best pid: 2119.0,0.007873836554991577,0.0017491613096196712
//best two-pricer 0.1082237216944093,3.1523556761732823,4907.282923793729,5680.176279741764