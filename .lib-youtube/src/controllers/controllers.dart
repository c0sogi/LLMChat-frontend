import 'package:get/get.dart';
import '/src/models/models.dart';
import '/src/utils/backend.dart';
import '/src/widgets/widgets.dart';

class BtmNavController extends GetxService {
  static BtmNavController get to => Get.find();
  RxInt bottomIndex = 0.obs;

  void onClickPlus() {
    Get.bottomSheet(const BtmSheet());
  }
}

class HomeController extends GetxService {
  static HomeController get to => Get.find();
  RxString text = "Push me".obs;

  void onClickButton(String accessKey, String secretKey, Crud crud) async {
    text(
      await requestFastAPI(
        url: "http://192.168.0.3:8000/api/services/email/send_by_ses",
        crud: Crud.get,
        queryParams: null,
        headers: null,
        body: null,
      ),
    );
  }
}
