import 'dart:convert';
import 'dart:io';

import 'package:courtcasesmanager/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:process_run/shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_size/window_size.dart';

import 'caseCard.dart';
import 'courtCase.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Court Cases Manager');
    setWindowMinSize(const Size(1000, 480));
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
  bool xa = false;
  String searchTerm = "";
  String gamePath =
      "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Grand Theft Auto V";

  late Future<List<CourtCase>> courtCases;
  int totalCases = 0, veredictReached = 0, pending = 0;

  Future<void> loadConfig() async {
    debugPrint("loading config");
    final prefs = await SharedPreferences.getInstance();
    gamePath = prefs.getString('gamePath') ??
        "C:/Program Files (x86)/Steam/steamapps/common/Grand Theft Auto V";
    debugPrint("config loaded");
  }

  @override
  void initState() {
    courtCases = fetchData(context);
    super.initState();
  }

  Future<void> convert(BuildContext context) async {
    var shell = Shell();

    try {
      debugPrint("Executing translator");
      await shell.run('''
CourtCaseTranslator/CourtCaseTranslator.exe "$gamePath"
  ''');
    } on Exception catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Error"),
                content: const Text(
                    "The Court Case Translator exe could not be found. Please make sure it is in CourtCaseTranslator folder."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"))
                ],
              ));
    }
    debugPrint("Translation end");
  }

  Future<List<CourtCase>> fetchData(BuildContext context) async {
    debugPrint("Start loading");

    // Reset data

    totalCases = 0;
    veredictReached = 0;
    pending = 0;

    debugPrint("Data resetted");

    await loadConfig();
    await convert(context);

    debugPrint("Path loaded: $gamePath");

    File file =
        File('''$gamePath\\plugins\\LSPDFR\\CompuLite\\CourtCases.json''');
    final contents = await file.readAsString();
    debugPrint(contents);
    debugPrint("File loaded");

    List<CourtCase> hold = [];

    List<dynamic> map = jsonDecode(contents);

    for (dynamic json in map) {
      CourtCase courtCase = CourtCase.fromJson(json);
      hold.add(courtCase);
    }
    debugPrint("Json decoded");

    debugPrint("Stop loading");

    for (CourtCase courtCase in hold) {
      setState(() {
        totalCases++;
      });
      if (courtCase.courtDateMillis >= DateTime.now().millisecondsSinceEpoch) {
        setState(() {
          pending++;
        });
      } else {
        setState(() {
          veredictReached++;
        });
      }
      debugPrint(DateTime.fromMillisecondsSinceEpoch(courtCase.courtDateMillis)
          .toString());
    }

    return hold;
  }

  @override
  Widget build(BuildContext context) {
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
                        Row(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 400,
                              child: TextField(
                                onChanged: (value) => setState(() {
                                  searchTerm = value;
                                }),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  hintText: 'Search',
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: ((context) =>
                                          ConfigDialog(gamePath: gamePath)));
                                },
                                icon: const Icon(Icons.settings)),
                          ],
                        )
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
                      child: FutureBuilder(
                    future: courtCases,
                    builder:
                        ((context, AsyncSnapshot<List<CourtCase>> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          if (searchTerm != "") {
                            List<CourtCase> filtered = [];
                            
                            snapshot.data!.forEach((element) {
                                if(element.defendantName
                                  .toLowerCase()
                                  .contains(searchTerm.toLowerCase())) {
                                    filtered.add(element);
                                  }
                            });

                            return ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  return CourtCaseCard(
                                      courtCase: filtered[index]);
                                });
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return CourtCaseCard(
                                      courtCase: snapshot.data![index]);
                                });
                          }
                        } else {
                          return const Center(
                              child: Text(
                                  "No cases found, check settings for game path or resume patrol to generate cases"));
                        }
                      } else {
                        return const Center(child: Text("Loading..."));
                      }
                    }),
                  )),
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
                                      "Total cases: $totalCases",
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
    if (!await launchUrl(Uri.parse(
        "https://www.lcpdfr.com/downloads/gta5mods/misc/42526-court-cases-manager/"))) {
      throw 'Could not launch';
    }
  }
}
