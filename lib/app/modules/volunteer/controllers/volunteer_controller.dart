import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kreki119/app/core/base/base_controller.dart';
import 'package:kreki119/app/core/model/emergency_status.dart';
import 'package:kreki119/app/data/local/preference/preference_manager.dart';
import 'package:kreki119/app/data/model/form/form_location_place.dart';
import 'package:kreki119/app/data/model/response/emergency_mobile_entity.dart';
import 'package:kreki119/app/data/model/response/user_mobile_entity.dart';
import 'package:kreki119/app/modules/main/controllers/main_controller.dart';

import '../../../data/model/response/app_user_entity.dart';
import '../../../data/repository/emergency_mobile/emergency_repository.dart';

class VolunteerController extends BaseController with GetSingleTickerProviderStateMixin{

  final mainController = Get.find<MainController>();

  final EmergencyRepository emergencyRepository =
  Get.find(tag: (EmergencyRepository).toString());

  final RxList<EmergencyMobileEntity> _emergenciesController = RxList.empty();
  List<EmergencyMobileEntity> get emergencyList => _emergenciesController.toList();

  final RxList<EmergencyMobileEntity> _onGoingController = RxList.empty();
  List<EmergencyMobileEntity> get onGoingList => _onGoingController.toList();

  final RxList<EmergencyMobileEntity> _finishedController = RxList.empty();
  List<EmergencyMobileEntity> get finishedList => _finishedController.toList();

  final _firebaseUser = AppUserEntity().obs;
  AppUserEntity get userApp => _firebaseUser.value;
  setAppUser(AppUserEntity val) => _firebaseUser.value = val;

  final _userMobile = UserMobileEntity().obs;
  UserMobileEntity get userMobile => _userMobile.value;
  setUserMobile(UserMobileEntity val) => _userMobile.value =val;

  late TabController tabController;

  final _requestVolunteer = false.obs;
  bool get requestVolunteer => _requestVolunteer.value;
  set requestVolunteer(bool val) => _requestVolunteer.value = val;

  loadRequestVolunteer() async{
    var request = await preferenceManager.getBool(PreferenceManager.keyRequestVolunteer);
    requestVolunteer = request;
  }

  @override
  void onInit()async{
    super.onInit();

    tabController = TabController(length: 2, vsync: this);
    await mainController.loadUpdateLocation();
  }

  @override
  onReady()async{

    setUserMobile(await mainController.getUserMobile());

    // await mainController.loadProfile();

    loadData();
  }

  loadData()async{
    await loadDataEmergency();
    await loadDataOnGoing();
    await loadDataOnFinished();
  }

  loadProfile()async{
    var user = await getUserMobile();
    await loadUserMobile(user.id.toString());
    setUserMobile(await getUserMobile());
  }

  loadDataEmergency()async{
    var user = await getUserMobile();
    FormLocationPlace form = FormLocationPlace(
      latitude: user.latitude,
      longitude: user.longitude
    );

    callDataService(emergencyRepository.getTaskByDistance(form), onSuccess: (response){
      _emergenciesController(response);
    });
  }

  loadDataOnGoing() async{
    callDataService(emergencyRepository.getTaskVolunteer(EmergencyStatus.ACCEPTED), onSuccess: (response){

      if(response.isEmpty){
        callDataService(emergencyRepository.getTaskVolunteer(EmergencyStatus.ON_GOING), onSuccess: (response){
          _onGoingController(response);
        });

        return;
      }
      _onGoingController(response);
    });
  }


  loadDataOnFinished()async{
    callDataService(emergencyRepository.getTaskVolunteer(EmergencyStatus.FINISHED), onSuccess: (response){
      _finishedController(response);
    });
  }

  @override
  void onClose() {
    //TODO
  }
}
