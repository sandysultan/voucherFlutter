import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

showImageDialog(
    BuildContext context, Function(CroppedFile croppedFile) onImageReady) {
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
                    final ImagePicker picker = ImagePicker();
                    picker
                        .pickImage(source: ImageSource.gallery)
                        .then((image) async {
                      if (image != null) {
                        _cropImage(context, image, onImageReady)
                            .then((value) => Navigator.of(context).pop());
                      } else {
                        Navigator.of(context).pop();
                      }
                    });
                  },
                ),
              ],
            ),
          ));
}

Future<void> _cropImage(BuildContext context, XFile image,
    Function(CroppedFile image) onImageReady) async {
  ImageCropper().cropImage(
    sourcePath: image.path,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Cropper',
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'Cropper',
      ),
    ],
  ).then((croppedFile) {
    if (croppedFile != null) {
      onImageReady(croppedFile);
    } else {
      EasyLoading.showError('Image is mandatory');
    }
  });
}
