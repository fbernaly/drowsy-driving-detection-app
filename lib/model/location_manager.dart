import 'package:daylight/daylight.dart';
import 'package:location/location.dart';

class LocationManager {
  Location location = Location();

  Future<LocationData?> getLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    LocationData locationData = await location.getLocation();
    return locationData;
  }

  Future<DaylightResult?> getDailyResults() async {
    final locationData = await getLocation();

    if (locationData == null ||
        locationData.latitude == null ||
        locationData.longitude == null) {
      return null;
    }

    final now = DateTime.now();
    final daylightLocation =
        DaylightLocation(locationData.latitude!, locationData.longitude!);
    final daylightCalculator = DaylightCalculator(daylightLocation);
    final dailyResults = daylightCalculator.calculateForDay(now);
    return dailyResults;
  }
}
