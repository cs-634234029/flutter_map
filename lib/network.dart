import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class NetworkHelper {
  NetworkHelper(this._startLng, this._startLat, this._endLng, this._endLat);

  final double _startLng;
  final double _startLat;
  final double _endLng;
  final double _endLat;

  Future getData() async {
    String? apiKey = "5b3ce3597851110001cf6248127dcc0b6dd948eb8b2457faaaf3256a";
    String? url = "https://api.openrouteservice.org/v2/directions";
    String? journeyMode = "driving-car";

    http.Response response = await http.get(Uri.parse(
        '$url$journeyMode?api_key=$apiKey&start=${_startLng.toStringAsFixed(5)},${_startLat.toStringAsFixed(5)}&end=${_endLng.toStringAsFixed(5)},${_endLat.toStringAsFixed(5)}'));

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      debugPrint(response.statusCode.toString());
    }
  }
}