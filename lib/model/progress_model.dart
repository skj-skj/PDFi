// 🐦 Flutter imports:
import 'package:flutter/material.dart';

/// 🌀 Model for Showing Progress of Files being imported
class ProgressModel extends ChangeNotifier {
  /// 🕵️ [_noOfFiles], is a List<int>
  ///
  ///   - _noOfFiles[0] = Current Value
  ///   - _noOfFiles[1] = Total Value
  ///
  /// Current & Total Values are:
  ///   - Current = Number of files been imported
  ///   - Total = Total number of files user selected to import
  List<int> _noOfFiles = [0, 1];

  /// 🗞️ Getter for Current Value
  int get currValue => _noOfFiles[0];

  /// 🗞️ Getter for Total Value
  int get totalValue => _noOfFiles[1];

  /// ➕ Update Current Value by 1
  void currentValueIncrement() {
    _noOfFiles[0]++;
    notifyListeners();
  }

  /// 📥📝 Set Default Value of [_noOfFiles]
  ///
  ///   - Current Value = 0 ( _noOfFiles[0] )
  ///   - Total Value = 1 ( _noOfFiles[1] )
  void setDefaultValue() {
    _noOfFiles[0] = 0;
    _noOfFiles[1] = 1;
    notifyListeners();
  }

  /// ➕ Update Total Value
  void updateTotalValue(int value) {
    _noOfFiles[1] = value;
    notifyListeners();
  }
}
