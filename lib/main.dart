import 'dart:io';

import 'package:courtcasesmanager/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_size/window_size.dart';
import 'package:xml/xml.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Court Cases Manager');
    setWindowMinSize(const Size(900, 480));
  }

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
  String gamePath =
      "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Grand Theft Auto V";

  int totalCases = 0, veredictReached = 0, pending = 0, notGuilty = 0;

  loadConfig() async {
    debugPrint("loading config");
    final prefs = await SharedPreferences.getInstance();
    gamePath = prefs.getString('gamePath') ??
        "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Grand Theft Auto V";
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
      if (veredict == 'Not Guilty') notGuilty++;
      if (veredict == 'Waiting for verdict') pending++;
      if (veredict != 'Not Guilty' && veredict != 'Waiting for verdict') {
        veredictReached++;
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
    print(MediaQuery.of(context).size.height);
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Expanded(
                            flex: 4,
                            child: Text(
                              "Court Cases Manager",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            )),
                        Expanded(
                            flex: 1,
                            child: Row(
                              children: [],
                            ))
                      ]),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 8,
              child: Row(children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    child: ListView.builder(
                        itemCount: courtCases.length,
                        itemBuilder: (context, index) {
                          return CourtCaseCard(courtCase: courtCases[index]);
                        }),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            color: const Color.fromARGB(255, 235, 235, 235),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            elevation: 0,
                            child: SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      "Your stats",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "Total cases: ${courtCases.length}",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "Veredict reached: $veredictReached",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "Pending: $pending",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "Not guilty: $notGuilty",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _launchUrl,
                            child: const Text(
                              "Made by August00\nv0.0.2",
                              textAlign: TextAlign.center,
                            ),
                          )
                        ]),
                  ),
                )
              ]),
            )
          ],
        ),
      )),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(
        Uri.parse("https://www.lcpdfr.com/profile/405215-august00/"))) {
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
      elevation: 0,
      color: const Color.fromARGB(255, 235, 235, 235),
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
            Row(
              children: [
                const Text("Status: "),
                SizedBox(
                  width: 400,
                  child: Text(
                    courtCase.veredict,
                    maxLines: 4,
                    style: TextStyle(
                        color: courtCase.veredict == "Not Guilty"
                            ? Colors.red
                            : courtCase.veredict == "Pending"
                                ? Colors.amber
                                : Colors.green),
                  ),
                )
              ],
            )
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
