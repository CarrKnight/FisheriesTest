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

    fishery.updateBioMass();
    expect(fishery.bioMass,closeTo(1.049500 ,.001));
    fishery.updateBioMass();
    expect(fishery.bioMass,closeTo(1.101424 ,.001));
    fishery.updateBioMass();
    expect(fishery.bioMass,closeTo(1.155889 ,.001));
    fishery.updateBioMass();
    expect(fishery.bioMass,closeTo(1.213015 ,.001));
    fishery.updateBioMass();
    expect(fishery.bioMass,closeTo(1.272930 ,.001));



  });

  test("bounded", (){

    Fishery fishery = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);

    fishery.maxCapacity=2.0;
    fishery.bioMass=1.0;
    fishery.growthRate=3.0; //300% growth!


    for(int i=0; i<500;i++)
      fishery.updateBioMass();


    expect(fishery.bioMass<=2.0,true);



  });


  test("fish out", (){

    Fishery fishery = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);

    fishery.maxCapacity=100.0;
    fishery.bioMass=100.0;
    fishery.growthRate=0.0; //no growth


    //consume 50%
    fishery.fishHere(.5);
    fishery.updateBioMass();
    expect(fishery.bioMass,closeTo(50,.0001));
    expect(fishery.netBiomassChange,closeTo(-50,.0001));
    expect(fishery.bioMassFished,closeTo(50,.0001));
    expect(fishery.fishermenHere,1);


    //consume another 80%
    fishery.resetCounters();
    fishery.fishHere(.60);
    fishery.fishHere(.20);
    fishery.updateBioMass();
    expect(fishery.bioMass,closeTo(10,.0001));
    expect(fishery.netBiomassChange,closeTo(-40,.0001));
    expect(fishery.bioMassFished,closeTo(40,.0001));
    expect(fishery.fishermenHere,2);


  });


  test("fish and grow",(){
    Fishery fishery = new Fishery([new Point(0.0,0.0),
    new Point(0.0,1.0),new Point(1.0,0.0),new Point(1.0,1.0)]);

    fishery.maxCapacity=100.0;
    fishery.bioMass=100.0;
    fishery.growthRate=2.0; //200% so that when it grows it grows at 2*(1-.5)=100% (stupid logistic growth)


    //consume 50%
    fishery.fishHere(.5);

    //it should be exactly the same in the end
    fishery.updateBioMass();
    expect(fishery.bioMass,closeTo(100,.0001));
    expect(fishery.netBiomassChange,closeTo(0,.0001));
    expect(fishery.bioMassFished,closeTo(50,.0001));
  });

}