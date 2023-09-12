import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kreki119/app/core/model/emergency_status.dart';
import 'package:kreki119/app/core/utils/call_util.dart';
import 'package:kreki119/app/core/values/app_colors.dart';
import 'package:kreki119/app/core/values/text_styles.dart';
import 'package:kreki119/app/core/widget/asset_image_view.dart';
import 'package:kreki119/app/data/model/response/emergency_entity.dart';
import 'package:kreki119/app/data/model/response/emergency_mobile_entity.dart';
import 'package:kreki119/flavors/build_config.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/date_util.dart';
import '../values/app_values.dart';
import '../widget/elevated_container.dart';

class ItemEmergency extends StatelessWidget {
  const ItemEmergency({Key? key,
    required this.item,
    this.onTap,
    this.isVolunteerView = false
  }) : super(key: key);

  final EmergencyMobileEntity item;
  final bool isVolunteerView;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    // var date = DateTime.parse(item.updatedAt ?? '').toLocal();
    Logger logger = BuildConfig.instance.config.logger;
    var date = item.createdAt?.iSeconds ?? DateTime.now().second;
    var dateTime = DateTime.fromMillisecondsSinceEpoch(date*1000,);
    // var hasGoingStat = item.currentStatus == EmergencyStatus.ACCEPTED.description ||
    //     item.currentStatus == EmergencyStatus.ON_GOING.description;

    return ElevatedContainer(
      borderRadius: isVolunteerView ? 0 : AppValues.smallRadius,
      padding: const EdgeInsets.all(AppValues.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          !isVolunteerView ? Container(height: 1,) :
          const Text('Permintaan darurat berlangsung', style: appBarActionTextStyle,),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: AppValues.minLeadingWidth,
                child: Column(
                  children: [
                    const AssetImageView(fileName: 'ic_marker_victim.svg', width: AppValues.iconSize_28,),

                    Text(item.namaKorban ?? item.fullName ?? 'Korban', textAlign: TextAlign.center,
                      maxLines: 1,
                    )
                  ],
                ),
              ),

              AppValues.padding.toInt().width,

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat("dd MMM yyyy").format(dateTime)),
                      Text(DateFormat("HH:mm:ss").format(dateTime)),
                    ],
                  ),
                  Text(item.currentStatus.toString(), style: cardSubtitleStyle,),

                  AppValues.smallPadding.toInt().height,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item.keterangan ?? 'tidak ada keterangan deskripsi').expand(),

                      isVolunteerView ?
                      item.phoneNumber.isEmptyOrNull ? Container(width: 1,) :
                      const CircleAvatar(
                        backgroundColor: AppColors.colorPrimary,
                        radius: AppValues.iconSmallSize,
                        child: Icon(Icons.call_outlined),
                      ).onTap((){
                        UtilCall.launchCall(item.phoneNumber ?? '');
                      }) : Container(width: 1,),
                    ],
                  ),
                ],
              ).expand()

            ],
          ),
        ],
      ),
    ).onTap(onTap);
  }
}
