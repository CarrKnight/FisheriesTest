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

  ControlBar(this.container, this.presentation, String simulationId,Reset reset,[this.speed=80])
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

  }

  step()
  {

    print("step!");
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


}