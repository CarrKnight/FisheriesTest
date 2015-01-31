/*
 * This code is open-source, MIT license. See the LICENSE file
 */
library fisherman.test;


import 'package:unittest/unittest.dart';
import 'package:mapspike/model/model.dart';
import 'dart:math';


main()
{

  test("one profitable fishery, choose it!",()
  {



    //useless fishery
    Fishery fishery = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);
    //these actually don't factor in the choice since they are not known to the fisherman
    fishery.bioMass = 123.0;
    fishery.maxCapacity = 123.0;

    GlobalCosts costs = new GlobalCosts(100.0,0.0,{fishery:0.0});
    Port port = new Port({fishery:0.0},0.0,1.0);

    //create a fisherman with random expected bio
    Random random = new Random();
    Fisherman fisherman = new Fisherman(port,.5,random,1.0,2.0);

    //he should start at port
    expect(fisherman.location==Fisherman.AT_PORT,true);

    //now let the fisherman choose where to fish
    fisherman.chooseFishery(costs,random,0.0);
    //should have switched to fishery
    expect(fisherman.location==fishery,true);

    //make sure it counts correctly
    expect(fishery.fishermenHere,1);


  });

  test("one unprofitable fishery, stay home!",()
  {



    //useless fishery
    Fishery fishery = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);
    //these actually don't factor in the choice since they are not known to the fisherman
    fishery.bioMass = 123.0;
    fishery.maxCapacity = 123.0;

    //tariff is too damn high
    GlobalCosts costs = new GlobalCosts(100.0,0.0,{fishery:100.0});
    Port port = new Port({fishery:0.0},0.0,1.0);

    //create a fisherman with random expected bio
    Random random = new Random();
    Fisherman fisherman = new Fisherman(port,.5,random,1.0,2.0);

    //he should start at port
    expect(fisherman.location==Fisherman.AT_PORT,true);

    //now let the fisherman choose where to fish
    fisherman.chooseFishery(costs,random,0.0);
    //should have stayed home
    expect(fisherman.location==Fisherman.AT_PORT,true);

    //make sure it counts correctly
    expect(fishery.fishermenHere,0);


  });


  test("one unprofitable fishery, but noise make you choose differently!",()
  {



    //useless fishery
    Fishery fishery = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);
    //these actually don't factor in the choice since they are not known to the fisherman
    fishery.bioMass = 123.0;
    fishery.maxCapacity = 123.0;

    //tariff is too damn high
    GlobalCosts costs = new GlobalCosts(100.0,0.0,{fishery:100.0});
    Port port = new Port({fishery:0.0},0.0,1.0);

    //create a fisherman with random expected bio
    Random random = new Random();
    Fisherman fisherman = new Fisherman(port,.5,random,1.0,2.0);

    //he should start at port
    expect(fisherman.location==Fisherman.AT_PORT,true);

    //error is so high, it will choose to fish
    fisherman.chooseFishery(costs,random,1.0);
    //should have switched to fishery
    expect(fisherman.location==fishery,true);

    //make sure it counts correctly
    expect(fishery.fishermenHere,1);


  });

  test("wrong expecations correct themselves",()
  {

    //you have two fisheries, one full one empty but the expectations are reversed. Choose wrong at first right after that


    //profitable fishery
    Fishery fishery1 = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);
    //these actually don't factor in the choice since they are not known to the fisherman
    fishery1.bioMass = 100.0;
    fishery1.maxCapacity = 100.0;
    //empty fishery
    Fishery empty = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);
    //these actually don't factor in the choice since they are not known to the fisherman
    empty.bioMass = 0.0;
    empty.maxCapacity = 0.0;



    //no tariffs
    GlobalCosts costs = new GlobalCosts(100.0,0.0,{fishery1:0.0,empty:0.0});
    Port port = new Port({fishery1:0.0,empty:0.0},0.0,1.0);

    //create a fisherman with random expected bio
    Random random = new Random();
    Fisherman fisherman = new Fisherman(port,.5,random,1.0,2.0);
    //fix his expectations so that he thinks full is bad and empty is full
    fisherman.expectedBio[fishery1]=1.0;
    fisherman.expectedBio[empty]=100.0;

    //he should start at port
    expect(fisherman.location==Fisherman.AT_PORT,true);

    //will choose empty
    fisherman.chooseFishery(costs,random,0.0);
    //should have switched to fishery
    expect(fisherman.location==empty,true);

    //make sure it counts correctly
    expect(fishery1.fishermenHere,0);
    expect(empty.fishermenHere,1);

    //but now it should have changed expectations!
    expect(fisherman.expectedBio[fishery1],1.0);
    expect(fisherman.expectedBio[empty],0.0);

    //now it will choose better
    fisherman.chooseFishery(costs,random,0.0);
    expect(fisherman.location==fishery1,true);
    //and the expectations update correctly
    expect(fisherman.expectedBio[fishery1],100.0);
    expect(fisherman.expectedBio[empty],0.0);

  });

  test("distance matters if oil is expensive",()
  {
    //you have two fisheries, one full one empty but the expectations are reversed. Choose wrong at first right after that


    //profitable fishery
    Fishery fishery1 = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);
    fishery1.bioMass = 120.0;
    fishery1.maxCapacity = 120.0;
    Fishery fishery2 = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);
    fishery2.bioMass = 100.0;
    fishery2.maxCapacity = 100.0;


    //no tariffs, oil costs 1$
    GlobalCosts costs = new GlobalCosts(1.0,1.0,{fishery1:0.0,fishery2:0.0});
    //fishery 2 is very close. Fishery 1 is very far
    Port port = new Port({fishery1:100.0,fishery2:0.0},0.0,1.0);

    //create a fisherman with random expected bio
    Random random = new Random();
    Fisherman fisherman = new Fisherman(port,.5,random,1.0,2.0);
    //Fishery 1 is richer but it's farther away
    fisherman.expectedBio[fishery1]=120.0;
    fisherman.expectedBio[fishery2]=100.0;

    //he should start at port
    expect(fisherman.location==Fisherman.AT_PORT,true);

    //he will choose the closest one
    fisherman.chooseFishery(costs,random,0.0);
    expect(fisherman.location==fishery2,true);



    //remove oil costs
    costs.oilPricePerKm=0.0;

    //now it will choose 1
    fisherman.chooseFishery(costs,random,0.0);
    expect(fisherman.location==fishery1,true);

  });


}