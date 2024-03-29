import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shalimar/Controller/set_activity_detail_data_controller.dart';
import 'package:shalimar/Elements/commom_snackbar_widget.dart';
import 'package:shalimar/Home_Screen/CheckIn_Module/checkin_screen.dart';
import 'package:shalimar/Model/customer_data_model.dart';
import 'package:shalimar/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerProfileList extends StatefulWidget {
  List<Data> customerList;
  int index;
  BuildContext context;

  CustomerProfileList({
    super.key,
    required this.customerList,
    required this.index,
    required this.context,
  });

  @override
  State<CustomerProfileList> createState() => _CustomerProfileListState();
}

class _CustomerProfileListState extends State<CustomerProfileList> {
  SetActivityDetailDataController controller =
      Get.put(SetActivityDetailDataController());

  String? _currentAddress;
  Position? _currentPosition;
  double? distance;

  Future<void> _getCurrentPosition() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      if (this.mounted) {
        setState(() {
          _currentPosition = position;
          prefs.setDouble('LAT', _currentPosition!.latitude ?? 0.0);
          prefs.setDouble('LNG', _currentPosition!.longitude ?? 0.0);
        });
      }

      distance = calculateDistance(
        prefs.getDouble("LAT"),
        prefs.getDouble("LNG"),
        widget.customerList[widget.index].latitude == null
            ? 0.0
            : widget.customerList[widget.index].latitude,
        widget.customerList[widget.index].longitude == null
            ? 0.0
            : widget.customerList[widget.index].longitude,
      );

      print("Distance: $distance");
    }).catchError((e) {
      debugPrint(e);
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircleAvatar(
                    child: Icon(
                      Icons.person_sharp,
                      size: 50,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 250,
                          child: Text(
                              widget.customerList[widget.index].levelName
                                  .toString(),
                              maxLines: 2,
                              style: TextStyle(
                                  color: blackTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                            "ID:${widget.customerList[widget.index].levelCode.toString()}",
                            style: TextStyle(
                                color: blackTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 250,
                          child: Text(
                            widget.customerList[widget.index].address1
                                .toString(),
                            maxLines: 2,
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Text(
                            distance != null
                                ? "Distance: ${distance!.toInt()} KM Away"
                                : "",
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.fetchData(
                          levelCode: widget.customerList[widget.index].levelCode
                              .toString(),
                          activityID: 8);
                      showSnackBar(
                          "You are CheckedIn at",
                          widget.customerList[widget.index].levelName
                              .toString(),
                          Colors.greenAccent);

                      Get.to(
                        CheckInPage(
                            // levelName: widget
                            //     .customerList[widget.index].levelName
                            //     .toString(),
                            // levelCode: widget
                            //     .customerList[widget.index].levelCode
                            //     .toString(),
                            // levelAddress: widget
                            //     .customerList[widget.index].address1
                            //     .toString(),
                            // isCheckinOnSite: true
                            ),

                        // arguments: [
                        //   widget.customerList[widget.index].levelName,
                        //   widget.customerList[widget.index].levelCode
                        //       .toString(),
                        //   widget.customerList[widget.index].address1
                        //       .toString(),
                        //   true
                        // ]
                      );
                      controller.levelCode.value = widget
                          .customerList[widget.index].levelCode
                          .toString();
                      controller.levelName.value = widget
                          .customerList[widget.index].levelName
                          .toString();
                      controller.levelAddress.value =
                          widget.customerList[widget.index].address1.toString();
                      controller.isCheckinOnSite.value = true;
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "Check in On-site",
                        style: TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.fetchData(
                          levelCode: widget.customerList[widget.index].levelCode
                              .toString(),
                          activityID: 9);
                      showSnackBar(
                          "You are CheckedIn at",
                          widget.customerList[widget.index].levelName
                              .toString(),
                          Colors.greenAccent);

                      Get.to(
                        CheckInPage(
                            // levelName: widget
                            //     .customerList[widget.index].levelName
                            //     .toString(),
                            // levelCode: widget
                            //     .customerList[widget.index].levelCode
                            //     .toString(),
                            // levelAddress: widget
                            //     .customerList[widget.index].address1
                            //     .toString(),
                            // isCheckinOnSite: false
                            ),
                        // arguments: [
                        //   widget.customerList[widget.index].levelName,
                        //   widget.customerList[widget.index].levelCode
                        //       .toString(),
                        //   widget.customerList[widget.index].address1
                        //       .toString(),
                        //   false
                        // ]
                      );
                      controller.levelCode.value = widget
                          .customerList[widget.index].levelCode
                          .toString();
                      controller.levelName.value = widget
                          .customerList[widget.index].levelName
                          .toString();
                      controller.levelAddress.value =
                          widget.customerList[widget.index].address1.toString();
                      controller.isCheckinOnSite.value = false;
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "Check in Off-site",
                        style: TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class CustomerProfileHorizontal extends StatefulWidget {
  const CustomerProfileHorizontal({super.key});

  @override
  State<CustomerProfileHorizontal> createState() =>
      _CustomerProfileHorizontalState();
}

class _CustomerProfileHorizontalState extends State<CustomerProfileHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 80,
                height: 80,
                child: CircleAvatar(
                  child: Icon(
                    Icons.person_sharp,
                    size: 50,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Balaji Traders",
                    style: TextStyle(
                        color: blackTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
                SizedBox(
                  height: 5,
                ),
                Text("ID:N221000086",
                    style: TextStyle(
                        color: blackTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Govt. School Near Village \nSamogarbayana, Bharatput",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
