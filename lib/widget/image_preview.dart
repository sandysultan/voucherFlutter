import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({Key? key, this.network, this.local}) : super(key: key);
  final String? network;
  final String? local;

  static Route<String?> route({String? network, String? local}) {
    return MaterialPageRoute<String?>(
      settings: const RouteSettings(name: '/image'),
      builder: (context) => ImagePreview(network:network,local:local),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
      ),
      body: network != null
          ? PhotoView(imageProvider: NetworkImage(network!))
          : local != null
              ? PhotoView(imageProvider: FileImage(File(local!)))
              : const Center(child: Text('Image provider not valid')),
    );
  }
}
