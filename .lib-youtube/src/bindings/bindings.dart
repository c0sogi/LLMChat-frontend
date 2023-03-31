import 'package:flutter_web/src/controllers/controllers.dart';
import 'package:get/get.dart';

class IndexBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(BtmNavController());
    Get.put(HomeController());
  }
}
