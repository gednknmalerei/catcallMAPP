import 'package:cat_call_app/globals.dart';
import 'package:cat_call_app/main.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DetailScreen extends StatefulWidget {
  final int id;

  const DetailScreen({Key? key, required this.id}) : super(key: key);

  static const String routeName = '/detailScreen';

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  late String title;
  late String location;
  late String text;
  late String link;
  late String imgLink;
  String initializeText = "Already initialized";

  Future<void> _initializeCSV() async {
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
    title = csvdata[widget.id][5];
    location = csvdata[widget.id][3];
    text = csvdata[widget.id][7];
    link = csvdata[widget.id][17];
    imgLink = 'assets/catcall_images/${widget.id}.jpg';
    addLatLang();
  }

  @override
  void initState() {
    super.initState();
    // wenn App von durch Klick auf eine Benachrichtigung geöffnet wird, müssen erst die CSV Daten initialisiert werden
    if (!initialized) {
      _initializeCSV();
    }
    // wenn normal geöffnet, werden die Daten nur zugeordnet
    else {
      title = csvdata[widget.id][5];
      location = csvdata[widget.id][3];
      text = csvdata[widget.id][7];
      link = csvdata[widget.id][17];
      imgLink = 'assets/catcall_images/${widget.id}.jpg';
    }
  }

  _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B2042),
      body: ListView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 70.0),
        children: [
          /*Text(initializeText,
          style: TextStyle(
            color: Colors.white,
          ),),*/
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
            child: GestureDetector(
              onTap: () {
                currentPageIndex = 1;
                startViewMap = latlang[widget.id];
                startZoomMap = 18;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CatcallApp(),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/marker-purple.png',
                    height: 35,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      location,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: GestureDetector(
              onTap: () async {
                // save click in user data
                clickedOnInstagramLink = clickedOnInstagramLink + 1;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setInt('clickedOnInstagramLink', clickedOnInstagramLink);

                // save timestamp of click on instagram link
                DateTime timeStamp = DateTime.now();
                // get last saved list of dates and convert to List of Type DateTime
                List<String>? savedDateStrings = prefs.getStringList('clickedOnInstagramLinkDates');
                if (savedDateStrings != null) {
                  clickedOnInstagramLinkDates = savedDateStrings.toList();
                }
                // add timestamp
                clickedOnInstagramLinkDates.add(timeStamp.toString());
                // save new list of readDetailsDates in SharedPreferences
                await prefs.setStringList('clickedOnInstagramLinkDates', clickedOnInstagramLinkDates);

                await _launchURL(link);
              },
              child: Image.asset(
                imgLink,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    'assets/instagram.png',
                    width: 16.0,
                  ),
                ),
                const Text(
                  '@catcallsofbrmn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
