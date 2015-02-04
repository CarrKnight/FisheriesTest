/*
 * This code is open-source, MIT license. See the LICENSE file
 */

/**
 * A simple PID controller, never lets MV go negative, doesn't allow negative parameters, has windup-stop enabled
 */

part of policy;

class PIDController {


  static const  double DEFAULT_PROPORTIONAL_PARAMETER = .1;
  static const  double DEFAULT_INTEGRAL_PARAMETER = .1;
  static const  double DEFAULT_DERIVATIVE_PARAMETER = 0.0;

  /**
   * the a of the discrete PID controller
   */
  double proportionalParameter;

  /**
   * the b of the discrete PID controller
   */
  double integrativeParameter;

  /**
   * the c of the discrete PID controller
   */
  double derivativeParameter;

  /**
   * offset + PID formula
   */
  double _manipulatedVariable = 0.0;

  /**
   * the offset: if the pid formula is 0 the MV is the offset
   */
  double _offset = 0.0;

  /**
   * when this is set to true the residual is -target+controlledVariable
   */
  bool invertSign = false;

  /**
   * the last residual
   */
  double _currentError =double.NAN;

  /**
   * the residual before last
   */
  double _previousError = double.NAN;

  double _sumOfErrors = 0.0;




  PIDController.standardPI():
  this(PIDController.DEFAULT_PROPORTIONAL_PARAMETER,
       PIDController.DEFAULT_INTEGRAL_PARAMETER,
       PIDController.DEFAULT_DERIVATIVE_PARAMETER
       );

  PIDController(this.proportionalParameter, this.integrativeParameter, this.derivativeParameter);

  set offset(double value){_offset=max(0.0,value);
  _manipulatedVariable = _offset;
  }

  get offset=> _offset;

  get manipulatedVariable=>((_manipulatedVariable*100.0).roundToDouble()/100.0); //always round to second decimal.


  /**
   * "step" the PID controller. A new CV is computed
   */
  updateMV() {
//PID FORMULA
    double newMV = offset +
                   proportionalParameter * _currentError +
                   integrativeParameter * _sumOfErrors;
    if (_previousError.isFinite)
      newMV += derivativeParameter * (_currentError - _previousError);

    //if newMV is <0, windup stop!
    if (newMV < 0) {
      if (integrativeParameter != 0) //if the i is not 0
        _sumOfErrors = _sumOfErrorsNeededForFormulaToBe0();
      newMV = 0.0;
    }

    //done!
    _manipulatedVariable = newMV;
  }

  void adjust(double target, double controlledVariable)
  {
    //compute error
    assert(target.isFinite);
    assert(controlledVariable.isFinite);

    double residual = invertSign ? controlledVariable-target : target-controlledVariable;
    assert(residual.isFinite);
    _previousError = _currentError;
    _currentError = residual;
    _sumOfErrors += _currentError;

    //now use the error to update the manipulated vaiable
    updateMV();

  }



  double _sumOfErrorsNeededForFormulaToBe0(){
    double numerator = 0 - offset - (proportionalParameter * _currentError);
    if(_previousError.isFinite)
      numerator-= derivativeParameter * (_currentError-_previousError);
    return numerator/integrativeParameter;
  }

  void changeSumOfErrorsSoOutputIsX(double x){
    double numerator = x - offset - (proportionalParameter * _currentError);
    if(_previousError.isFinite)
      numerator-= derivativeParameter * (_currentError-_previousError);
    _sumOfErrors =  numerator/integrativeParameter;
    updateMV();

  }

}


/**
 * use a pid to stay on target
 */
class PIDPolicy extends Policy
{

  double get target => genes[0];
  double get p => genes[1];
  double get i => genes[2];

  final Random random;

  PIDController controller;

  PIDPolicy(this.random);

  PIDPolicy.Random(this.random)
  {
    genes = new List<double>(3);

    genes[0] = (random.nextDouble() * 10000).roundToDouble();
    genes[1] = random.nextDouble()/100;
    genes[2] = random.nextDouble()/100;

  }

  double mutateGene(double gene, num strength) {
    if(random.nextBool())
      return max(0.0, gene + strength * gene * random.nextDouble()/10.0 );
    else
      return max(0.0, gene - strength * gene * random.nextDouble()/10.0 );

  }

  void simulationStart(Simulation sim) {
    controller = new PIDController(p,i,0.0);
  }

  void apply(Simulation sim) {
    controller.adjust(target,sim.biomeLeft());
    sim.costs.oilPricePerKm =  controller.manipulatedVariable;
  }


}


/**
 * use a pid to stay on target
 */
class PIDWithTariff extends Policy
{

  double get target => genes[0];
  double get p => genes[1];
  double get i => genes[2];
  double get tariffTarget => genes[3];
  double get tariffP => genes[4];
  double get tariffI => genes[5];

  final Random random;

  PIDController controller;
  PIDController tariffController;


  PIDWithTariff(this.random);

  PIDWithTariff.Random(this.random)
  {
    genes = new List<double>(6);

    genes[0] = (random.nextDouble() * 10000).roundToDouble();
    genes[1] = random.nextDouble()/100;
    genes[2] = random.nextDouble()/100;

    genes[3] = (random.nextDouble() * 2000).roundToDouble();
    genes[4] = random.nextDouble()/100;
    genes[5] = random.nextDouble()/100;

  }

  double mutateGene(double gene, num strength) {
    if(random.nextBool())
      return max(0.0, gene + strength * gene * random.nextDouble()/10.0 );
    else
      return max(0.0, gene - strength * gene * random.nextDouble()/10.0 );

  }

  void simulationStart(Simulation sim) {
    controller = new PIDController(p,i,0.0);
    tariffController = new PIDController(tariffP,tariffI,0.0);
  }

  void apply(Simulation sim) {
    controller.adjust(target,sim.biomeLeft());
    sim.costs.oilPricePerKm =  controller.manipulatedVariable;
    assert(sim.fisheries[0].name=="Marsala");
    sim.costs.tariffs[sim.fisheries[0]] =  controller.manipulatedVariable;
  }


}