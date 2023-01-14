import 'dart:io';

import 'package:courtcasesmanager/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Court Cases Manager',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.sourceCodeProTextTheme()),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late XmlDocument document;
  late File file;
  bool xa = false;
  List<CourtCase> courtCases = [];
  String gamePath = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Grand Theft Auto V";

  loadConfig() async {
    debugPrint("loading config");
    final prefs = await SharedPreferences.getInstance();
    gamePath = prefs.getString('gamePath') ?? "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Grand Theft Auto V";
    debugPrint("config loaded");
  }

  @override
  void initState() {
    loadConfig();

    try {
      file = File('''$gamePath\\plugins\\LSPDFR\\LSPDFR+\\CourtCases.xml''');
      document = XmlDocument.parse(file.readAsStringSync());
    } catch (e) {
      xa = true;
    }
    debugPrint(gamePath);

    if (!xa) fetchData();

    super.initState();
  }

  fetchData() {
    final total = document.findAllElements('CourtCase');
    debugPrint(total.toString());
    for (int i = 0; i < total.length; i++) {
      final id =
          int.parse(total.elementAt(i).findElements('SuspectDOB').first.text);
      final name2 =
          total.elementAt(i).findElements('SuspectName').first.text.split(' ');
      final name = name2[0];
      final lastName = name2[1];
      final crime =
          total.elementAt(i).findElements('Crime').first.text.split(',');
      final veredict =
          total.elementAt(i).findElements('CourtVerdict').first.text != ''
              ? total.elementAt(i).findElements('CourtVerdict').first.text
              : 'Waiting for verdict';
      final published =
          total.elementAt(i).findElements('Published').first.text == 'True'
              ? true
              : false;
      for (var element in crime) {
        if (element[0] == ' ') element = element.substring(1);
      }
      courtCases.add(CourtCase(
          id: id,
          name: name,
          lastName: lastName,
          crime: crime,
          veredict: veredict,
          published: published));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(children: [
              const Text(
                "Court Cases Manager",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(onPressed: () => showDialog(context: context, builder: (context) => ConfigDialog(gamePath: gamePath,)), icon: const Icon(Icons.settings)),
            ]),
          ),
          Expanded(
            flex: 10,
            child: courtCases.isNotEmpty
                ? ListView.builder(
                    itemBuilder: ((context, index) => CourtCaseCard(
                          courtCase: courtCases[index],
                        )),
                    itemCount: courtCases.length)
                : const Text(
                    "No court cases found, please check your game path in config or continue patrolling"),
          ),
          InkWell(
              onTap: () => _launchUrl(),
            child: const Text("Court Cases Manager 0.0.1 by Augustt0"),)
        ],
      )),
    );
  }

  Future<void> _launchUrl() async {
  if (!await launchUrl(Uri.parse("https://www.lcpdfr.com/profile/405215-august00/"))) {
    throw 'Could not launch';
  }
}

}

class CourtCaseCard extends StatelessWidget {
  final CourtCase courtCase;
  const CourtCaseCard({super.key, required this.courtCase});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${courtCase.name} ${courtCase.lastName}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Crimes:"),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                      itemBuilder: ((context, index) =>
                          Text(courtCase.crime[index])),
                      itemCount: courtCase.crime.length),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              color: courtCase.veredict == "Waiting for veredict"
                  ? Colors.yellow
                  : Colors.green,
              child: Text(
                "Veredict: ${courtCase.veredict}",
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              "Published: ${courtCase.published.toString()}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class CourtCase {
  final int id;
  final String name;
  final String lastName;
  final List<String> crime;
  final String veredict;
  final bool published;
  CourtCase(
      {required this.id,
      required this.name,
      required this.lastName,
      required this.crime,
      required this.veredict,
      required this.published});
}
