import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:kreki119/app/core/model/emergency_status.dart';
import 'package:kreki119/app/core/values/text_styles.dart';
import 'package:kreki119/app/core/view_bottom/view_add_contact.dart';
import 'package:kreki119/app/core/view_item/item_emergency.dart';
import 'package:kreki119/app/core/view_item/item_weather.dart';
import 'package:kreki119/app/core/widget/asset_image_view.dart';
import 'package:kreki119/app/routes/app_pages.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../core/view_bottom/view_contact.dart';
import '../../../core/view_item/item_contact.dart';
import '/app/core/base/base_view.dart';
import '/app/core/values/app_values.dart';
import '/app/modules/home/controllers/home_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../aid_book/views/aid_book_view.dart';

class HomeView extends BaseView<HomeController> {

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      leading: null,
      title: const Text('Beranda', style: boldTitleStyle,),
      bottom: TabBar(
        controller: controller.tabController,
        tabs: const [
          Tab(text: 'Permintaan',),
          Tab(text: 'Bantuan Lain',),
          Tab(text: 'Buku saku',),
        ],
      ),
      actions: [
        IconButton(onPressed: () async{
          controller.checkVolunteerStatus();
        },
          icon: badgeIcon(),
          tooltip: 'Relawan',
        ),

        // IconButton(onPressed: () async{
        //   Get.toNamed(Routes.EMERGENCY_HISTORY);
        // },
        //   icon: const Icon(Icons.history),
        //   tooltip: 'History',
        // )
      ],
    );
  }

  Widget badgeIcon(){
    return Stack(
      alignment: Alignment.center,
      children: const [
        Align(alignment: Alignment.topRight, child: Icon(FontAwesome.warning, size: AppValues.iconSmallerSize, color: Colors.red,),),
        Icon(Icons.verified_user,size: AppValues.iconSize_28,),
      ],
    );
  }

  @override
  Widget body(BuildContext context) {
    return TabBarView(
      controller: controller.tabController,
      children: [
        requestedEmergency(),
        otherHelp(),
        AidBookView()
      ],
    );
  }

  Widget requestedEmergency(){
    return RefreshIndicator(
      onRefresh: () => controller.mainController.onLoadEmergency(),
      child: Column(
        children: [
          weatherWidget(),

          Container(
            child: Obx(()=>controller.mainController.emergencyList.isEmpty ?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum ada permintaan darurat, klik tombol darurat untuk melakukan permintaan atau',
                  textAlign: TextAlign.center,).center(widthFactor: 2),
                AppValues.padding.toInt().height,
                AppButton(
                  onTap: (){
                    controller.mainController.onLoadEmergency();
                  },
                  textColor: AppColors.primary400,
                  text: 'Muat ulang',
                )
              ],
            ) :
                ListView.separated(
                  itemCount: controller.mainController.emergencyList.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: AppValues.padding, vertical: AppValues.smallPadding),
                  itemBuilder: (BuildContext context, int index) {
                    var item = controller.mainController.emergencyList[index];
                    // var photos = item.photos?.first ?? '';

                    return ItemEmergency(item: item,
                      onTap: (){
                        if(item.currentStatus == EmergencyStatus.WAITING.description){
                          Get.toNamed(Routes.EMERGENCY_WAIT,arguments: item);
                        }
                      },
                    );
                  }, separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10,),
                )
            ).expand(),
          ),
        ],
      ),
    );
  }
  
  Widget weatherWidget(){
    return Obx(()=> ItemWeather(
        item: controller.mainController.weather,
      tapWeather: (){
          controller.mainController.loadWeather();
      },
    )
    );
  }

  Widget headerWidget(){
    return Container(
      color: AppColors.primary400,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Hai, User', style: cardTitleStyle.copyWith(color: AppColors.textColorWhite),),
              Text('Apakah anda butuh bantuan?', style: descriptionTextStyle.
                copyWith(color: AppColors.textColorWhite),),
              Text('Klik tombol darurat untuk mencari pertolongan',
                style: contentTextStyle,),

            ],
          ),

          const CircleAvatar(
            radius: AppValues.circularImageSize_30,
            backgroundColor: AppColors.primary300,
            child: CircleAvatar(
              radius: AppValues.largeRadius,
              backgroundColor: AppColors.neutral100,
              child: Text('U', style: titleStyle,),
            ),
          )
        ],
      ).paddingAll(AppValues.padding),
    );
  }

  Widget otherHelp(){
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Cari Bantuan Lain', style: descriptionTextStyle,),
        Text('Anda dapat menggunakan Bantuan Lain untuk membantu dalam keadaan darurat',
          style: greyDarkContentTextStyle,),

        GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              crossAxisSpacing: AppValues.smallPadding,
              mainAxisSpacing: AppValues.smallPadding
            ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          primary: true,
          children: [
            itemHelp('PSC', 'ic_psc.png').onTap((){
              Get.toNamed(Routes.PSC);
            }),
            itemHelp('Ambulance', 'ic_ambulance.svg').onTap((){
              Get.toNamed(Routes.AMBULANCE);
            }),
            itemHelp('Relawan', 'ic_volunteer.svg').onTap((){
              Get.toNamed(Routes.VOLUNTEER_MAP);
            }),
            itemHelp('RS & Faskes', 'ic_hospital.svg').onTap((){
              Get.toNamed(Routes.HOSPITAL);
            }),
            itemHelp('SehatPedia', 'ic_sehatpedia.png').onTap((){
              openUrl("https://play.google.com/store/apps/details?id=id.sehatpedia.apps&hl=en&gl=US");
            })
          ],
        ).marginOnly(top: AppValues.padding),

        emergencyContact(),
      ],
    ).marginAll(AppValues.padding);
  }

  Widget itemHelp(String title, String imageUrl){
    return Container(
      decoration: boxDecorationRoundedWithShadow(AppValues.radius_6.toInt()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imageUrl.isEmpty ?
          const Placeholder(fallbackHeight: AppValues.iconLargeSize,)
              .marginOnly(left: AppValues.padding,
          right: AppValues.padding,bottom: AppValues.smallPadding) :
          AssetImageView(fileName: imageUrl,
            height: AppValues.iconHomeSize, width: AppValues.iconHomeSize,).center(),
          AppValues.smallPadding.toInt().height,
          Text(title)
        ],
      ).center(),
    );
  }

  Widget emergencyContact(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [

        Text('Kontak Darurat', style: descriptionTextStyle,),

        AppValues.padding.toInt().height,

        Container(
          decoration: boxDecorationRoundedWithShadow(AppValues.radius_12.toInt()),
          padding: const EdgeInsets.all(AppValues.smallPadding),
          child: Row(
            children: [
              Container(
                decoration: boxDecorationWithRoundedCorners(),
                child: const Icon(Icons.person_add_alt_1, color: AppColors.secondary500,),
              ),
              AppValues.padding.toInt().width,
              Text('Tambah Kontak Darurat', style: cardTagStyle,)
            ],
          ),
        ).onTap((){
          openBottomSheet(ViewAddContact(onClickSubmit: controller.onAddContact));
        }),

        AppValues.padding.toInt().height,

        Obx(()=>controller.contacts.isEmpty ? Container():
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppValues.smallPadding,
            mainAxisSpacing: AppValues.smallPadding,
            childAspectRatio: 3/1
          ),
            itemCount: controller.contacts.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            primary: true,
            itemBuilder: (context, index){
              var item = controller.contacts[index];

              return ItemContact(item:item).onTap((){
                openBottomSheet(ViewContact(item: item, onTapCall: (phone){
                  openCall(phone);
                },));
              });
            }))

      ],
    ).paddingSymmetric(vertical: AppValues.padding);
  }

}
