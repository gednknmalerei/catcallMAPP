import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_screen.dart';
import 'globals.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String mapTheme = '';
  final Completer<GoogleMapController> _controller = Completer();
  late ScrollController _scrollController;
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  Uint8List? markerImage;
  final List<String> images = [ 'assets/marker-blue.png', 'assets/marker-grey-opacity.png', 'assets/marker-grey.png',
    'assets/marker-yellow.png', 'assets/marker-blue-group.png', 'assets/marker-grey-group.png', 'assets/marker-yellow-group.png'];
  final List<Marker> _markers = <Marker>[];
  double widthInfoWindow = 150.0;

  getLanguageSpecific() {
    if (language == 'English') {
      widthInfoWindow = 110.0;
    }
  }

  late CameraPosition _kGooglePlex;

  Future<Uint8List> getBytesFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight:width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  String getDaytime(double value) {
    String mo = 'morgens';
    String vm = 'vormittags';
    String m = 'mittags';
    String nm = 'nachmittags';
    String a = 'abends';
    String n = 'nachts';

    if (language == 'English') {
      mo = 'early morning';
      vm = 'morning';
      m = 'noon';
      nm = 'afternoon';
      a = 'evening';
      a = 'evening';
      n = 'night';
    }

    int roundedValue = value.round();

    if (roundedValue == 0) {
      return mo;
    } else if (roundedValue == 1) {
      return vm;
    } else if (roundedValue == 2) {
      return m;
    } else if (roundedValue == 3) {
      return nm;
    } else if (roundedValue == 4) {
      return a;
    } else if (roundedValue == 5) {
      return n;
    } else {
      return '';
    }
  }

  Future<void> setMapScreenOpenedTrue () async {
    if (!mapScreenOpened) {
      mapScreenOpened = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mapScreenOpened', true);
    }
  }

  @override
  void initState() {
    super.initState();
    _kGooglePlex = CameraPosition(
      target: startViewMap,
      zoom: startZoomMap,
    );
    startViewMap = const LatLng(53.074980, 8.807080);
    startZoomMap = 15;
    _scrollController = ScrollController();
    DefaultAssetBundle.of(context).loadString('assets/maps-styling.json').then((value){
      mapTheme = value;
    });
    loadData();
    getLanguageSpecific();
    setMapScreenOpenedTrue();
  }

  // passende Marker laden je nach Filter
  loadData() async {
    _markers.clear();
    int markerSize = 75;
    int markerSizeGroup = 100;

    bool catcallFound(dynamic targetValue) {
      for (var row in catcallsFound) {
        if (row.isNotEmpty && row[0] == targetValue) {
          return true;
        }
      }
      return false;
    }

    for(int i = 1 ; i < csvdata.length ; i++) {
      late Uint8List markerIcon;
      bool addTime = false;
      bool addShow = false;
      bool addDynamics = false;
      markerSize = 75;
      markerSizeGroup = 100;

      if (latlang[i] == startViewMap) {
        markerSize = 100;
        markerSizeGroup = 130;
      }

      if (gender == Gender.perpetrator ) {
        if (csvdata[i][10] == 'm' && csvdata[i][11] == 'e') {
          markerIcon = await getBytesFromAssets(images[0], markerSize);
        } else if (csvdata[i][10] == 'm' && csvdata[i][11] == 'g') {
          markerIcon = await getBytesFromAssets(images[4], markerSizeGroup);
        } else if (csvdata[i][10] == 'w' && csvdata[i][11] == 'e') {
          markerIcon = await getBytesFromAssets(images[3], markerSize);
        } else if (csvdata[i][10] == 'w' && csvdata[i][11] == 'g') {
          markerIcon = await getBytesFromAssets(images[6], markerSizeGroup);
        } else if (csvdata[i][10] == 'NAN' && csvdata[i][11] == 'g') {
          markerIcon = await getBytesFromAssets(images[5], markerSizeGroup);
        } else {
          markerIcon = await getBytesFromAssets(images[2], markerSize);
        }
      } else if (gender == Gender.victim) {
        if (csvdata[i][13] == 'm') {
          markerIcon = await getBytesFromAssets(images[0], markerSize);
        } else if (csvdata[i][13] == 'w') {
          markerIcon = await getBytesFromAssets(images[3], markerSize);
        } else {
          markerIcon = await getBytesFromAssets(images[2], markerSize);
        }
      }

      // turn daytime string to int
      dynamic daytime = 6;

      switch(csvdata[i][9]) {
        case 'mo':
          daytime = 0;
          break;
        case 'vm':
          daytime = 1;
          break;
        case 'm':
          daytime = 2;
          break;
        case 'nm':
          daytime = 3;
          break;
        case 'a':
          daytime = 4;
          break;
        case 'n':
          daytime = 5;
          break;
        case 'nm, a':
          daytime = [3, 4];
        case 'a, n':
          daytime = [4, 5];
        case 'm, nm':
          daytime = [2, 3];
      }

      // is daytime equal to the one chosen by the user?
      if (startValueSlider.round() == 0 && endValueSlider.round() == 5) {
        addTime = true;
      }

      if (daytime is int) {
        if (startValueSlider.round() <= daytime && endValueSlider.round() >= daytime) {
          addTime = true;
        }
      } else if (daytime is List<int>) {
        for (int i = 0; i < daytime.length; i++) {
          if (startValueSlider.round() <= daytime[i] && endValueSlider.round() >= daytime[i]) {
            addTime = true;
          }
        }
      }

      // is catcallfound equal to the filter option chosen by the user
      int id = csvdata[i][0];
      if (show == Show.showAll) {
        addShow = true;
      } else if (catcallFound(id) && show == Show.found) {
        addShow = true;
      } else if (!catcallFound(id) && show == Show.notFound) {
        addShow = true;
      } else {
        addShow = false;
      }

      if (dynamicOffender == Dynamics.showAll) {
        addDynamics = true;
      } else if (dynamicOffender == Dynamics.group && csvdata[i][11] == 'g') {
        addDynamics = true;
      } else if (dynamicOffender == Dynamics.singleOffender && csvdata[i][11] == 'e') {
        addDynamics = true;
      }


      // add marker if addTime and addShow are true
      if (addTime && addShow && addDynamics) {
        String infoTitle = 'noch nicht gefunden';
        if (language == 'English') {
          infoTitle = 'not found yet';
        }
        if (catcallFound(csvdata[i][0])) {
          infoTitle = '';
        }

        _markers.add(
          Marker(markerId: MarkerId(csvdata[i][0].toString()),
              position: latlang[i],
              icon: BitmapDescriptor.fromBytes(markerIcon),
              onTap: () async {
                // save click in user data
                readDetails = readDetails + 1;

                // save timestamp of click on details
                DateTime timeStamp = DateTime.now();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                // get last saved list of dates and convert to List of Type DateTime
                List<String>? savedDateStrings = prefs.getStringList('readDetailsDates');
                if (savedDateStrings != null) {
                  readDetailsDates = savedDateStrings.toList();
                }
                // add timestamp
                readDetailsDates.add(timeStamp.toString());
                // save new list of readDetailsDates in SharedPreferences
                await prefs.setStringList('readDetailsDates', readDetailsDates);

                await prefs.setInt('readDetails', readDetails);

                int? rowOfCatcall;
                for (int j = 1; j < catcallsFound.length; j++) {
                  if (catcallsFound[j][0] == i) {
                    rowOfCatcall = j;
                  }
                }
                if (rowOfCatcall != null) {
                  catcallsFound[rowOfCatcall][20] = true;
                  String catcallsCsv = const ListToCsvConverter().convert(catcallsFound);
                  await prefs.setString('lastStateCsv', catcallsCsv);
                }

                if (catcallFound(csvdata[i][0])) {
                  int catcallID = csvdata[i][0];

                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          id: catcallID,
                        ),
                      ),
                    );
                  }
                } else {
                  _customInfoWindowController.addInfoWindow!(
                    Container(
                      alignment: Alignment.center,
                      height: 100,
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B6FF),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        infoTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    latlang[i],
                  );
                }
              }
          ),
        );
      }
    }

    setState(() {});
  }

  getGoogleMapsPadding() {
    if (Platform.isAndroid) {
      return const EdgeInsets.only(bottom: 25, top: 100);
    } else {
      return const EdgeInsets.only(bottom: 25);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B2042),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: Set<Marker>.of(_markers),
            style: mapTheme,
            onMapCreated: (GoogleMapController controller) {
              _customInfoWindowController.googleMapController = controller;
              _controller.complete(controller);
            },
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            padding: getGoogleMapsPadding(),
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 25,
            width: widthInfoWindow,
            offset: 28,
          ),
          NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (_scrollController.hasClients && notification is OverscrollNotification && notification.overscroll > 0 && _scrollController.position.pixels == 0) {
                  return true;
                }
                return false;
              },
              child: DraggableScrollableSheet(
                  initialChildSize: 0.4,
                  minChildSize: 0.03,
                  maxChildSize: 0.55,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          controller: scrollController,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF6F4779),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, right: 22, bottom: 10, left: 22),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 34.0, bottom: 10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        myHeadline(
                                            textGer: 'Anzeigen',
                                            textEng: 'Show'),
                                        Padding(
                                            padding: const EdgeInsets.only(bottom: 20.0),
                                            child: Column(
                                              children: [
                                                myRadioButton<Show>(
                                                  currentValue: show,
                                                  value: Show.showAll,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      show = value!;
                                                      loadData();
                                                    });
                                                  },
                                                  textGer: 'alle',
                                                  textEng: 'all',
                                                ),
                                                myRadioButton<Show>(
                                                  currentValue: show,
                                                  value: Show.found,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      show = value!;
                                                      loadData();
                                                    });
                                                  },
                                                  textGer: 'von mir gefunden',
                                                  textEng: 'found by me',
                                                ),
                                                myRadioButton<Show>(
                                                  currentValue: show,
                                                  value: Show.notFound,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      show = value!;
                                                      loadData();
                                                    });
                                                  },
                                                  textGer: 'noch nicht gefunden',
                                                  textEng: 'not found yet',
                                                ),
                                              ],
                                            )
                                        ),
                                        myHeadline(
                                            textGer: 'Geschlecht der/des...',
                                            textEng: 'Gender of the...'),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 20.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 50,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      myRadioButton<Gender>(
                                                        currentValue: gender,
                                                        value: Gender.perpetrator,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            gender = value!;
                                                            loadData();
                                                          });
                                                        },
                                                        textGer: 'Täter(s)',
                                                        textEng: 'perpetrator',
                                                      ),
                                                      myRadioButton<Gender>(
                                                        currentValue: gender,
                                                        value: Gender.victim,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            gender = value!;
                                                            loadData();
                                                          });
                                                        },
                                                        textGer: 'Opfer(s)',
                                                        textEng: 'victim',
                                                      ),
                                                    ]
                                                ),
                                              ),
                                              Expanded(
                                                flex: 50,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      myLabel(
                                                        color: 'blue',
                                                        textGer: 'männlich',
                                                        textEng: 'male',
                                                      ),
                                                      myLabel(
                                                        color: 'yellow',
                                                        textGer: 'weiblich',
                                                        textEng: 'female',
                                                      ),
                                                      myLabel(
                                                        color: 'grey',
                                                        textGer: 'nicht bekannt',
                                                        textEng: 'unknown',
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        myHeadline(
                                            textGer: 'Einzeltäter:in oder Gruppe?',
                                            textEng: 'Single offender or group?'),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 20.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 50,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      myRadioButton<Dynamics>(
                                                        currentValue: dynamicOffender,
                                                        value: Dynamics.showAll,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            dynamicOffender = value!;
                                                            loadData();
                                                          });
                                                        },
                                                        textGer: 'Alle anzeigen',
                                                        textEng: 'show all',
                                                      ),
                                                      myRadioButton<Dynamics>(
                                                        currentValue: dynamicOffender,
                                                        value: Dynamics.singleOffender,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            dynamicOffender = value!;
                                                            loadData();
                                                          });
                                                        },
                                                        textGer: 'Einzeltäter:in',
                                                        textEng: 'single offender',
                                                      ),
                                                      myRadioButton<Dynamics>(
                                                        currentValue: dynamicOffender,
                                                        value: Dynamics.group,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            dynamicOffender = value!;
                                                            loadData();
                                                          });
                                                        },
                                                        textGer: 'Gruppe',
                                                        textEng: 'group',
                                                      ),
                                                    ]
                                                ),
                                              ),
                                              Expanded(
                                                flex: 50,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      myLabel(
                                                        color: 'blue-group',
                                                        textGer: 'männliche Gruppe',
                                                        textEng: 'male group',
                                                      ),
                                                      myLabel(
                                                        color: 'yellow-group',
                                                        textGer: 'weibliche Gruppe',
                                                        textEng: 'female group',
                                                      ),
                                                      myLabel(
                                                        color: 'grey-group',
                                                        textGer: 'gemischte / unbekannte Gruppe',
                                                        textEng: 'mixed / unknown group',
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        myHeadline(
                                            textGer: 'Tageszeit',
                                            textEng: 'Daytime'),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6.0, bottom: 26.0),
                                          child: SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              trackHeight: 12.0,
                                              activeTrackColor: const Color(0xFFF0B6FF),
                                              inactiveTrackColor: const Color(0xFF3B2042),
                                              thumbColor: const Color(0xFFF0B6FF),
                                              overlayColor: Colors.transparent,
                                              overlayShape: SliderComponentShape.noOverlay,
                                              activeTickMarkColor: const Color(0xFF3B2042),
                                              inactiveTickMarkColor: const Color(0xFF6F4779),
                                              valueIndicatorColor: const Color(0xFF3B2042),
                                              valueIndicatorTextStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                            ),
                                            child: RangeSlider(
                                              min: 0.0,
                                              max: 5.0,
                                              divisions: 5,
                                              labels: RangeLabels(
                                                getDaytime(startValueSlider),
                                                getDaytime(endValueSlider),
                                              ),
                                              values: RangeValues(startValueSlider, endValueSlider),
                                              onChanged: (values) {
                                                setState(() {
                                                  startValueSlider = values.start;
                                                  endValueSlider = values.end;
                                                  loadData();
                                                });
                                              },

                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: Container(
                            alignment: Alignment.center,
                            height: 24,
                            color: const Color(0xFF6F4779),
                            child: Image.asset(
                              'assets/topBar.png',
                              width: 130,
                            ),
                          ),
                        )
                      ],
                    );
                  },
              ),
            ),
        ],
      ),

    );
  }

  Widget myHeadline({
    required String textGer,
    required String textEng}) {
    String text = textGer;
    if (language == 'English') {
      text = textEng;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget myRadioButton<T> ({
    required T currentValue,
    required T value,
    required ValueChanged<T?> onChanged,
    required String textGer,
    required String textEng,
  }) {
    String text = textGer;
    if (language == 'English') {
      text = textEng;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
      child: Row(
        children: [
          SizedBox(
          height: 24.0,
          width: 20.0,
            child: Radio(
              fillColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                return Colors.white;
              },),
              value: value,
              groupValue: currentValue,
              onChanged: onChanged,
              activeColor: Colors.white,
              hoverColor: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget myLabel({
    required String color,
    required String textGer,
    required String textEng,
  }) {
    assert(['blue', 'yellow', 'grey', 'grey-opacity', 'blue-group', 'yellow-group', 'grey-group'].contains(color.toLowerCase()),
    'Ungültige Farbe: $color. Erlaubte Farben sind: blue, yellow, grey, grey-opacity, blue-group, yellow-group, grey-group.');

    String imageURL = '';
    String text = textGer;
    if (language == 'English') {
      text = textEng;
    }

    if (color == 'blue') {
      imageURL = 'assets/marker-blue.png';
    } else if (color == 'yellow') {
      imageURL = 'assets/marker-yellow.png';
    } else if (color == 'grey-opacity') {
      imageURL = 'assets/marker-grey-opacity.png';
    } else if (color == 'blue-group') {
      imageURL = 'assets/marker-blue-group.png';
    } else if (color == 'yellow-group') {
      imageURL = 'assets/marker-yellow-group.png';
    } else if (color == 'grey-group') {
      imageURL = 'assets/marker-grey-group.png';
    } else {
      imageURL = 'assets/marker-grey.png';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Row(
        children: [
          Image.asset(
            imageURL,
            width: 18,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            )
          ),
        ],
      ),
    );
  }

}

