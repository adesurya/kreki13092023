import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kreki119/app/core/model/volunteer_status.dart';
import 'package:kreki119/app/data/model/form/Form_add_contact.dart';
import 'package:kreki119/app/data/model/response/contact_entity.dart';
import 'package:kreki119/app/data/repository/volunteer/volunteer_repository.dart';
import 'package:kreki119/app/modules/main/controllers/main_controller.dart';
import 'package:kreki119/app/network/exceptions/api_exception.dart';
import 'package:kreki119/app/network/exceptions/base_api_exception.dart';
import 'package:kreki119/app/network/exceptions/base_exception.dart';
import 'package:kreki119/app/routes/app_pages.dart';
import 'package:nb_utils/nb_utils.dart';

import '/app/core/base/base_controller.dart';

class HomeController extends BaseController with GetSingleTickerProviderStateMixin {

  final mainController = Get.find<MainController>();

  final VolunteerRepository volunteerRepository = Get.find(tag: (VolunteerRepository).toString());

  final _contact = RxList<ContactEntity>();
  List<ContactEntity> get contacts => _contact.toList();
  set contacts(List<ContactEntity> data) => _contact(data);

  late TabController tabController;

  @override
  onInit()async{
    tabController = TabController(length: 3, vsync: this);

    loadDataContact();

    await mainController.onLoadEmergency();
    // await mainController.loadProfile();
    await loadUpdateLocation();

    super.onInit();
  }



  onRefreshPage() {
    //TODO
  }

  onLoadNextPage() {
    logger.i("On load next");

  }

  loadDataContact()async{
    callDataService(userRepo.getContacts(),
      onSuccess: (response){
        var data = response.data;

        if(data != null){
          contacts = data;
        }
      }
    );
  }


  onAddContact(String name, String email, String phone) async{
    FormAddContact form = FormAddContact()
    ..name = name
    ..email = email
    ..phoneNumber = phone;

    callDataService(userRepo.createContact(form),
        onSuccess: (response)async{
          if(response.message != null){
            finish(Get.context!);
            showMessage("${response.message}");

            showMessage("");

            await loadDataContact();
          }

        },
      onError: (Exception exception){
        if(exception is ApiException){
          toast("${exception.status}: ${exception.message}");
        } else if (exception is BaseException){
          toast(exception.message);
        } else if (exception is BaseApiException){
          toast("${exception.status}: ${exception.message}");
        } else {
          toast(exception.toString());
        }
      }
    );

  }

  checkVolunteerStatus() async{
    var user = await getUserMobile();
    callDataService(volunteerRepository.getVolunteerById(user.id.toString()),
      onSuccess: (response)async{
        var data = response.data;
        if(data==null){
          showConfirmDialog(Get.context, 'Anda belum jadi relawan, lanjutkan mendaftar?',
            positiveText: 'Ya, lanjutkan',
            negativeText: 'Tidak',
            onAccept: (){
              Get.toNamed(Routes.UPGRADE_VOLUNTEER);
            }
          );
        } else {
          if(data.status == VolunteerStatus.WAITING.name){
            showMessage('Pengajuan Volunteer dalam tahap verifikasi admin');
          } else if(data.status == VolunteerStatus.ACCEPTED.name){
            if(mainController.userRole.group == 'user'){
              await mainController.loadProfile();
            }
            Get.toNamed(Routes.VOLUNTEER);
          } else if (data.status == VolunteerStatus.DEACTIVATED.name){
            showErrorMessage('Status volunteer tidak aktif, hubungi admin untuk info lebih lanjut');
          } else if(data.status == VolunteerStatus.REJECTED.name){
            showErrorMessage('Pengajuan Volunteer tidak di setujui admin');
          }
        }
      }
    );

  }

}
