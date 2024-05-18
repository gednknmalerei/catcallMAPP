import 'package:geofence_service/geofence_service.dart';

// Create a [GeofenceService] instance and set options.
final geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 50,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: true,
    allowMockLocations: false,
    printDevLog: false,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

// This function is to be called when a location services status change occurs
// since the service was started.
void onLocationServicesStatusChanged(bool status) {
  //print('isLocationServicesEnabled: $status');
}

// This function is used to handle errors that occur in the service.
void onError(error) {
  final errorCode = getErrorCodesFromError(error);
  if (errorCode == null) {
    //print('Undefined error: $error');
    return;
  }

  //print('ErrorCode: $errorCode');
}