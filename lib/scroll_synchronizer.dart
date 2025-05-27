import 'package:flutter/material.dart';

// A class to create a set of ScrollControllers that are synchronized
class ScrollSynchronizer {
  List<ScrollController> _controllers = [];
  List<VoidCallback> _controllerListeners = [];
  bool _isSyncingScroll = false;

  /*
  Returns a new ScrollController which will be synchronized with the others.
  */
  ScrollController getNewSynchronizedController() {
    ScrollController newController = ScrollController();

    // Add a new empty callback for the new controller.
    void newCallback () {}
    _controllerListeners.add(newCallback);
    newController.addListener(newCallback);
    _controllers.add(newController);

    // Synchronize by adding an event listener between every controller.
    for (int i = 0; i < _controllers.length; i++) {
      // First remove previous listener.
      _controllers[i].removeListener(_controllerListeners[i]);
      // Then create the new callback, including the new controller.
      _controllerListeners[i] = () {
        if (_isSyncingScroll) return;
        _isSyncingScroll = true;
        for (int j = 0; j < _controllers.length; j++) {
          if (j != i && _controllers[j].hasClients) {
              _controllers[j].jumpTo(_controllers[i].offset);
          }
        }
        _isSyncingScroll = false;
      };
      // Finally add the new callback as a listener
      _controllers[i].addListener(_controllerListeners[i]);
    }

    return newController;
  }

  void dispose() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].removeListener(_controllerListeners[i]);
      _controllers[i].dispose();
    }
    _controllers.clear();
    _controllerListeners.clear();
  }
}