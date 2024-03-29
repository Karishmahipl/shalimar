import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shalimar/Elements/commom_snackbar_widget.dart';
import 'package:shalimar/Services/plant_service.dart';
import 'package:shalimar/utils/consts.dart';

import '../Model/plant_data_model.dart';

class PlantDataController extends GetxController {
  var isLoading = false.obs;
  PlantDataModel? plantDataModel;
  var plantID = 0;
  var plantList = <Data>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    fetchPlantData();
    getPlantData();
  }

  fetchPlantData() async {
    try {
      isLoading(true);
      print('Plant Data api called');

      final body = {
        "PlantId": 0,
      };

      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
      };

      print("**********");

      final res = await http.post(Uri.parse(AppConstants.getPlantData),
          body: jsonEncode(body), headers: requestHeaders);

      print(res);

      if (kDebugMode) {
        print("******Plant Data Api Call****");
        print(AppConstants.getPlantData);
        print(requestHeaders);
        print(body);
        print(res.statusCode);
      }

      var data = json.decode(res.body);

      if (kDebugMode) {
        print(data);
      }

      if (res.statusCode == 200) {
        if (data != null) {
          if (data['Data'] != null) {
            var result = jsonDecode(res.body);
            plantDataModel = PlantDataModel.fromJson(result);
            // plantList.add(data['Data']);
            // print("plantData : $plantList");
          } else {
            showSnackBar("Error!!", data['Message'], Colors.redAccent);
            return null;
          }
        } else {
          showSnackBar("Error!!", data['Message'], Colors.redAccent);
          return null;
        }
      } else {
        showSnackBar("Error!!", data['Message'], Colors.redAccent);
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error while getting data is $e');
      }
    } finally {
      isLoading(false);
    }
  }

  getPlantData() async {
    print("Get   plant****");
    isLoading(true);
    var fetchedPlant = await PlantService.getPlant();
    isLoading(false);

    if (fetchedPlant != null) {
      plantList.value = fetchedPlant.data ?? [];
      print('Plant Length : ${plantList.length}');
    }
  }

  
}
