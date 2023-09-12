import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kreki119/app/core/base/base_view.dart';
import 'package:kreki119/app/core/values/app_colors.dart';
import 'package:kreki119/app/core/values/app_values.dart';
import 'package:kreki119/app/core/view_item/item_emergency.dart';
import 'package:kreki119/app/modules/emergency_pick/views/emergency_pick_view.dart';
import 'package:kreki119/app/routes/app_pages.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/volunteer_controller.dart';

class VolunteerView extends BaseView<VolunteerController> {


  // static push({UserMobileEntity? user, required String userId}){
  //   Get.toNamed(Routes.VOLUNTEER, arguments: [user, userId]);
  // }

  @override
  PreferredSizeWidget? appBar(BuildContext context) {

    return AppBar(
      title: const Text('Relawan Kreki',),
      titleSpacing: 0,
      bottom: TabBar(
        controller: controller.tabController,
        tabs: const [
          Tab(text: 'Darurat',),
          // Tab(text: 'Diterima',),
          Tab(text: 'Riwayat',)
        ],
      ),
    );
  }

  @override
  Widget body(BuildContext context) {
    return volunteerWidget();
  }

  Widget notVolunteerWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Anda belum menjadi relawan, \n'
            'mendaftar terlebih dahulu untuk melanjutkan',
          textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
        ).center(),
        AppValues.padding.toInt().height,
        AppButton(
          onTap: (){
            Get.toNamed(Routes.UPGRADE_VOLUNTEER);
          },
          textColor: AppColors.primary400,
          text: 'Daftar Relawan',
        )
      ],
    );
  }

  Widget requestVolunteerWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Permintaan relawan anda dalam pengajuan, \n'
            'segarkan halaman ini, untuk melihat perubahan status',
          textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
        ).center(),
        AppValues.padding.toInt().height,
        AppButton(
          onTap: (){
            controller.loadProfile();
          },
          textColor: AppColors.primary400,
          text: 'Cek Status relawan',
        )
      ],
    );
  }

  Widget volunteerWidget(){
    return Column(
      children: [
        TabBarView(
          controller: controller.tabController,
            children: [
              requestedEmergency(),
              // onGoingEmergency(),
              finishedEmergency()
            ]
        ).expand(),

        Obx(()=>controller.onGoingList.isNotEmpty?
        ItemEmergency(item: controller.onGoingList.first,
          isVolunteerView: true,
          onTap: (){
            EmergencyPickView.push(data: controller.onGoingList.first);
          },):
        Container(height: 1,))
      ],
    );
  }

  Widget requestedEmergency(){
    return Obx(()=>controller.emergencyList.isEmpty ?
    const Text('Belum ada permintaan darurat di dekatmu, data permintaan terdekat akan tampil disini',
      textAlign: TextAlign.center,).center(widthFactor: 2) :
    ListView.separated(
      itemCount: controller.emergencyList.length,
      shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: AppValues.padding,
            vertical: AppValues.smallPadding),
        itemBuilder: (BuildContext context, int index) {
        var item = controller.emergencyList[index];

        return ItemEmergency(item: item,
          onTap: (){
            if(controller.onGoingList.isEmpty){
              EmergencyPickView.push(data: item);
            } else {
              controller.showMessage('Selesaikan permintaan darurat berlangsung dahulu');
            }
          },
        );
    }, separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),)
    );
  }

  Widget onGoingEmergency(){
    return Obx(()=>controller.onGoingList.isEmpty ?
    const Text('Belum ada permintaan darurat berlangsung',
      textAlign: TextAlign.center,).center(widthFactor: 2) :
    ListView.separated(
      itemCount: controller.onGoingList.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: AppValues.padding, vertical: AppValues.smallPadding),
      itemBuilder: (BuildContext context, int index) {
        var item = controller.onGoingList[index];

        return ItemEmergency(item: item,
          onTap: (){
            EmergencyPickView.push(data: item);
          },
        );
      }, separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8,),

    )
    );
  }

  Widget finishedEmergency(){
    return Obx(()=>controller.finishedList.isEmpty ?
    const Text('Belum ada permintaan darurat terselesaikan',
      textAlign: TextAlign.center,).center(widthFactor: 2) :
    ListView.separated(
      itemCount: controller.finishedList.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: AppValues.padding, vertical: AppValues.smallPadding),
      itemBuilder: (BuildContext context, int index) {
        var item = controller.finishedList[index];

        return ItemEmergency(item: item,
          onTap: (){
            EmergencyPickView.push(data: item);
          },
        );
      }, separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8,),

    )
    );
  }
}
