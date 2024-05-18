import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dart:convert';
import 'dart:io';
import 'globals.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class MenuScreen1 extends StatefulWidget {
  const MenuScreen1({Key? key})
      : super(key: key);

  @override
  MenuScreen1State createState() => MenuScreen1State();
}

// Choose your language
class MenuScreen1State extends State<MenuScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B2042),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          textDirection: TextDirection.ltr,
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
            GestureDetector(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('language', 'German');
                language = 'German';

                if(context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => CatcallApp()),
                        (route) => ModalRoute.of(context)!.isFirst,
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
            GestureDetector(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('language', 'English');
                language = 'English';

                if(context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => CatcallApp()),
                        (route) => ModalRoute.of(context)!.isFirst,
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
      ),
    );
  }
}

class MenuScreen2 extends StatelessWidget {
  const MenuScreen2({super.key});

  Future<void> setHowItWorksOpenedTrue () async {
    if (!howItWorksOpened) {
      howItWorksOpened = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('howItWorksOpened', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    String howitworks = 'Wie funktioniert\'s';
    String walk = 'Laufe durch Bremen!';
    String sprechblase = 'Komme an einem Ort vorbei, an dem jemand einen Catcall erlebt hat.';
    String glocke = 'Du kriegst eine Benachrichtigung.';
    String click = 'Klicke auf die Benachrichtigung, um zu lesen, was an deinem Standort passiert ist.';
    String listHeadline = 'Liste';
    String list = 'Hier siehst du, welche Catcalls du schon entdeckt hast. Klicke auf eine Kachel, um mehr darüber zu erfahren.';
    String mapHeadline = 'Karte';
    String map = 'Sieh dir hier an, wo Catcalls passiert sind. Mit den Filteroptionen kannst du weitere Informationen erhalten.';
    String listScreenURL = 'assets/list_screen.jpg';
    String mapScreenURL = 'assets/map_screen.jpg';

    if (language == "English") {
      howitworks = 'How it works';
      walk = 'Walk through Bremen!';
      sprechblase = 'Pass a place where someone got catcalled.';
      glocke = 'You will receive a notification.';
      click = 'Click on the notification to read what happened on your location.';
      listHeadline = 'List';
      list = 'Here you can see which catcalls you have already discovered. Click on a tile to find out more about it.';
      mapHeadline = 'Map';
      map = 'See here where catcalls have happened. Use the filter options to get more information.';
      listScreenURL = 'assets/list_screen_eng.jpg';
      mapScreenURL = 'assets/map_screen_eng.jpg';
    }

    setHowItWorksOpenedTrue();

    return Scaffold(
      backgroundColor: const Color(0xFF3B2042),
      body: ListView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 70.0),
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                // Navigiere zurück
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/arrow-back.png',
                height: 25,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
            child: Text(
              howitworks,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          iconTextGrid(
            imageURL: 'assets/lauf.png',
            text: walk,
          ),
          iconTextGrid(
            imageURL: 'assets/sprechblase.png',
            text: sprechblase,
            iconFirst: false,
          ),
          iconTextGrid(
            text: glocke,
            imageURL: 'assets/glocke.png',
          ),
          iconTextGrid(
            imageURL: 'assets/finger.png',
            text: click,
            iconFirst: false,
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFF0B6FF),
                          blurRadius: 30,
                          offset: Offset(0, 0),
                          spreadRadius: -20,
                        ),
                      ]
                    ),
                    child: Image.asset(
                      listScreenURL,
                      height: 400,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listHeadline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          list,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mapHeadline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          map,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFF0B6FF),
                            blurRadius: 30,
                            offset: Offset(0, 0),
                            spreadRadius: -20,
                          ),
                        ]
                    ),
                    child: Image.asset(
                      mapScreenURL,
                      height: 400,
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
}

class MenuScreen3 extends StatelessWidget {
  const MenuScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    String howitworks = 'Über CatcallMAPP';
    String about = 'Diese App ist im Rahmen der Masterarbeit von Merle Keiser an der Universität Bremen (Master Digital Media) entstanden.';
    String sourcesCatcalls = 'Die Informationen über die Catcalls sowie die in dieser App verwendeten Fotos von den mit Kreide festgehaltenen Catcalls stammen von dem Instagram-Kanal @catcallsofbrmn. Ein großer Dank an dieser Stelle an @catcallsofbrmn für ihre Arbeit und die Bereitstellung der Bilder.';
    String sourcesImagesHead = 'Weitere in dieser App verwendeten Bilder und Illustrationen wurden entweder selbst entworfen oder sind im Folgenden aufgeführt:';
    String saveUserDataText = 'Nutzerdaten speichern';

    if (language == "English") {
      howitworks = 'About CatcallMAPP';
      about = "This app was developed as part of Merle Keiser's master's thesis at the University of Bremen (Master Digital Media).";
      sourcesCatcalls = 'The information about the catcalls and the photos of the catcalls written down with chalk used in this app come from the Instagram channel @catcallsofbrmn. A big thank you to @catcallsofbrmn for their work and for providing the images. ';
      sourcesImagesHead = 'Other images and illustrations used in this app were either self-designed or are listed below:';
      saveUserDataText = 'Save user data';
    }

