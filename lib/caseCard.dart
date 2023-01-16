import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'courtCase.dart';
import 'main.dart';

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
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  courtCase.defendantName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                ),
                const Text(
                  'Defendant details: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: "Date of birth: ",
                    style: TextStyle(
                        fontFamily: GoogleFonts.sourceCodePro().fontFamily,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: courtCase.defendantDOB,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: "Age: ",
                    style: TextStyle(
                        fontFamily: GoogleFonts.sourceCodePro().fontFamily,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: courtCase.defendantAge,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Case details: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: "Offence date: ",
                    style: TextStyle(
                        fontFamily: GoogleFonts.sourceCodePro().fontFamily,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: courtCase.offenceDate,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: "Offence location: ",
                    style: TextStyle(
                        fontFamily: GoogleFonts.sourceCodePro().fontFamily,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: courtCase.offenceLocation,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Crimes:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: ((context, index) =>
                            Text(courtCase.offenceList[index])),
                        itemCount: courtCase.offenceList.length),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Text("Status: "),
                    SizedBox(
                      width: 450,
                      child: Text(
                        courtCase.courtDateMillis >=
                                DateTime.now().millisecondsSinceEpoch
                            ? "Pending | Court date: ${DateTime.fromMillisecondsSinceEpoch(courtCase.courtDateMillis).toLocal().toString().substring(0, 16)} | YYYY-MM-DD"
                            : courtCase.totalPrisonTimeAndFine,
                        maxLines: 4,
                        style: TextStyle(
                            color: courtCase.courtDateMillis >=
                                    DateTime.now().millisecondsSinceEpoch
                                ? Colors.amber
                                : Colors.green),
                      ),
                    )
                  ],
                ),
              ],
            ),
            Positioned(
                top: 30,
                right: 10,
                child: Container(
                  width: 120,
                  color: Colors.red,
                  child: AspectRatio(aspectRatio: 5/7, child: Image.asset("assets/peds/${courtCase.pedModel.toLowerCase()}__0_0_0_front.jpg"),),
                ))
          ],
        ),
      ),
    );
  }
}