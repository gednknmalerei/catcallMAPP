import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'main.dart';
import 'globals.dart';


bool notificationsEnabled = false;

// Onboarding nur anzeigen, wenn die App das erste Mal geöffnet wird
class OnboardingManager {
  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }

  Future<void> setNotFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF3B2042),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OnboardingPageLanguage(),
        ],
      ),
    );
  }
}

class OnboardingPageLanguage extends StatefulWidget {
  const OnboardingPageLanguage({Key? key})
      : super(key: key);

  @override
  OnboardingPageLanguageState createState() => OnboardingPageLanguageState();
}

// Choose your language
class OnboardingPageLanguageState extends State<OnboardingPageLanguage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            "CHOOSE YOUR LANGUAGE",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 16,
            )
          ),
          const SizedBox(height: 30),
          InkWell(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', 'German');
              language = 'German';

              if(context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingPageInstruction1()),
                );
              }
            },
            child: SizedBox(
              width: 120.0,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B6FF),
                  borderRadius: BorderRadius.circular(10.0), // Anpassen des borderRadius
                ),
                child: const Text(
                    "Deutsch",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 16,
                    )
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', 'English');
              language = 'English';

              if(context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingPageInstruction1()),
                );
              }
            },
            child: SizedBox(
              width: 120.0,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B6FF),
                  borderRadius: BorderRadius.circular(10.0), // Anpassen des borderRadius
                ),
                child: const Text(
                    "English",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 16,
                    )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageInstruction1 extends StatelessWidget {
  const OnboardingPageInstruction1({super.key});

  getText() {
    if (language == 'English') {
      return 'Walk through Bremen!';
    } else {
      return 'Laufe durch Bremen!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildOnboardingPage(
      imageURL: 'assets/lauf.png',
      text: getText(),
      context: context,
      first: true,
      last: false,
      permission: '',
      previousScreen: const OnboardingPageLocation(),
      nextScreen: const OnboardingPageLocation());
  }
}

class OnboardingPageLocation extends StatelessWidget {
  const OnboardingPageLocation({super.key});

  getText() {
    if (language == 'English') {
      return 'In the next step, allow CatcallMAPP access to your location and activity at all times (first choose "When in use", then "Allow always") so that the app runs correctly also in the background.';
    } else {
      return 'Erlaube CatcallMAPP im nächsten Schritt jederzeit Zugriff auf deinen Standort (erst "Beim Verwenden erlauben" auswählen, dann "Immer erlauben"), damit die App auch im Hintergrund richtig läuft.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildOnboardingPage(
      imageURL: 'assets/lauf.png',
      text: getText(),
      context: context,
      first: false,
      last: false,
      permission: 'location',
      previousScreen: const OnboardingPageInstruction1(),
      nextScreen: const OnboardingPageLocation2());
  }
}

class OnboardingPageLocation2 extends StatelessWidget {
  const OnboardingPageLocation2({super.key});

  getText() {
    if (language == 'English') {
      return 'To recognize how you move through the city, CatcallMAPP also needs access to your physical activity. Please allow this in the next step.';
    } else {
      return 'Um zu erkennen, wie du dich durch die Stadt bewegst, braucht CatcallMAPP außerdem Zugriff auf deine physische Aktivität. Bitte erlaube dies im nächsten Schritt.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildOnboardingPage(
      imageURL: 'assets/lauf.png',
      text: getText(),
      context: context,
      first: false,
      last: false,
      permission: 'activity',
      previousScreen: const OnboardingPageLocation(),
      nextScreen: const OnboardingPageInstruction2());
  }
}

class OnboardingPageInstruction2 extends StatelessWidget {
  const OnboardingPageInstruction2({super.key});

  getText() {
    if (language == 'English') {
      return 'Pass a place where someone got catcalled.';
    } else {
      return 'Komme an einem Ort vorbei, an dem jemand einen Catcall erlebt hat.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildOnboardingPage(
      imageURL: 'assets/sprechblase.png',
      text: getText(),
      context: context,
      first: false,
      last: false,
      permission: '',
      previousScreen: const OnboardingPageLocation(),
      nextScreen:  const OnboardingPageNotifications());
  }
}

class OnboardingPageNotifications extends StatelessWidget {
  const OnboardingPageNotifications({super.key});

  getText() {
    if (language == 'English') {
      return "You will receive a notification. In the next step, please allow CatcallMAPP to send you notifications.";
    } else {
      return 'Du kriegst eine Benachrichtigung. Bitte aktiviere dafür im nächsten Schritt, dass CatcallMAPP dir Benachrichtigungen schicken darf.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildOnboardingPage(
      imageURL: 'assets/glocke.png',
      text: getText(),
      context: context,
      first: false,
      last: false,
      permission: 'notification',
      previousScreen: const OnboardingPageLocation(),
      nextScreen: const OnboardingPageClick());
  }
}

class OnboardingPageClick extends StatelessWidget {
  const OnboardingPageClick({super.key});

  getText() {
    if (language == 'English') {
      return "Click on the notification to read what happened on your location.";
    } else {
      return 'Klicke auf die Benachrichtigung, um zu lesen, was an deinem Standort passiert ist.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildOnboardingPage(
      imageURL: 'assets/finger.png',
      text: getText(),
      context: context,
      first: false,
      last: true,
      permission: '',
      previousScreen: const OnboardingPageNotifications(),
      nextScreen: CatcallApp());
  }
}

Widget buildOnboardingPage({
  required String imageURL,
  required String text,
  required BuildContext context,
  required bool first,
  required bool last,
  required String permission,
  required StatelessWidget previousScreen,
  required StatelessWidget nextScreen
}) {
  return Scaffold(
    backgroundColor: const Color(0xFF3B2042),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Image.asset(
                    imageURL,
                    height: 80,
                  ),
                ),
              ),
              Card(
                color: const Color(0xFFF0B6FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 50.0, right: 20.0, bottom: 20.0),
                  child: Column(
                    children: [
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),
                      buildNavigation(first, last, permission, previousScreen, nextScreen, context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

buildNavigation(bool first, bool last, String permission, StatelessWidget previousScreen, StatelessWidget nextScreen, BuildContext context) {
  String textNext = '';
  String textPrevious = '';
  if (language == 'English') {
    textPrevious = "BACK";
    if (last) {
      textNext = "LET'S GO";
    } else {
      textNext = "NEXT";
    }
  } else {
    textPrevious = "ZURÜCK";
    if (last) {
      textNext = "LET'S GO";
    } else {
      textNext = "WEITER";
    }
  }

  if (first) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },
      child: Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/arrow-right.png',
                width: 22,
              ),
              Text(
                textNext,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          )
      ),
    );
  } else {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(builder: (context) => previousScreen),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/arrow-left.png',
                    width: 22,
                  ),
                  Text(
                    textPrevious,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                if (permission == 'notification') {
                  final status = await Permission.notification.request();
                  if (status == PermissionStatus.granted) {
                    notificationPermission = true;
                  }
                } else if (permission == 'location') {
                  final statusLocation = await Permission.locationWhenInUse.request();
                  if (statusLocation.isGranted) {
                    Permission.locationAlways.request();
                  }
                } else if (permission == 'activity') {
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
                if (last) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstTime', false);
                }
                if(context.mounted) {
                  if (last) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => nextScreen),
                          (route) => ModalRoute.of(context)!.isFirst,
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => nextScreen),
                    );
                  }
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/arrow-right.png',
                    width: 22,
                  ),
                  Text(
                    textNext,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}