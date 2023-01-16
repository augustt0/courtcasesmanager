class CourtCase {
  final String caseNo;
  final int courtDateMillis;
  final String defendantName;
  final String defendantDOB;
  final String defendantAge;
  final String offenceDate;
  final String offenceLocation;
  final List<String> offenceList;
  final List<String> outcomeList;
  final String totalPrisonTimeAndFine;
  final String notes;
  final String pedModel;

  CourtCase(
      {required this.caseNo,
      required this.courtDateMillis,
      required this.defendantName,
      required this.defendantDOB,
      required this.defendantAge,
      required this.offenceDate,
      required this.offenceLocation,
      required this.offenceList,
      required this.outcomeList,
      required this.totalPrisonTimeAndFine,
      required this.notes,
      required this.pedModel});

  factory CourtCase.fromJson(Map<String, dynamic> json) {
    return CourtCase(
        caseNo: json['caseNo'],
        courtDateMillis: json['courtDateMillis'],
        defendantName: json['defendantName'],
        defendantDOB: json['defendantDOB'],
        defendantAge: json['defendantAge'],
        offenceDate: json['offenceDate'],
        offenceLocation: json['offenceLocation'],
        offenceList: List<String>.from(json['offenceList']),
        outcomeList: List<String>.from(json['outcomeList']),
        totalPrisonTimeAndFine: json['totalPrisonTimeAndFine'],
        notes: json['notes'],
        pedModel: json['pedEntry']['pedModel']);
  }
}