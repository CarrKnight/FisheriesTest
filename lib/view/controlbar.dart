/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of view;

typedef void Reset();

/**
 * A bunch of buttons to press to step/unstep the simulation
 */
class ControlBar
{

  int speed;


  Duration msPerStep = new Duration(milliseconds:80);


  final SimulationPresentation presentation;


  final DivElement container;

  AnchorElement playButton;

  AnchorElement resetButton;

  bool playing = false;

  List<StreamSubscription> listeners = [];

  ControlBar(this.container, this.presentation, String simulationId,Reset reset,
  {this.speed:80,GlobalCosts costs:null,bool tariffControl: false})
  {
    msPerStep = new Duration(milliseconds:speed);
    //this is how buttons look like in pure.css
    //  <a class="pure-button" href="#">A Pure Button</a>

    //add play button
    playButton = new AnchorElement()
      ..className = "pure-button pure-button-primary"
//      ..href = "#"
      ..text = "Play";

    listeners.add(
        playButton.onClick.listen((e)
                                  {
                                    playing = !playing;
                                    if(playing)
                                    {
                                      step();
                                      playButton.className="pure-button pure-button-active pure-button-primary";
                                      playButton.text = "Pause";
                                    }
                                    else
                                    {
                                      playButton.className="pure-button pure-button-primary";
                                      playButton.text = "Play";

                                    }
                                  })
        );
    //add reset button
    resetButton = new AnchorElement()
      ..className = "pure-button"
//      ..href = "#"
      ..text = "Reset";

    listeners.add(
    resetButton.onClick.listen((e)=>reset())
    );

    //add speed slider
    LabelElement label = new LabelElement()
      ..text = "Speed "
      ..htmlFor = "${simulationId}_speed";

    InputElement slider = new InputElement()
      ..type = "range"
      ..id = "${simulationId}_speed"
      ..min= "10"
      ..value= "${speed}"
      ..max = "300"
      ..step="10";

    slider.style.width = "60%";

    label.append(slider);


    SpanElement speedometer = new SpanElement();
    speedometer.text=" $speed ms";

    //listen to it
    listeners.add(

        slider.onInput.listen((e){
          speed=int.parse(slider.value);
          msPerStep = new Duration(milliseconds:speed);
          speedometer.text=" $speed ms";
        })
        );

    SpanElement dayCounter = new SpanElement();
    dayCounter.text = "";

    listeners.add(
        presentation.stream.listen((e)=>dayCounter.text=" Day: ${e.day}")
        );
    //add it all to the container
    container.append(playButton);
    container.append(resetButton);
    container.append(dayCounter);
    container.append(new BRElement());
    container.append(label);
    container.append(speedometer);
    //if you are given global costs, add oil slider
    if(costs != null)
    {
      container.append(new BRElement());
      container.append(addOilSlider(costs,simulationId));
      if(tariffControl)
      {
        List<DivElement> sliders = addTariffSliders(costs,simulationId);
        for(DivElement e in sliders)
        {
          container.append(new BRElement());
          container.append(e);
        }
      }
    }

  }

  step()
  {

    if(playing)
    {
      presentation.step();
      Timer timer = new Timer(msPerStep,()=>step());
    }
  }


  kill()
  {
    playing = false;
    for(StreamSubscription listener in listeners)
      listener.cancel();
  }


  DivElement addOilSlider(GlobalCosts costs, String simulationId)
  {
    DivElement container = new DivElement();
    //add speed slider
    LabelElement label = new LabelElement()
      ..text = "Oil Price"
      ..htmlFor = "${simulationId}_oil";

    InputElement slider = new InputElement()
      ..type = "range"
      ..id = "${simulationId}_oil"
      ..min= "0"
      ..value= "${costs.oilPricePerKm}"
      ..max = "5"
      ..step="0.1";

    slider.style.width = "60%";

    label.append(slider);


    SpanElement meter = new SpanElement();
    meter.text=" ${costs.oilPricePerKm}\$/km";

    //listen to it
    listeners.add(

        slider.onInput.listen((e){
          double cost=double.parse(slider.value);
          costs.oilPricePerKm = cost;
          meter.text=" ${costs.oilPricePerKm}\$/km";
        })
        );

    SpanElement dayCounter = new SpanElement();
    dayCounter.text = "";

    container.append(label);
    container.append(meter);
    return container;
  }




  List<DivElement> addTariffSliders(GlobalCosts costs, String simulationId)
  {

    List<DivElement> toReturn = [];
    costs.tariffs.forEach((fishery,tariff)
                          {


                            DivElement container = new DivElement();
                            //add speed slider
                            LabelElement label = new LabelElement()
                              ..text = "${fishery.name} tariff "
                              ..htmlFor = "${simulationId}_${fishery.name}";

                            InputElement slider = new InputElement()
                              ..type = "range"
                              ..id = "${simulationId}_${fishery.name}"
                              ..min= "0"
                              ..value= "${tariff}"
                              ..max = "10"
                              ..step="0.5";

                            slider.style.width = "60%";

                            label.append(slider);


                            SpanElement meter = new SpanElement();
                            meter.text=" ${tariff}\$/day";

                            //listen to it
                            listeners.add(

                                slider.onInput.listen((e){
                                  double newTariff=double.parse(slider.value);
                                  costs.tariffs[fishery] = newTariff;
                                  meter.text=" ${newTariff}\$/day";
                                })
                                );

                            SpanElement dayCounter = new SpanElement();
                            dayCounter.text = "";

                            container.append(label);
                            container.append(meter);
                            toReturn.add(container);




                          });
    return toReturn;
  }


}