    // function to download catcalls and other user data to json
    void shareDownloadedFile() async {
      UserData userData = UserData(
        readDetails: readDetails,
        readDetailsDates: readDetailsDates,
        readDetailsUnique: sumReadDetailsUnique(),
        mapScreenOpened: mapScreenOpened,
        howItWorksOpened: howItWorksOpened,
        clickedOnInstagramLink: clickedOnInstagramLink,
        clickedOnInstagramLinkDates: clickedOnInstagramLinkDates,
        operatingSystem: Platform.operatingSystem,
        catcallsfoundLength: catcallsFound.length-1,
        catcallsFound: catcallsFound,
      );

      // Encode die kombinierten Daten in JSON
      String jsonData = jsonEncode(userData.toJson());

      // Bei Android direkt in den Dateien speichern
      if (Platform.isAndroid) {
        final statusStorage = await Permission.manageExternalStorage.request();
        if (statusStorage.isGranted) {
          String? savePath = await FilePicker.platform.getDirectoryPath();

          if (savePath != null) {
            String filePath = '$savePath/user-data.json';
            File jsonFile = File(filePath);
            await jsonFile.writeAsString(jsonData);
          }
        } else {
          print(statusStorage);
        }
      }
      // Bei IOS über Teilen-Funktion
      else if (Platform.isIOS) {
        // Get the directory for storing temporary files
        Directory tempDir = await getTemporaryDirectory();
        String tempFilePath = '${tempDir.path}/user-data.json';

        // Write the JSON data to a temporary file
        File tempFile = File(tempFilePath);
        await tempFile.writeAsString(jsonData);

        // Share the temporary file
        await Share.shareXFiles([XFile(tempFilePath)]);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3B2042),
      body: ListView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 70.0),
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                // Navigiere zurück
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/arrow-back.png',
                height: 25,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
            child: Text(
              howitworks,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          aboutTextBlock(about),
          aboutTextBlock(sourcesCatcalls),
          aboutTextBlock(sourcesImagesHead),
          const SizedBox(height: 20.0),
          sourceImage(
            imageURL: 'assets/lauf.png',
            source: 'Running, Freepik at Flaticon.com, https://www.flaticon.com/de/kostenloses-icon/lauf_1950591?k=1700226366123&log-in=google, CC-BY, downloaded: 17.11.2023.'),
          sourceImage(
            imageURL: 'assets/sprechblase.png',
            source: 'Speech bubble, riajulislam at Flaticon.com, https://www.flaticon.com/de/kostenloses-icon/sprechblase_8427783?term=sprechblase+ausrufezeichen&page=1&position=64&origin=search&related_id=8427783, CC-BY, downloaded: 17.11.2023.'),
          sourceImage(
            imageURL: 'assets/glocke.png',
            source: 'Bell, Pixel perfect at Flaticon.com, https://www.flaticon.com/de/kostenloses-icon/glocke_1827349?term=glocke&related_id=1827349, CC-BY, downloaded: 17.11.2023.'),
          sourceImage(
            imageURL: 'assets/finger.png',
            source: 'Finger, Kiranshastry at Flaticon.com, https://www.flaticon.com/de/kostenloses-icon/zapfhahn_1612744?term=finger&related_id=1612744, CC-BY, downloaded: 17.11.2023.'),
          const SizedBox(height: 40.0),

          ElevatedButton(
            onPressed: shareDownloadedFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0B6FF),
            ),
            child: Text(
              saveUserDataText,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 50.0),
        ],
      ),
    );
  }
}

Widget sourceImage({
  required String imageURL,
  required String source
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30.0,
          child: Image.asset(
            imageURL,
            height: 30.0,
          ),
        ),
        const SizedBox(width: 20.0),
        Flexible(
          child: Text(
            source,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 10,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget aboutTextBlock(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
    ),
  );
}

Widget iconTextGrid({
  required String text,
  required String imageURL,
  bool iconFirst = true,
}) {
  if (iconFirst) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          SizedBox(
            width: 60.0,
            child: Image.asset(
              imageURL,
              height: 50,
            ),
          ),
          const SizedBox(width: 20.0),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  } else {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 20.0),
          SizedBox(
            width: 60.0,
            child: Image.asset(
              imageURL,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}

class UserData {
  int readDetails;
  List<String> readDetailsDates;
  int readDetailsUnique;
  bool mapScreenOpened;
  bool howItWorksOpened;
  int clickedOnInstagramLink;
  List<String> clickedOnInstagramLinkDates;
  String operatingSystem;
  int catcallsfoundLength;
  List<List<dynamic>> catcallsFound;

  UserData({
    required this.readDetails,
    required this.readDetailsDates,
    required this.readDetailsUnique,
    required this.mapScreenOpened,
    required this.howItWorksOpened,
    required this.clickedOnInstagramLink,
    required this.clickedOnInstagramLinkDates,
    required this.operatingSystem,
    required this.catcallsfoundLength,
    required this.catcallsFound,
  });

  // Konvertiere die Daten in ein Map-Objekt
  Map<String, dynamic> toJson() {
    return {
      'readDetails': readDetails,
      'readDetailsDates': readDetailsDates,
      'readDetailsUnique': readDetailsUnique,
      'mapScreenOpened': mapScreenOpened,
      'howItWorksOpened': howItWorksOpened,
      'clickedOnInstagramLink': clickedOnInstagramLink,
      'clickedOnInstagramLinkDates': clickedOnInstagramLinkDates,
      'operatingSystem': operatingSystem,
      'catcallsfoundLength': catcallsfoundLength,
      'catcallsFound': catcallsFound,
    };
  }
}