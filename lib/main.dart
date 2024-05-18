import 'dart:async';
import 'dart:io' show Platform;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'geofence.dart';
import 'map_screen.dart';
import 'list_screen.dart';
import 'detail_screen.dart';
import 'menu_screens.dart';
import 'globals.dart';
import 'onboarding.dart';

int idNot = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
StreamController<String?>.broadcast();

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers an App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
      Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = CatcallApp.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
    initialRoute = DetailScreen.routeName;
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');

  final List<DarwinNotificationCategory> darwinNotificationCategories =
  <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationStream.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
    notificationCategories: darwinNotificationCategories,
  );

  final LinuxInitializationSettings initializationSettingsLinux =
  LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  runApp(
    MaterialApp(
      initialRoute: initialRoute,
      routes: <String, WidgetBuilder>{
        CatcallApp.routeName: (_) => CatcallApp(notificationAppLaunchDetails: notificationAppLaunchDetails),
        DetailScreen.routeName: (_) => DetailScreen(id: int.parse(selectedNotificationPayload!)),
      },
    ));
}

class CatcallApp extends StatelessWidget {
  CatcallApp({
    super.key,
    this.notificationAppLaunchDetails,
  });
  final OnboardingManager _onboardingManager = OnboardingManager();
  static const String routeName = '/';
  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  @override
  Widget build(BuildContext context) {
    String backgroundNotification = "CatcallMAPP erkennt Catcalls, wenn die App im Hintergrund geöffnet ist.";
    String backgroundNotTitle = "CatcallMAPP";

    if(language == "English") {
      backgroundNotification = "CatcallMAPP recognizes catcalls when the app is open in the background.";
    }

    return MaterialApp(
      home: WillStartForegroundTask(
        onWillStart: () async {
          // You can add a foreground task start condition.
          return geofenceService.isRunningService;
        },
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription: 'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: const ForegroundTaskOptions(),
        notificationTitle: backgroundNotTitle,
        notificationText: backgroundNotification,
        child: FutureBuilder(
          future: _onboardingManager.isFirstTime(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              bool isFirstTime = snapshot.data as bool;

              if (isFirstTime) {
                return const OnboardingScreen();
              } else {
                return HomeScreen(notificationAppLaunchDetails: notificationAppLaunchDetails);
              }
            }
          },
        ),
      ),
      title: 'Catcalls Bremen',
      theme: ThemeData(
        fontFamily: 'NotoSans',
        primarySwatch: Colors.purple,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      routes: {
        '/language': (context) => const MenuScreen1(),
        '/howitworks': (context) => const MenuScreen2(),
        '/about': (context) => const MenuScreen3(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.notificationAppLaunchDetails,
  });
  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();
  Geofence? curGeofence;
  final geofenceList = <Geofence>[];
  late final List<Widget> _screens = [
    const ListScreen(),
    const MapScreen(),
  ];

  String getCurrentDate() {
    // Aktuelles Datum
    DateTime now = DateTime.now();
    // Datum im Format (z.B. "yyyy-MM-dd HH:mm:ss") extrahieren
    String formattedDateTime = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    return formattedDateTime;
  }

  double getHeight() {
    if (Platform.isAndroid) {
      return 60.0;
    } else {
      return 40.0;
    }
  }
  EdgeInsets getPadding() {
    if (Platform.isAndroid) {
      return const EdgeInsets.only(top: 0.0);
    } else {
      return const EdgeInsets.only(top: 10.0);
    }
  }

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    if (!mounted) return;
    // wenn in einen Geofence eingetreten wird
    if (geofenceStatus.toString() == 'GeofenceStatus.ENTER') {
      curGeofence = geofence;
      // int i = index des Catcalls
      int i = csvdata[int.parse(curGeofence!.id)][0];
      bool alreadyAdded = false;
      // iterieren durch catcallsFound und index vergleichen mit der Liste aller Catcalls
      for (int j = 1 ; j < catcallsFound.length ; j++) {
        if (catcallsFound[j][0] == i) {
          // wenn index schon in catcallsFound, already added = true
          alreadyAdded = true;
        }
      }
      // catcall nur hinzufügen + Benachrichtigung senden, wenn noch nicht hinzugefügt
      if (!alreadyAdded) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        catcallsFound.add([...csvdata[int.parse(curGeofence!.id)], getCurrentDate(), false]);
        String catcallsCsv = const ListToCsvConverter().convert(catcallsFound);
        await prefs.setString('lastStateCsv', catcallsCsv);
        await _showNotification();
        setState(() {
          _screens[0] = const ListScreen();
        });
      }
    }
    _geofenceStreamController.sink.add(geofence);
  }

