import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import "package:http/http.dart" as http;
import 'package:wheather_task/constants/api_key.dart';
import 'package:wheather_task/logic/models/weather_model.dart';


class CallToApi {
  Future<WeatherModel> callWeatherAPi(bool current, String cityName,BuildContext context) async {
    try {
      Position currentPosition = await getGeoLocationPosition(context);
      if (current) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            currentPosition.latitude, currentPosition.longitude);

        Placemark place = placemarks[0];
        cityName = place.locality!;
      }

      var url = Uri.https('api.openweathermap.org', '/data/2.5/weather',
          {'q': cityName, "units": "metric", "appid": apiKey});
      final http.Response response = await http.get(url);
      log('location response ${response.body.toString()}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = json.decode(response.body);
        return WeatherModel.fromMap(decodedJson);
      } else {
        throw Exception('your live location not found');
      }
    } catch (e) {
      throw Exception('your live location not found');
    }
  }
  Future<Position> getGeoLocationPosition(BuildContext context) async {
    // bool serviceEnabled;
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      // CustomSnackBar.showSnackBar('Location Permission'.tr, 'click on permission and enable location permission'.tr);
      ///appExt.push(const Home(), context);
      await Future.delayed(const Duration(seconds: 2)).then((value)async{
        await Geolocator.openLocationSettings();
      });
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        //CustomSnackBar.showSnackBar('Location Permission'.tr, 'click on permission and enable location permission'.tr);
        //appExt.push(const Home(), context);
        await Future.delayed(const Duration(seconds: 2)).then((value)async{
          await Geolocator.openLocationSettings();
        });
      }
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

  }

}