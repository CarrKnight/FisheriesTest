/*
 * This code is open-source, MIT license. See the LICENSE file
 */
library acceptance.test;

import 'package:unittest/unittest.dart';
import 'package:mapspike/model/model.dart';
import 'dart:math';


main()
{

  //with no fishermen, it should fill in forever
  test("max capacity reached",()
  {


    Simulation sim = new Simulation.oneLonelyFishery(
        new DateTime.now().millisecondsSinceEpoch);

    Fishery hawaii = sim.fisheries.first;
    expect(hawaii.bioMass<hawaii.maxCapacity,true); //starts not full

    sim.scheduleAgents();


    for(int i=0; i<1000;i++)
    {
      sim.schedule.simulateDay();
    }
    //ends full
    expect(hawaii.bioMass,closeTo(hawaii.maxCapacity,.0001));


  });

  //overfishing kills
  test("fish is overfished",()
  {


    Simulation sim = new Simulation.overfishing(
        new DateTime.now().millisecondsSinceEpoch);

    Fishery hawaii = sim.fisheries.first;
    expect(hawaii.bioMass,closeTo(hawaii.maxCapacity,.0001)); //starts full

    sim.scheduleAgents();


    for(int i=0; i<2000;i++)
    {
      sim.schedule.simulateDay();
    }
    //ends full
    expect(hawaii.bioMass,closeTo(0,.0001));


  });

  //overfishing kills
  test("best is best",()
  {


    Simulation sim = new Simulation.chooseRichest(
        new DateTime.now().millisecondsSinceEpoch);

    Fishery best = sim.fisheries.first;



    sim.scheduleAgents();
    sim.schedule.simulateDay();
    //on average only half will be correct the first day
    expect(best.fishermenHere < 20, true);
    //but after a few days, it should be everyone
    for(int i=0;i<10;i++)
      sim.schedule.simulateDay();
    expect(best.fishermenHere > 20, true);


  });

//overfishing kills
  test("no oil costs, richer but farther is chosenn",()
  {


    Simulation sim = new Simulation.gasPolicy(
        new DateTime.now().millisecondsSinceEpoch,oilCosts:0.0);

    Fishery best = sim.fisheries.first;



    sim.scheduleAgents();
    sim.schedule.simulateDay();
    //on average only half will be correct the first day
    expect(best.fishermenHere < 20, true);
    //but after a few days, it should be everyone
    for(int i=0;i<10;i++)
      sim.schedule.simulateDay();
    expect(best.fishermenHere > 20, true);


  });

//overfishing kills
  test("with oil costs, poor closer gets chosen",()
  {


    Simulation sim = new Simulation.gasPolicy(
        new DateTime.now().millisecondsSinceEpoch,oilCosts:0.1);




    Fishery poor = sim.fisheries.last;



    sim.scheduleAgents();
    sim.schedule.simulateDay();
    //on average only half will be correct the first day
    expect(poor.fishermenHere < 20, true);
    //but after a few days, it should be everyone
    //unfortunately I can't be sure when and after a while the close fishery gets exhausted
    int maxFishermen = 0;
    for(int i=0;i<50;i++)
    {

      sim.schedule.simulateDay();
      maxFishermen = max(maxFishermen,poor.fishermenHere);

      print(poor.fishermenHere);
    }
    expect(maxFishermen > 16, true);


  });


}