// globale Variablen
import 'package:google_maps_flutter/google_maps_flutter.dart';

bool initialized = false;
int currentPageIndex = 0;
bool notificationPermission = false;
bool activityPermission = false;
String language = 'German';
enum Show { showAll, found, notFound }
enum Gender { perpetrator, victim }
enum Dynamics { showAll, singleOffender, group }
Show show = Show.showAll;
Gender gender = Gender.perpetrator;
Dynamics dynamicOffender = Dynamics.showAll;
bool showDisco = false;
double startValueSlider = 0.0;
double endValueSlider = 5.0;
LatLng startViewMap = const LatLng(53.074980, 8.807080);
double startZoomMap = 15;

// user data variables
int readDetails = 0;
List<String> readDetailsDates = [];
bool mapScreenOpened = false;
bool howItWorksOpened = false;
int clickedOnInstagramLink = 0;
List<String> clickedOnInstagramLinkDates = [];

// sum up all catcalls which have been found and the details have been read (unique)
int sumReadDetailsUnique() {
  int readDetailsUnique = 0;
  for (int i = 1; i < catcallsFound.length; i++) {
    if (catcallsFound[i][20] == "true" || catcallsFound[i][20] == true) {
      readDetailsUnique = readDetailsUnique + 1;
    }
  }
  return readDetailsUnique;
}

List<List<dynamic>> catcallsFound = [
  ["index", "lat", "lang", "ortname", "locationradius", "text", "texteng", "longtext", "longtexteng", "zeit", "gtater", "dtater", "alttater", "gopfer", "dopfer", "altopfer", "altdiff", "link", "imglink", "date", "read"]
];

List<List<dynamic>> csvdata = [];
final List<LatLng> latlang = <LatLng>[];

void addLatLang() {
  double lat;
  String strLat;
  double long;
  String strLong;
  latlang.add(const LatLng(0.0, 0.0));
  for (int j = 1 ; j < csvdata.length ; j++) {
    strLat = csvdata[j][1];
    strLat = strLat.replaceAll(',', '.');
    lat = double.parse(strLat);
    strLong = csvdata[j][2];
    strLong = strLong.replaceAll(',', '.');
    long = double.parse(strLong);
    latlang.add(LatLng(lat, long));
  }
}