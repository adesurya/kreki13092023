import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kreki119/app/core/base/base_map_controller.dart';
import 'package:kreki119/app/core/model/type_volunteer.dart';
import 'package:kreki119/app/data/model/response/volunteer_entity.dart';
import 'package:kreki119/app/data/repository/volunteer/volunteer_repository.dart';

import '../../../data/model/form/form_location_place.dart';

class VolunteerMapController extends BaseMapController {

  final VolunteerRepository repository = Get.find(tag: (VolunteerRepository).toString());

  final _data = RxList<VolunteerEntity>();
  List<VolunteerEntity> get volunteerDataList => _data.toList();
  set volunteerDataList(List<VolunteerEntity> data) => _data(data);

  @override
  void onInit() async{
    super.onInit();

    await loadUpdateLocation();

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


  @override
  TypeVolunteer getTypeVolunteer() {
    return TypeVolunteer.VOLUNTEER;
  }

  @override
  loadOnMapCreated({double? latitude, double? longitude}) async{
    getUserMobile().then((user) async{
      FormLocationPlace form = FormLocationPlace();
      form.latitude = latitude ?? user.latitude ?? 0;
      form.longitude = longitude?? user.longitude?? 0;

      var icon = await getBitmapByTypeVolunteer(TypeVolunteer.VOLUNTEER);

      callDataService(repository.getVolunteerByDistance(form),
          onSuccess: (response){
            var dataList = response.data;

            if(dataList!=null){
              volunteerDataList = dataList;

              if(dataList.isNotEmpty){
                for(var item in dataList){
                  logger.d("aap, mark location: (${item.latitude},${item.longitude})");
                  Marker marker = Marker(
                    markerId: MarkerId('${item.latitude},${item.longitude}'),
                    icon: icon,
                    position: LatLng(item.latitude ?? 0.0,
                        item.longitude ?? 0.0),
                    infoWindow: InfoWindow(title: item.fullName ?? 'My Psc',),
                  );

                  markers.value[item.fullName ?? 'Psc'] = marker;
                }
              }
            }
          }
      );
    });


  }
}
