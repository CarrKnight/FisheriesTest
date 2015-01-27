/*
 * This code is open-source, MIT license. See the LICENSE file
 */

library fishery.test;


import 'package:unittest/unittest.dart';
import 'package:mapspike/model/model.dart';
import 'dart:math';

main(){

  test("easy point in between", (){

    Fishery fishery = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);

    for(int i=0; i<100;i++)
    {
      Point random = fishery.randomPointInBetween(new Random());
      expect(random.x >=0,true);
      expect(random.y >=0,true);
      expect(random.x <=1,true);
      expect(random.y <=1,true);
    }

  });

  test("grows correctly", (){

    Fishery fishery = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);

    fishery.maxCapacity=100.0;
    fishery.bioMass=1.0;
    fishery.growthRate=.05;

    //compare against R computed values for logistic growth

    fishery.replenish();
    expect(fishery.bioMass,closeTo(1.049500 ,.001));
    fishery.replenish();
    expect(fishery.bioMass,closeTo(1.101424 ,.001));
    fishery.replenish();
    expect(fishery.bioMass,closeTo(1.155889 ,.001));
    fishery.replenish();
    expect(fishery.bioMass,closeTo(1.213015 ,.001));
    fishery.replenish();
    expect(fishery.bioMass,closeTo(1.272930 ,.001));



  });

  test("bounded", (){

    Fishery fishery = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);

    fishery.maxCapacity=2.0;
    fishery.bioMass=1.0;
    fishery.growthRate=3.0; //300% growth!


    for(int i=0; i<500;i++)
      fishery.replenish();


    expect(fishery.bioMass<=2.0,true);



  });


}