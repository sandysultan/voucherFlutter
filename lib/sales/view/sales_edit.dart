import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:voucher/sales/sales.dart';

class SalesEdit extends StatelessWidget {
  const SalesEdit(this.item, {Key? key}) : super(key: key);
  final Kiosk item;

  static Route<String?> route(Kiosk item) {
    return MaterialPageRoute<String?>(
      settings: const RouteSettings(name: '/sales_edit'),
      builder: (context) => SalesEdit(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: FirebaseAuth.instance.currentUser?.getIdToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return BlocProvider(
              create: (context) => VoucherCubit(snapshot.data!)..loadVouchers(),
              child: _SalesView(item),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class _SalesView extends StatefulWidget {
  const _SalesView(this.item, {Key? key}) : super(key: key);
  final Kiosk item;

  @override
  State<_SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<_SalesView> {
  int _subtotal = 0;

  var logger = Logger();

  var formatter = NumberFormat('#,###');

  bool _power = false;

  String? _receiptPath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.kioskName),
      ),
      body: BlocBuilder<VoucherCubit, VoucherState>(
        builder: (context, state) {
          if (state is VoucherLoaded) {
            List<VoucherItem>? vouchers = [];
            for (var voucher in state.vouchers) {
              vouchers.add(VoucherItem(
                  voucher.id, voucher.name, voucher.price, 0, 0, 0));
            }
            return FormBuilder(
              // child: Placeholder(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    VoucherSold(
                      initialValue:
                          VoucherRecap(vouchers: vouchers, subTotal: 0),
                      onChanged: (VoucherRecap? value) {
                        setState(() {
                          _subtotal = value?.subTotal ?? 0;
                          logger.d('Total ' + _subtotal.toString());
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 24),
                      child: Table(
                        columnWidths: const {
                          1: FixedColumnWidth(20),
                          2: FixedColumnWidth(60),
                        },
                        children: [
                          TableRow(children: [
                            Text(
                              'Kiosks Profit ' +
                                  (widget.item.kioskShare * 100.0).toString() +
                                  '%',
                              textAlign: TextAlign.end,
                            ),
                            const Text(' = '),
                            Text(
                              '(' +
                                  formatter.format(
                                      _subtotal * widget.item.kioskShare) +
                                  ')',
                              textAlign: TextAlign.right,
                            )
                          ]),
                          const TableRow(children: [
                            Text(
                              'Last Debt',
                              textAlign: TextAlign.end,
                            ),
                            Text(' = '),
                            Text(
                              '0',
                              textAlign: TextAlign.right,
                            )
                          ]),
                          TableRow(children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Checkbox(
                                  visualDensity: const VisualDensity(
                                      horizontal: -4, vertical: -4),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _power = value ?? false;
                                    });
                                  },
                                  value: _power,
                                ),
                                const Text('Power Cost'),
                              ],
                            ),
                            const TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Text(' = ')),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Text(
                                '(' +
                                    formatter.format(
                                        _subtotal * widget.item.kioskShare) +
                                    ')',
                                textAlign: TextAlign.right,
                              ),
                            )
                          ]),
                          const TableRow(children: [
                            Text(
                              'Total',
                              textAlign: TextAlign.end,
                            ),
                            Text(' = '),
                            Text(
                              '200,000',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    if (_receiptPath != null)
                      Image.file(
                        File(_receiptPath!),
                        height: 150,
                        width: 150,
                      ),
                    SizedBox(
                        width: 150,
                        child: ElevatedButton(
                            onPressed: () {
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
                                              onTap: () async {
                                                final ImagePicker _picker =
                                                    ImagePicker();
                                                final XFile? photo =
                                                    await _picker.pickImage(
                                                        source:
                                                            ImageSource.camera);
                                                if (photo != null) {
                                                  await cropImage(photo);
                                                }
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ListTile(
                                              title: const Text('Gallery'),
                                              leading: const Icon(
                                                  Icons.image_search),
                                              onTap: () async {
                                                final ImagePicker _picker =
                                                    ImagePicker();
                                                final XFile? image =
                                                    await _picker.pickImage(
                                                        source: ImageSource
                                                            .gallery);
                                                if (image != null) {
                                                  await cropImage(image);
                                                }
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      ));
                            },
                            child: const Text('Receipt'))),
                    SizedBox(
                        width: 150,
                        child: ElevatedButton(
                            onPressed: () {}, child: const Text('Save'))),
                    const SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> cropImage(XFile image) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
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
    );
    if (croppedFile != null) {
      setState(() {
        _receiptPath = croppedFile.path;
      });
    }
  }
}
