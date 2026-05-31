import 'package:flutter/foundation.dart';

class AdminShellController {
  AdminShellController._();

  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  static void selectTab(int index) {
    tabIndex.value = index;
  }
}
