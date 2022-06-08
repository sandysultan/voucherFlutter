import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

List<PlatformUiSettings>? buildUiSettings(BuildContext context) {
  return [
    AndroidUiSettings(
        toolbarTitle: 'Cropper',
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: false),
    IOSUiSettings(
      title: 'Cropper',
    ),
  ];
}