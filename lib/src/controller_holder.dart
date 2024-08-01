

class ControllerHolder {
  static final ControllerHolder _instance = ControllerHolder._internal();
  dynamic _chatNewController;

  factory ControllerHolder() {
    return _instance;
  }

  ControllerHolder._internal();

  void setChatNewController(dynamic controller) {
    _chatNewController = controller;
  }

  dynamic get chatNewController => _chatNewController;
}