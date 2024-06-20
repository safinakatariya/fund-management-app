import 'package:flutter/material.dart';

class FundModel extends ChangeNotifier {
  double _fund = 0;

  double get fund => _fund;

  void addFund(double amount) {
    _fund += amount;
    notifyListeners();
  }
}
