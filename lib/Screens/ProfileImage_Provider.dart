import 'dart:io';
import 'package:flutter/material.dart';

class ProfileImageProvider with ChangeNotifier {
  File? _imageFile;

  File? get imageFile => _imageFile;

  get image => null;

  set imageFile(File? file) {
    _imageFile = file;
    notifyListeners();
  }
}