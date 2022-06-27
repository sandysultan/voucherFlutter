import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http_client/http_client.dart';
import 'package:intl/intl.dart';
import 'package:local_repository/local_repository.dart';

import 'package:repository/repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voucher/sales/bloc/sales_kiosk_invoice_bloc.dart';
import 'package:voucher/widget/image_preview.dart';

class SalesKioskInvoice extends StatelessWidget {
  const SalesKioskInvoice(
      {Key? key, required this.kiosk, required this.sales, this.imageLocalPath, this.imageMemory})
      : super(key: key);

  static Route<bool> route(
      {required Kiosk kiosk, required Sales sales, String? imageLocalPath, Future<Uint8List>? imageMemory}) {
    return MaterialPageRoute<bool>(
      settings: const RouteSettings(name: '/sales_list'),
      builder: (context) => SalesKioskInvoice(
          kiosk: kiosk, sales: sales, imageLocalPath: imageLocalPath,imageMemory:imageMemory),
    );
  }

  final Kiosk kiosk;
  final Sales sales;
  final String? imageLocalPath;
  final Future<Uint8List>? imageMemory;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: FirebaseAuth.instance.currentUser?.getIdToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return BlocProvider(
              create: (context) => SalesKioskInvoiceBloc(snapshot.data!),
              child: SalesKioskView(
                  kiosk: kiosk, sales: sales, imageLocalPath: imageLocalPath, imageMemory:imageMemory),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class SalesKioskView extends StatelessWidget {
  SalesKioskView(
      {Key? key, required this.kiosk, required this.sales, this.imageLocalPath, this.imageMemory})
      : super(key: key);

  final Kiosk kiosk;
  final Sales sales;
  final String? imageLocalPath;
  final Future<Uint8List>? imageMemory;

  final GlobalKey genKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd MMMM yyyy');
    NumberFormat numberFormat = NumberFormat('#,###');
    var salesDetail = [
      TableRow(
          decoration:
              BoxDecoration(border: Border.all(), color: Colors.blueAccent),
          children: const [
            TableCell(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Voucher',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            )),
            TableCell(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Restock',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            )),
            TableCell(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Price x ( S - B - D )',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            )),
            TableCell(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Summary',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ))
          ]),
    ];
    int subtotal = 0;
    for (int i = 0; i < (sales.salesDetails?.length ?? 0); i++) {
      SalesDetail detail = sales.salesDetails![i];
      subtotal +=
          (detail.price * (detail.stock - detail.balance - detail.damage));
      salesDetail.add(TableRow(
          decoration: BoxDecoration(
              border: const Border.symmetric(vertical: BorderSide()),
              color: i % 2 == 0 ? Colors.blue[50] : null),
          children: [
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    detail.voucher?.name ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    detail.restock.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${numberFormat.format(detail.price)} x ( ${detail.stock} - ${detail.balance} - ${detail.damage} = ${detail.stock - detail.balance - detail.damage} )',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    numberFormat.format(detail.price *
                        (detail.stock - detail.balance - detail.damage)),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
          ]));
    }
    salesDetail.addAll([
      TableRow(
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(), left: BorderSide(), right: BorderSide()),
              color: Colors.blueAccent),
          children: [
            Container(),
            Container(),
            const TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  'Subtotal : ',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                )),
            TableCell(
                child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                numberFormat.format(subtotal),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
              ),
            ))
          ]),
      TableRow(
          decoration: const BoxDecoration(
              border: Border(left: BorderSide(), right: BorderSide()),
              color: Colors.blueAccent),
          children: [
            Container(),
            Container(),
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  'Kiosk Profit ${subtotal==0?0:(sales.kioskProfit / (subtotal / 100.0))}% : ',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                )),
            TableCell(
                child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '(${numberFormat.format(sales.kioskProfit)})',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
              ),
            )),
          ]),
    ]);
    if (sales.debt > 0) {
      salesDetail.add(TableRow(
          decoration: const BoxDecoration(
              border: Border(left: BorderSide(), right: BorderSide()),
              color: Colors.blueAccent),
          children: [
            Container(),
            Container(),
            const TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  'Debt : ',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                )),
            TableCell(
                child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                numberFormat.format(sales.debt),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
              ),
            )),
          ]));
    }
    if (sales.powerCost > 0) {
      salesDetail.add(TableRow(
          decoration: const BoxDecoration(
              border: Border(left: BorderSide(), right: BorderSide()),
              color: Colors.blueAccent),
          children: [
            Container(),
            Container(),
            const TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  'Power Cost : ',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                )),
            TableCell(
                child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                numberFormat.format(sales.powerCost),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
              ),
            )),
          ]));
    }
    salesDetail.add(TableRow(
        decoration: BoxDecoration(
            border: Border(
                left: const BorderSide(),
                right: const BorderSide(),
                bottom: sales.cash != sales.total
                    ? BorderSide.none
                    : const BorderSide(),
                top: const BorderSide(color: Colors.white)),
            color: Colors.blueAccent),
        children: [
          Container(),
          Container(),
          const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text(
                'Total : ',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              )),
          TableCell(
              child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              numberFormat.format(sales.total),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          )),
        ]));
    if (sales.cash != sales.total) {
      salesDetail.addAll([
        TableRow(
            decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(),
                  right: BorderSide(),
                ),
                color: Colors.blueAccent),
            children: [
              Container(),
              Container(),
              const TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(
                    'Cash : ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  )),
              TableCell(
                  child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  numberFormat.format(sales.cash),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              )),
            ]),
        TableRow(
            decoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(),
                    right: BorderSide(),
                    bottom: BorderSide(),
                    top: BorderSide(color: Colors.white)),
                color: Colors.blueAccent),
            children: [
              Container(),
              Container(),
              const TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(
                    'New Debt : ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  )),
              TableCell(
                  child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  numberFormat.format(sales.total - sales.cash),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              )),
            ]),
      ]);
    }
    var actions = <Widget>[];
    if (sales.id != null) {
      actions.add(IconButton(
          onPressed: () {
            takePicture();
          },
          icon: const Icon(Icons.share)));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(kiosk.kioskName),
        actions: actions,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RepaintBoundary(
              key: genKey,
              child: Container(
                color: Theme.of(context).canvasColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        columnWidths: const {
                          0: FixedColumnWidth(70),
                          1: FixedColumnWidth(20),
                        },
                        children: [
                          TableRow(children: [
                            const TableCell(child: Text('Date')),
                            const TableCell(child: Text(' : ')),
                            TableCell(
                                child: Text(dateFormat.format(
                                    (sales.date ?? DateTime.now()).toLocal()))),
                          ]),
                          if (sales.id != null) ...[
                            TableRow(children: [
                              const TableCell(child: Text('Sales No')),
                              const TableCell(child: Text(' : ')),
                              TableCell(child: Text(sales.id.toString())),
                            ])
                          ],
                          TableRow(children: [
                            const TableCell(child: Text('Kiosk')),
                            const TableCell(child: Text(' : ')),
                            TableCell(
                                child:
                                    Text('[${kiosk.id}] ${kiosk.kioskName}')),
                          ]),
                          TableRow(children: [
                            const TableCell(child: Text('Operator')),
                            const TableCell(child: Text(' : ')),
                            TableCell(
                                child: Text((sales.operatorUser?.name ?? "") +
                                    (sales.operatorUser?.phone == null
                                        ? ''
                                        : (', Telp: 0${sales.operatorUser!.phone!.substring(2)}')))),
                          ]),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Table(
                        columnWidths: const {
                          0: FixedColumnWidth(60),
                          1: FixedColumnWidth(50),
                          3: FixedColumnWidth(80)
                        },
                        children: salesDetail,
                      ),
                      Text('Notes : ${sales.description??''}' ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (imageLocalPath != null || sales.receipt == true) ...[
              InkWell(
                  onTap: () {
                    Navigator.of(context).push<void>(
                      ImagePreview.route(
                          local: imageLocalPath,
                          network: sales.receipt == true
                              ? '${HttpClient.server}sales/${sales.id}/receipt'
                              : null),
                    );
                  },
                  child: imageLocalPath != null
                      ? kIsWeb?
                      FutureBuilder<Uint8List>(
                        future: imageMemory,
                          builder: (context,snapshot) {
                          if(snapshot.connectionState==ConnectionState.done) {
                            return Image.memory(
                              snapshot.requireData,
                              height: 150,
                              width: 150,
                              fit: BoxFit.contain,);
                          } else{
                            return const Center(child: CircularProgressIndicator(),);
                          }
                          })
                      :Image.file(
                          File(imageLocalPath!),
                          height: 150,
                          width: 150,
                          fit: BoxFit.contain,
                        )
                      : Image.network(
                          '${HttpClient.server}sales/${sales.id}/receipt',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ))
            ],
            if (sales.id == null) ...[
              Align(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Save'),
                ),
              )
            ],
            if (sales.id != null) ...[
              BlocListener<SalesKioskInvoiceBloc, SalesKioskInvoiceState>(
                  listenWhen: (previous, current) =>
                      current is UpdateWhatsappSuccess ||
                      current is UpdateWhatsappLoading ||
                      current is UpdateWhatsappError,
                  listener: (context, state) {
                    if (state is UpdateWhatsappLoading) {
                      EasyLoading.show(status: 'Saving whatsapp number');
                    } else if (state is UpdateWhatsappError) {
                      EasyLoading.showError(state.message);
                    } else if (state is UpdateWhatsappSuccess) {
                      EasyLoading.showSuccess('Whatsapp number saved');
                      sendWhatsapp(context, state.kiosk.whatsapp!,
                          "${dateFormat.format(sales.date ?? DateTime.now())} Rp. ${numberFormat.format(sales.total)}");
                    }
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (kiosk.whatsapp?.isNotEmpty == true) {
                            showDialog<int>(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: const Text('Send invoice'),
                                      content: Text(kiosk.whatsapp!),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(0);
                                            },
                                            child: const Text('Cancel')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(1);
                                            },
                                            child: const Text('Send')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(2);
                                            },
                                            child: const Text('Change Number')),
                                      ],
                                    )).then((result) {
                              if (result == 1) {
                                sendWhatsapp(context, kiosk.whatsapp!,
                                    "${dateFormat.format(sales.date ?? DateTime.now())} Rp. ${numberFormat.format(sales.total)}");
                              } else if (result == 2) {
                                changeNumber(
                                    context: context, whatsapp: kiosk.whatsapp);
                              }
                            });
                          } else {
                            changeNumber(
                              context: context,
                            );
                          }
                        },
                        child: const Text('Send Whatsapp')),
                  ))
            ],
          ],
        ),
      ),
    );
  }

  Future<void> takePicture() async {
    RenderRepaintBoundary boundary =
        genKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    File imgFile = File('$directory/invoice.png');
    imgFile.writeAsBytes(pngBytes);
    Share.shareFiles([imgFile.path], text: 'Invoice');
  }

  void sendWhatsapp(BuildContext context, String number, String message) async {
    //   launchUrl(Uri.parse("https://wa.me/$number?text=$message"));
    // }
    //
    // openwhatsapp() async{
    //   var whatsapp ="+919144040888";
    var whatsappURlAndroid =
        Uri.parse("whatsapp://send?phone=$number&text=$message");
    var whatappURLIos = Uri.parse("https://wa.me/$number?text=$message");
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrl(whatappURLIos)) {
        await launchUrl(whatappURLIos);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp not installed")));
      }
    } else {
      // android , web
      if (await canLaunchUrl(whatsappURlAndroid)) {
        await launchUrl(whatsappURlAndroid);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp not installed")));
      }
    }
  }

  void changeNumber({required BuildContext context, String? whatsapp}) {
    showDialog(
      context: context,
      builder: (_) {
        var formWhatsappKey = GlobalKey<FormBuilderState>();
        return AlertDialog(
          title: const Text('Whatsapp Number'),
          content: FormBuilder(
            key: formWhatsappKey,
            child: FormBuilderTextField(
              name: 'whatsapp',
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.required(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  if (formWhatsappKey.currentState?.saveAndValidate() == true) {
                    Navigator.of(context)
                        .pop(formWhatsappKey.currentState?.value['whatsapp']);
                  }
                },
                child: const Text('Save')),
          ],
        );
      },
    ).then((whatsapp) {
      if (whatsapp != null) {
        context
            .read<SalesKioskInvoiceBloc>()
            .add(UpdateKioskWhatsapp(kiosk.copy(whatsapp: whatsapp)));
      }
    });
  }
}
