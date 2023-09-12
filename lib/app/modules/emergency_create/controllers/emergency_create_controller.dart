import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kreki119/app/core/base/base_controller.dart';
import 'package:kreki119/app/data/model/form/Form_emergency.dart';
import 'package:kreki119/app/data/model/form/Form_task.dart';
import 'package:kreki119/app/data/model/response/user_mobile_entity.dart';
import 'package:kreki119/app/data/repository/asset/asset_repository.dart';
import 'package:kreki119/app/data/repository/emergency_mobile/emergency_repository.dart';
import 'package:kreki119/app/modules/main/controllers/main_controller.dart';
import 'package:kreki119/app/routes/app_pages.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../data/services/storage/util_storage.dart';

class EmergencyCreateController extends BaseController {

  final mainController = Get.find<MainController>();

  final AssetRepository assetRepository = Get.find(tag: (AssetRepository).toString());
  final EmergencyRepository emergencyRepository = Get.find(tag: (EmergencyRepository).toString());

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final _emergencyImage = ''.obs;
  String get emergencyImage => _emergencyImage.value;
  set emergencyImage(String val) => _emergencyImage.value = val;
  final _emergencyImageFile = XFile('').obs;
  XFile get emergencyImageFile => _emergencyImageFile.value;
  set emergencyImageFile(XFile val)=> _emergencyImageFile.value = val;

  //use this after upload to api
  final _emergencyUploadPath = ''.obs;
  String get emergencyUploadPath => _emergencyUploadPath.value;
  set emergencyUploadPath(String val) => _emergencyUploadPath.value = val;

  final formKey = GlobalKey<FormState>();

  final _isSubmit = false.obs;
  bool get isSubmit => _isSubmit.value;
  set isSubmit(bool value) => _isSubmit.value = value;




  addPhoto()async{
    XFile? photoFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if(photoFile!=null){
      emergencyImageFile = photoFile;
      emergencyImage = photoFile.path;
    }

  }

  @override
  void onInit() async{
    super.onInit();

    var user = await getUserMobile();
    if(user.fcm.isEmptyOrNull){
      await mainController.loadDataFcm();
    }
  }

  @override
  void onReady() {
    super.onReady();
    //TODO
  }

  @override
  void onClose() {
    //TODO
  }


  submitData() async{
    if(formKey.currentState!.validate()){


      var location = await getLastPositionLocator();
      if(location==null){
        showErrorMessage("mohon aktifkan lokasi di pengaturan untuk melanjutkan");

        return;
      }

      if(emergencyImage.isEmpty){
        showErrorMessage('pilih foto terlebih dahulu');

        return;
      }

      showLoading();

      var user = await getUserMobile();

      var upload = await UtilStorage.uploadEmergencyImage(emergencyImage, user.id.toString());

      upload.snapshotEvents.listen((event) async{
        switch(event.state){
          case TaskState.paused:
            showMessage('Upload pause');
            hideLoading();
            break;
          case TaskState.running:
            var progress = event.bytesTransferred / event.totalBytes;
            logger.d('progress: ${progress*100}');
            break;
          case TaskState.success:
            showMessage('Success upload');
            var url = await event.ref.getDownloadURL();
            submitPhotoAndData(location, user, url);
            hideLoading();
            break;
          case TaskState.canceled:
            submitPhotoAndData(location, user, '');
            hideLoading();
            break;
          case TaskState.error:
            submitPhotoAndData(location, user, '');
            hideLoading();
            break;
        }
      });
    }


  }

  submitPhotoAndData(Position location, UserMobileEntity user, String photoFile){
    FormTask formTask = FormTask(namaKorban: nameController.text,
        latitudePasien: location.latitude, longitudePasien: location.longitude,
        fcmPasien: user.fcm, keterangan: descriptionController.text,
        photobyUser: photoFile
    );

    isSubmit = true;

    callDataService(emergencyRepository.createTaskEmergency(formTask), onSuccess: (value){
      if(value.code! >=200 && value.code! <300){
        mainController.onLoadEmergency();
        Get.back();
        isSubmit = false;
      }

    });
  }

}
