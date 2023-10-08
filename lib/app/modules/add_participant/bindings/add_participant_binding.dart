import 'package:get/get.dart';

import '../controllers/add_participant_controller.dart';

class AddParticipantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddParticipantController>(
      () => AddParticipantController(),
    );
  }
}
