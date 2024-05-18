import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_screen.dart';
import 'globals.dart';


class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Sortiere die Daten nach Datum absteigend
    catcallsFound.sort((a, b) => b[19]!.compareTo(a[19]!));
    String textH1 = 'Letzte Catcalls';
    String textNotYetFound = 'Noch keine Catcalls gefunden. Laufe durch die Stadt, damit hier Catcalls auftauchen, die du entdeckt hast.';
    String dateToday = 'Heute';
    String dateYesterday = 'Gestern';

    getText() {
      if (language == 'English') {
        textH1 = 'Latest Catcalls';
        textNotYetFound = 'No catcalls found yet. Walk through the city so that catcalls that you have discovered appear here.';
        dateToday = 'Today';
        dateYesterday = 'Yesterday';
      }
    }

    getText();

    // Erstelle die Liste der Kacheln
    List<Widget> catcallTiles = [];
    String? currentDate = "";

    if (catcallsFound.length > 1) {
      for (var i = 1; i < catcallsFound.length; i++) {
        var catcall = catcallsFound[i];
        DateTime date = DateTime.parse(catcall[19]!);
        String formattedDate = DateFormat('yyyy-MM-dd').format(date);
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);
        String formattedToday = DateFormat('yyyy-MM-dd').format(today);
        DateTime yesterday = today.subtract(const Duration(days: 1));
        String formattedYesterday = DateFormat('yyyy-MM-dd').format(yesterday);
        String catcallTitle = catcall[5]!;
        String catcallLocation = catcall[3]!;
        int catcallID = catcall[0]!;

        getCatcallData() {
          if (language == 'English') {
            catcallTitle = catcall[6]!;
          }
        }

        getCatcallData();

        // Überschrift hinzufügen, wenn neuer Tag
        if (formattedDate != currentDate) {
          // Schreibe "Heute" bzw "Gestern", wenn das Finden des Catcalls erst vor Kurzem war
          if (formattedDate == formattedToday) {
            currentDate = dateToday;
          } else if (formattedDate == formattedYesterday) {
            currentDate = dateYesterday;
          } else {
            currentDate = DateFormat('dd.MM.yyyy').format(date);
          }
          // Füge das Datum als Überschrift hinzu, wenn es sich ändert
          catcallTiles.add(
            Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  currentDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
          currentDate = formattedDate;
        }

        // Füge die Kachel hinzu
        catcallTiles.add(
          GestureDetector(
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
              catcall[20] = true;
              String catcallsCsv = const ListToCsvConverter().convert(catcallsFound);
              await prefs.setString('lastStateCsv', catcallsCsv);

              if (context.mounted) {
                // Navigiere zur Detailseite beim Klicken auf eine Kachel
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      id: catcallID,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Card(
                color: const Color(0xFFF0B6FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 8.0, right: 5.0, bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      catcallTitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/map.png',
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              catcallLocation,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    } else {
      catcallTiles.add(
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
          child: Text(
            textNotYetFound,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3B2042),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFF0B6FF),
        backgroundColor: const Color(0xFF3B2042),
        edgeOffset: 50.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
                child: Text(
                  textH1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24.0,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              ...catcallTiles,
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}