/*
 * This code is open-source, MIT license. See the LICENSE file
 */


library presentation.test;


import 'package:unittest/unittest.dart';
import 'package:mapspike/model/model.dart';
import 'package:mapspike/presentation/presentation.dart';
import 'dart:math';
import 'dart:collection';
import 'dart:async';

main()
{



  //move fishermen around, hope it works
  test("movement works",()
  {

    Random random = new Random();
    Port port = new Port({},0.0,0.0);
    port.jitterVariance = 0.0; //no randomness

    List<Fisherman> roster = new List();
    for(int i=0; i<1000; i++)
      roster.add(new Fisherman(port,0.0,random,0.0,0.0));

    //two fisheries
    Fishery first = new Fishery([new Point(1.0,1.0),new Point(1.0,1.0)]);
    Fishery second = new Fishery([new Point(2.0,2.0),new Point(2.0,2.0)]);


    //create the presentation
    FishermenPresentation presentation = new FishermenPresentation(roster,random);

    //now move randomly and repeatedly the fishers
    for(int step=0;step<1000;step++)
    {
      for(Fisherman fisherman in roster)
      {
        double rand = random.nextDouble();
        if(rand < .33)
          fisherman.location = Fisherman.AT_PORT;
        else if(rand<.66)
          fisherman.location =first;
        else
          fisherman.location = second;
      }
      //tell presentation about it!
      presentation.present();
    }


    //check that it has updated correctly
    for(Fisherman fisherman in roster)
    {
      Fishery location =fisherman.location;

      if(location == Fisherman.AT_PORT)
      {
        expect(presentation.locations[fisherman].x, 0.0);
        expect(presentation.locations[fisherman].y, 0.0);
      }
      else if(location == first)
      {
        expect(presentation.locations[fisherman].x, 1.0);
        expect(presentation.locations[fisherman].y, 1.0);
      }
      else
      {
        expect(presentation.locations[fisherman].x, 2.0);
        expect(presentation.locations[fisherman].y, 2.0);
      }
    }



  });



  //move fishermen around but only notice through streams
  test("streaming works",()
  {

    Random random = new Random();
    Port port = new Port({},0.0,0.0);
    port.jitterVariance = 0.0; //no randomness

    List<Fisherman> roster = new List();
    for(int i=0; i<2; i++)
      roster.add(new Fisherman(port,0.0,random,0.0,0.0));

    //two fisheries
    Fishery first = new Fishery([new Point(1.0,1.0),new Point(1.0,1.0)]);
    Fishery second = new Fishery([new Point(2.0,2.0),new Point(2.0,2.0)]);


    //create the presentation
    FishermenPresentation presentation = new FishermenPresentation(roster,random);

    //create a copy of locations that updates through streams
    Map<Fisherman,Point> streamedTo = new HashMap.from(presentation.locations);
    int counters =0;

    presentation.movementStream.listen(expectAsync((e)
                                       {
                                         counters++;
                                         print(counters);
                                         e.movements.forEach((Fisherman f, Point p)
                                                             {streamedTo[f]=p;}
                                                             );
                                         if(counters==1000)
                                         {
                                           print("checking!");
                                           //test
                                           //check that it has updated correctly
                                           for(Fisherman fisherman in roster)
                                           {
                                             Fishery location =fisherman.location;

                                             if(location == Fisherman.AT_PORT)
                                             {
                                               expect(streamedTo[fisherman].x, 0.0);
                                               expect(streamedTo[fisherman].y, 0.0);
                                             }
                                             else if(location == first)
                                             {
                                               expect(streamedTo[fisherman].x, 1.0);
                                               expect(streamedTo[fisherman].y, 1.0);
                                             }
                                             else
                                             {
                                               expect(streamedTo[fisherman].x, 2.0);
                                               expect(streamedTo[fisherman].y, 2.0);
                                             }
                                           }
                                         }
                                         ;},count:1000));

    //now move randomly and repeatedly the fishers
    for(int step=0;step<1000;step++)
    {
      for(Fisherman fisherman in roster)
      {
        double rand = random.nextDouble();
        if(rand < .33)
          fisherman.location = Fisherman.AT_PORT;
        else if(rand<.66)
          fisherman.location =first;
        else
          fisherman.location = second;
      }
      //tell presentation about it!
      presentation.present();
    }




  });



}