  addToGeofence() async {
    double latGeo;
    double longGeo;
    double radGeo;
    for (int i = 1 ; i < csvdata.length ; i++) {
      latGeo = latlang[i].latitude;
      longGeo = latlang[i].longitude;
      radGeo = csvdata[i][4].toDouble();
      geofenceList.add(Geofence(
        id: '$i',
        latitude: latGeo,
        longitude: longGeo,
        radius: [
          GeofenceRadius(id: 'radius_{$radGeo}m', length: radGeo),
        ],
      ));
    }
  }

  // Anzeigen der Benachrichtigung, wenn sich der Nutzer an einem bestimmten Ort befindet
  Future<void> _showNotification() async {
    String notificationTitle = csvdata[int.parse(curGeofence!.id)][3];
    String notificationText = csvdata[int.parse(curGeofence!.id)][5];
    String i = csvdata[int.parse(curGeofence!.id)][0].toString();
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('not1', 'Notification',
        channelDescription: 'Normal Notification',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );
    const DarwinNotificationDetails macOSNotificationDetails = DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: macOSNotificationDetails,
    );
    if (language == 'English') {
      notificationText = csvdata[int.parse(curGeofence!.id)][6];
    }
    if (curGeofence?.id != null) {
      await flutterLocalNotificationsPlugin.show(
          idNot++, notificationTitle, notificationText, notificationDetails,
          payload: i);
    }
  }

  Future<void> _initialize() async {
    await loadLastState();
    await loadCSV();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      geofenceService.addLocationServicesStatusChangeListener(onLocationServicesStatusChanged);
      geofenceService.addStreamErrorListener(onError);
      geofenceService.start(geofenceList).catchError(onError);
    });
    await _checkAndShowPermissionDialog();
    addToGeofence();
    const ListScreen listScreen = ListScreen();
    const MapScreen mapScreen = MapScreen();
    if (mounted) {
      setState(() {
        _screens[0] = listScreen;
        _screens[1] = mapScreen;
        initialized = true;
      });
    }
    _configureSelectNotificationSubject();
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  loadCSV() async {
    if (!mounted) {
      return;
    }
    final rawData = await rootBundle.loadString("assets/catcall_data.csv");
    List<List<dynamic>> listData =
    const CsvToListConverter().convert(rawData, fieldDelimiter: ';');
    if (mounted) {
      setState(() {
        csvdata = listData;
      });
    }
    addLatLang();
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
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

      int i = int.parse(payload!);
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

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              id: i,
            ),
          ),
        );
      }
    });
  }

  _checkAndShowPermissionDialog() async {
    // Überprüfen ob alle Berechtigungen gegeben sind
    bool hasPermissions = await _checkPermissions();

    // Wenn Berechtigungen fehlen, AlertDialog anzeigen
    if (!hasPermissions) {
      await _showPermissionAlertDialog();
    }
  }

  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.status != PermissionStatus.granted || await Permission.notification.status != PermissionStatus.granted || await Permission.locationAlways.status != PermissionStatus.granted) {
        return false;
      } else {
        return true;
      }
    } else if (Platform.isIOS) {
      if (await Permission.sensors.status != PermissionStatus.granted || await Permission.notification.status != PermissionStatus.granted || await Permission.locationAlways.status != PermissionStatus.granted) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  Future<void> _showPermissionAlertDialog() {
    String title = '';
    String text = '';

    void createText() async {
      String permissionsMissing = '';
      String activity = '';
      String notification = '';
      String location = '';
      String permissionsMissingEng = '';
      String activityEng = '';
      String notificationEng = '';
      String locationEng = '';
      int count = 0;

      if (await Permission.locationAlways.status != PermissionStatus.granted) {
        location = 'Standort (immer abrufen)';
        locationEng = 'Location (always accessible)';
        count++;
      }
      if (Platform.isAndroid) {
        if (await Permission.activityRecognition.status != PermissionStatus.granted) {
          if (count == 1) {
            activity = ', physische Aktivität';
            activityEng = ', physical activity';
          } else {
            activity = 'physische Aktivität';
            activityEng = 'physical activity';
          }
          count++;
        }
      } else if (Platform.isIOS) {
        if (await Permission.sensors.status != PermissionStatus.granted) {
          if (count == 1) {
            activity = ', physische Aktivität';
            activityEng = ', physical activity';
          } else {
            activity = 'physische Aktivität';
            activityEng = 'physical activity';
          }
          count++;
        }
      }
      if (await Permission.notification.status != PermissionStatus.granted) {
        if (count >= 1) {
          notification = ', Benachrichtigungen';
          notificationEng = ', notifications';
        } else {
          notificationEng = 'notifications';
          notification = 'Benachrichtigungen';
        }
        count++;
      }
      permissionsMissing = '($location$activity$notification)';
      permissionsMissingEng = '($locationEng$activityEng$notificationEng)';

      title = 'Berechtigungen erforderlich';
      text = 'Bitte gewähre die erforderlichen Berechtigungen $permissionsMissing. Ansonsten kann die App nicht richtig verwendet werden.';

      getText() {
        if (language == 'English') {
          title = 'Permissions required';
          text = 'Please grant the required permissions $permissionsMissingEng. Otherwise the app cannot be used correctly.';
        }
      }

      getText();

    }

    createText();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (!notificationPermission) {
                  final statusNotification = await Permission.notification.request();
                  if (statusNotification == PermissionStatus.granted) {
                    notificationPermission = true;
                  }
                }
                if (!activityPermission) {
                  if (Platform.isAndroid) {
                    final statusActivity = await Permission.activityRecognition.request();
                    if (statusActivity == PermissionStatus.granted) {
                      activityPermission = true;
                    }
                  } else if (Platform.isIOS) {
                    final statusActivity = await Permission.sensors.request();
                    if (statusActivity == PermissionStatus.granted) {
                      activityPermission = true;
                    }
                  }
                }
                final status = await Permission.locationWhenInUse.status;
                if (!status.isGranted) {
                  final status = await Permission.locationWhenInUse.request();
                  if (status.isGranted) {
                    await Permission.locationAlways.request();
                  }
                }
                if (!notificationPermission || !activityPermission || await Permission.locationAlways.status != PermissionStatus.granted) {
                  openAppSettings();
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String menuLang = 'Sprache ändern';
    String menuHowitworks = 'Wie funktioniert\'s?';
    String menuAbout = 'Über CatcallMAPP';

    if (language == 'English') {
      menuLang = 'Change language';
      menuHowitworks = 'How it works';
      menuAbout = 'About CatcallMAPP';
    }

    List<String> activeIcons = ['assets/listview-thick.png', 'assets/map.png'];
    List<String> inactiveIcons = ['assets/listview.png', 'assets/map-stroke.png'];

    // get the correct icon based on the current page index
    Widget getIcon(int index) {
      bool isActive = index == currentPageIndex;
      String iconPath = isActive ? activeIcons[index] : inactiveIcons[index];

      return Padding(
        padding: getPadding(),
        child: Image.asset(
          iconPath,
          height: 24,
          width: 24,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3B2042),
      body: initialized
      ? Scaffold(
          backgroundColor: const Color(0xFF3B2042),
          body: Stack(
            children: [
              _screens[currentPageIndex],
              Positioned(
                top: 60,
                right: 0,
                child: PopupMenuTheme(
                  data: const PopupMenuThemeData(
                    color: Color(0xFFF0B6FF),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const ImageIcon(
                      AssetImage('assets/menu.png'),
                      color: Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Hier den gewünschten BorderRadius einstellen
                    ),
                    offset: const Offset(-40, 0),
                    onSelected: (value) {
                      Navigator.pushNamed(context, value);
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: '/language',
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(menuLang),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: '/howitworks',
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(menuHowitworks),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: '/about',
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(menuAbout),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: const Color(0xFFF0B6FF),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            indicatorColor: Colors.transparent,
            overlayColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.transparent;
                }
                return Colors.transparent;
              },
            ),
            height: getHeight(),
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            destinations: <Widget>[
              NavigationDestination(
                icon: getIcon(0),
                label: '',
              ),
              NavigationDestination(
                icon: getIcon(1),
                label: '',
              ),
            ],
          ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> loadLastState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Rufe CSV-Datei ab
    String catcallsCsv = prefs.getString('lastStateCsv') ?? "";

    // Dekodiere die CSV-Datei in die Liste zurück
    List<List<dynamic>> loadedCatcallsFound = const CsvToListConverter().convert(catcallsCsv);

    if (loadedCatcallsFound.isNotEmpty) {
      setState(() {
        catcallsFound = loadedCatcallsFound;
      });
    }

    language = prefs.getString('language') ?? 'German';
    readDetails = prefs.getInt('readDetails') ?? 0;
    mapScreenOpened = prefs.getBool('mapScreenOpened') ?? false;
    howItWorksOpened = prefs.getBool('howItWorksOpened') ?? false;
    clickedOnInstagramLink = prefs.getInt('clickedOnInstagramLink') ?? 0;
    // get last saved list of dates and convert to List of Type DateTime
    List<String>? savedDateDetailsStrings = prefs.getStringList('readDetailsDates');
    if (savedDateDetailsStrings != null) {
      readDetailsDates = savedDateDetailsStrings..toList();
    }
    List<String>? savedDateInstagramStrings = prefs.getStringList('clickedOnInstagramLinkDates');
    if (savedDateInstagramStrings != null) {
      clickedOnInstagramLinkDates = savedDateInstagramStrings..toList();
    }
  }

  @override
  void dispose() {
    _activityStreamController.close();
    _geofenceStreamController.close();
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }
}