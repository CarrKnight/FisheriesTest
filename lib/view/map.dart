/*
 * This code is open-source, MIT license. See the LICENSE file
 */

part of view;


/**
 * just a GMap that listens to mouse events in the map container; useful for tooltips since the dart gmap api
 * doesn't use dart mouse events
 */
class MouseTrackingMap extends GMap
{


  int mouseX;

  int mouseY;


  MouseTrackingMap(Element container, MapOptions options)
  :
  super(container,options)
  {

    container.onMouseMove.listen((event){

      mouseX = event.page.x;
      mouseY = event.page.y;

    });

  }
}