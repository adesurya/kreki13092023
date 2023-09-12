import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kreki119/app/core/base/base_view.dart';

import '../controllers/emergency_history_controller.dart';

class EmergencyHistoryView extends BaseView<EmergencyHistoryController> {


  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(title: Text(''),);
  }

  @override
  Widget body(BuildContext context) {
    return Container();
  }
}
