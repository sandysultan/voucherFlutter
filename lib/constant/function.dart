import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../cropper/ui_helper.dart'
if (dart.library.io) '../../cropper/mobile_ui_helper.dart'
if (dart.library.html) '../../cropper/web_ui_helper.dart';

showImageDialog(
    BuildContext context, Function(CroppedFile croppedFile) onImageReady) {
  if(kIsWeb){
    _pickFromGallery(context, onImageReady);
  }else {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: const Text("Image Source"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Camera'),
                  leading: const Icon(Icons.camera),
                  onTap: () {
                    final ImagePicker picker = ImagePicker();
                    picker
                        .pickImage(source: ImageSource.camera)
                        .then((photo) async {
                      if (photo != null) {
                        _cropImage(context, photo, onImageReady)
                            .then((value) => Navigator.of(context).pop());
                      } else {
                        Navigator.of(context).pop();
                      }
                    });
                  },
                ),
                ListTile(
                  title: const Text('Gallery'),
                  leading: const Icon(Icons.image_search),
                  onTap: () {
                    _pickFromGallery(context, onImageReady);
                  },
                ),
              ],
            ),
          ));
  }
}

void _pickFromGallery(BuildContext context, Function(CroppedFile croppedFile) onImageReady) {
  final ImagePicker picker = ImagePicker();
  picker
      .pickImage(source: ImageSource.gallery)
      .then((image) async {
    if (image != null) {
      _cropImage(context, image, onImageReady)
          .then((value) {
        if (!kIsWeb) {
          Navigator.of(context).pop();
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  });
}

Future<void> _cropImage(BuildContext context, XFile image,
    Function(CroppedFile image) onImageReady) async {
  ImageCropper().cropImage(
    sourcePath: image.path,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    uiSettings: buildUiSettings(context),
  ).then((croppedFile) {
    if (croppedFile != null) {
      onImageReady(croppedFile);
    } else {
      EasyLoading.showError('Image is mandatory');
    }
  });
}
