import 'package:get/get.dart';
import '../controller/controller.dart';

class InBin implements Bindings {
  @override
  void dependencies() {
    Get.put(appController());
  }
}
