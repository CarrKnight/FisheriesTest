/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of model;

//basically copy pasted from lancaster


/**
 * A simple schedule, going through each phase and not even bothering randomizing itself
 * It has a simple queue of steps to go through each day. You can schedule "soon" which means as soon
 * as that phase comes up (or now if we are currently in that phase) or "tomorrow" which assumes same phase next day.
 */
class Schedule
{

  Map<Phase,Queue<ScheduledStep>> _stepsByPhase;

  Queue<ScheduledStep> _tomorrow;

  int _day = 1;

  Phase currentPhase;



  Schedule()//initialize empty
  {
    _stepsByPhase = new Map();
    _tomorrow = new Queue();
    for(Phase phase in Phase.PHASE_LIST)
    {
      _stepsByPhase[phase]=new Queue<ScheduledStep>();
      // _stepsByPhase.putIfAbsent(phase,()=>new Queue<Step>());
    }

  }

  /**
   * Schedule the step [s] to occur as soon as we are in phase [p]
   */
  void schedule(Phase p, Step s){
    _schedule(p,s,false);
  }

  /**
   * Schedule the step [s] to occur every [p]
   */
  void scheduleRepeating(Phase p, Step s){
    _schedule(p,s,true);
  }

  void _schedule(Phase p, Step s, bool repeating){
    assert(s != null);
    assert(p != null);
    _stepsByPhase[p].addLast(new ScheduledStep(s,repeating));
  }


  /**
   * Make [s] occur tomorrow at current phase.
   */
  void scheduleTomorrow(Step s){
    _tomorrow.add(new ScheduledStep(s,false));
  }


  void simulateDay()
  {
    //go through each phase
    for(currentPhase in Phase.PHASE_LIST)
    {
      //while there are things to do.
      while(_stepsByPhase[currentPhase].isNotEmpty) {
        //do the first
        ScheduledStep next = _stepsByPhase[currentPhase].removeFirst();
        next.step(this);
        //if it's repeating, put it in the tomorrow pile
        if(next.repeating)
          _tomorrow.addLast(next);
      }
      //done for this phase, but add all the "tomorrow" scheduled
      _stepsByPhase[currentPhase].addAll(_tomorrow);
      _tomorrow.clear();
    }
    //day over!
    _day++;
  }




  get day=> _day;

}

class Phase {

  final int order;

  const Phase._(this.order);

  static const DAWN = const Phase._(0);
  static const FISHING = const Phase._(1);
  static const GOSSIPING = const Phase._(3);
  static const REPLENISHING = const Phase._(4);
  static const PRESENTATION = const Phase._(5); //non-model events that need to happen before gui is alerted
  static const GUI = const Phase._(6);


  static final List<Phase> PHASE_LIST = [DAWN,FISHING,GOSSIPING,REPLENISHING,PRESENTATION, GUI];


}
/**
 * step means a function that knows about the schedule
 */
typedef void Step(Schedule s);


//a step plus a flag to tell me if it should repeat every day or not
class ScheduledStep {

  final Step step;

  final bool repeating;

  ScheduledStep(this.step, this.repeating);
}

