import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shalimar/Elements/commom_snackbar_widget.dart';
import 'package:shalimar/Home_Screen/CheckIn_Module/checkin_screen.dart';
import 'package:shalimar/utils/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetOrderDataController extends GetxController {
  var isLoading = false.obs;
  TextEditingController remarkController = TextEditingController();
  var customerCode = "".obs;
  

  fetchData(BuildContext context,List<Map<dynamic, dynamic>> myCart) async {
    try {
      isLoading(true);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var EmployeeId = prefs.getInt('EmployeeId');
      var ActivityID = prefs.getInt('ActivityDetailID');

      var LAT = prefs.getDouble('LAT');
      var LNG = prefs.getDouble('LNG');

      print('Set Order Data API called');

      print("LNG : $LNG");
      print("LAT : $LAT");

      final body = {
        "OrderSource": "Mobile",
        "customercode": customerCode.value,
        "customercodeshipto": customerCode.value,
        // "customercode": "N221000011",
        // "customercodeshipto": "N221000011",
        // "CreatedBy": 358,
        "CreatedBy": EmployeeId,
        "remarks": remarkController.text,
        "ActivityID": ActivityID,
        "UserID": 358,
        // "UserID": EmployeeId,
        "Latitude": LAT,
        "Longitude": LNG,
        "OrderParam": myCart
        // [
        //   {"productcode": "53342628020000", "Qty": 2, "dpl": 600, "mrp": 1200}
        // ]
      };

      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
      };

      print("**********");

      final res = await http.post(Uri.parse(AppConstants.setOrderData),
          body: jsonEncode(body), headers: requestHeaders);

      print(res);

      if (kDebugMode) {
        print("******Set Order Data API called****");
        print(AppConstants.setOrderData);
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
          var result = jsonDecode(res.body);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Success'),
                  content: Text(result['Message']),
                  actions: <Widget>[
                    ElevatedButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.pop(context);
                        Get.off(
                          CheckInPage(),
                        );
                      },
                    ),
                  ],
                );
              });
          // showSnackBar("Success", result['Message'], Colors.greenAccent);
          // Get.off(CheckInPage());
          // prefs.setInt('ActivityDetailID', result['ActivityDetailID']);
          // print("ActivityDetailID: ${result['ActivityDetailID']}");
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
}
