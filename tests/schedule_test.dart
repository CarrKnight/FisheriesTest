/*
 * This code is open-source, MIT license. See the LICENSE file
 */

import 'package:unittest/unittest.dart';
import 'package:mapspike/model/model.dart';
import 'dart:collection';


main(){



  test("Simple Schedule",()
  {

    Schedule s = new Schedule();
    Queue toFill = new Queue();
    s.schedule(Phase.MOVEMENT,(s)=>toFill.addLast(10));
    s.schedule(Phase.GUI,(s)=>toFill.addLast(30));
    s.schedule(Phase.REPLENISHING,(s)=>toFill.addLast(15));
    s.schedule(Phase.REPLENISHING,(s)=>toFill.addLast(20));
    s.simulateDay();
    expect(toFill,[10,15,20,30]);

  });


  test("Tomorrow Schedule",()
  {

    Schedule s = new Schedule();
    Queue toFill = new Queue();
    int i = 10;
    Step stepper = (schedule){
      toFill.addLast(i);
      i+=10;
    };
    s.schedule(Phase.MOVEMENT,(schedule) {
      stepper(schedule);
      s.scheduleTomorrow(stepper);
    });
    s.simulateDay();
    s.simulateDay();
    expect(toFill,[10,20]);

  });


  test("Repeating Schedule",()
  {

    Schedule s = new Schedule();
    Queue toFill = new Queue();
    s.scheduleRepeating(Phase.REPLENISHING,(schedule)=>toFill.addLast(10));

    s.simulateDay();
    s.simulateDay();
    s.simulateDay();
    s.simulateDay();
    expect(toFill,[10,10,10,10]);

  });



}
