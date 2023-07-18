import 'dart:async';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:latlong2/latlong.dart';

class MapControllers extends GetxController {
  List<Position> positions = [];
  RxBool isRunning = false.obs;
  late LatLng start;
  late LatLng end;
  int tick = 0;

  // * starts from here
  void startTracking(LatLng start, LatLng end) async {
    log('startTracking called');
    bool permissions = await handleLocationPermission();
    if (!permissions) return;
    log('Permissions are ok');
    this.start = start;
    this.end = end;
    isRunning.value = true;
    startPeriodicFunction();
  }

  startStream() {
    LocationSettings custom = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: custom).listen((position) {
      log("Stream position: ${position.latitude}, ${position.longitude}");
    });
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    log("handleLocationPermission called");
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Location services are disabled. Please enable the services");
      return false;
    }

    log("Location services are enabled");

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permissions are denied. Please enable the permissions");
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location permissions are permanently denied, we cannot request permissions.");
      return false;
    }

    return true;
  }

  void stopTracking() {
    // send completed status via API
    isRunning.value = false;
  }

  void startPeriodicFunction() {
    log('startPeriodicFunction called');
    Timer.periodic(const Duration(seconds: 5), (_) async {
      tick++;
      log("Tick $tick");
      if (!isRunning.value) {
        _.cancel();
      } else {
        log("Getting current location for tick $tick");
        Position? currentPosition = await getCurrentLocation();
        log("Got current location for tick $tick");
        if (currentPosition != null) {
          // Add the current position to the list
          positions.add(currentPosition);

          // If there are more than 1 positions, call the distance logic function
          if (positions.length > 1) {
            log("Distance logic called for tick $tick");
            await distanceLogic(currentPosition, positions[positions.length - 2]);
          }
        }
      }
    });
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      log('Error getting current location: $e');
      return null;
    }
  }

  distanceLogic(Position currentPosition, Position prevPosition) async {
    double distance = distanceCalculator(
      LatLng(currentPosition.latitude, currentPosition.longitude),
      LatLng(prevPosition.latitude, prevPosition.longitude),
    );
    double distanceFromEnd = distanceCalculator(
      LatLng(currentPosition.latitude, currentPosition.longitude),
      end,
    );

    log('Distance: $distance');
    log('Distance from end: $distanceFromEnd');
    await statusSender("ok");
    log("--------------------");

    if (distanceFromEnd < 2500) {
      // Send near to destination report
    }

    if (distanceFromEnd < 100) {
      // Send reached destination report
      // stopTracking();
    }

    if (distance < 2500) {
      // Send slow report
    }
  }

  statusSender(String message) async {
    if (await isConnected()) {
      // send the status via API
      // if gets an error for any reason, store it in local db
      log("Connected for tick $tick");
    } else {
      // store it in local db
      log("Not connected");
    }
  }

  Future<bool> isConnected() async {
    return await InternetConnectionChecker().hasConnection;
  }

  double distanceCalculator(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);
  }
}
