import 'package:flutter/material.dart';

class SearchState extends ChangeNotifier {
  String keyword = "";
  String formatFilter = "すべて";
  DateTime? startDate;
  DateTime? endDate;
  List<String> usedFilters = [];
  List<String> opponentFilters = [];

  void setKeyword(String v) {
    keyword = v;
    notifyListeners();
  }

  void setFormatFilter(String v) {
    formatFilter = v;
    notifyListeners();
  }

  void setStartDate(DateTime? d) {
    startDate = d;
    notifyListeners();
  }

  void setEndDate(DateTime? d) {
    endDate = d;
    notifyListeners();
  }

  void addUsedFilter(String v) {
    if (!usedFilters.contains(v)) usedFilters.add(v);
    notifyListeners();
  }

  void removeUsedFilter(String v) {
    usedFilters.remove(v);
    notifyListeners();
  }

  void addOpponentFilter(String v) {
    if (!opponentFilters.contains(v)) opponentFilters.add(v);
    notifyListeners();
  }

  void removeOpponentFilter(String v) {
    opponentFilters.remove(v);
    notifyListeners();
  }

  void reset() {
    keyword = "";
    formatFilter = "すべて";
    startDate = null;
    endDate = null;
    usedFilters.clear();
    opponentFilters.clear();
    notifyListeners();
  }
}
