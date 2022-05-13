import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:voucher/sales/cubit/sales_edit_cubit.dart';
import 'package:voucher/sales/cubit/sales_edit_power_cubit.dart';
import 'package:voucher/sales/sales.dart';

class SalesEdit extends StatelessWidget {
  const SalesEdit(this.item, {Key? key}) : super(key: key);
  final Kiosk item;

  static Route<bool?> route(Kiosk item) {
    return MaterialPageRoute<bool?>(
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
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) =>
                      VoucherCubit(snapshot.data!)..loadVouchers(),
                ),
                BlocProvider(
                  create: (context) => SalesEditCubit(snapshot.data!),
                ),
                BlocProvider(
                  create: (context) => SalesEditPowerCubit(snapshot.data!)..get(item.id),
                ),
              ],
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
  Sales? _lastSales;

  final _formKey = GlobalKey<FormBuilderState>();

  int _total = 0;

  final _cashController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
            Map<int, SalesDetail> mapLastDetails = {};
            if (widget.item.sales?.isNotEmpty == true) {
              _lastSales = widget.item.sales![0];
              for (SalesDetail detail in _lastSales?.salesDetails ?? []) {
                mapLastDetails[detail.voucherId] = detail;
              }
            }
            _subtotal = 0;
            for (var voucher in state.vouchers) {
              var stock = mapLastDetails.containsKey(voucher.id)
                  ? mapLastDetails[voucher.id]!.stock -
                      mapLastDetails[voucher.id]!.balance +
                      mapLastDetails[voucher.id]!.restock
                  : 0;
              vouchers.add(VoucherItem(
                  id: voucher.id,
                  name: voucher.name,
                  price: voucher.price,
                  stock: stock,
                  balance: 0,
                  restock: 0));
              _subtotal += voucher.price * (stock);
            }
            _total = getTotal();
            return FormBuilder(
              key: _formKey,
              // child: Placeholder(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FormBuilderDateTimePicker(
                        name: 'date',
                        initialDate: _lastSales != null
                            ? _lastSales!.date.add(const Duration(days: 7))
                            : null,
                        initialValue: _lastSales != null
                            ? _lastSales!.date.add(const Duration(days: 7))
                            : null,
                        lastDate: DateTime.now(),
                        inputType: InputType.date,
                        validator: FormBuilderValidators.required(),
                        format: DateFormat('dd MMMM yyyy'),
                        decoration: const InputDecoration(label: Text('Date')),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    VoucherSold(
                      initialValue:
                          VoucherRecap(vouchers: vouchers, subTotal: 0),
                      onChanged: (VoucherRecap? value) {
                        setState(() {
                          _subtotal = value?.subTotal ?? 0;
                          _total = getTotal();
                          _cashController.text = _total.toString();
                          logger.d('Total ' + _subtotal.toString());
                        });
                      },
                      validator: (VoucherRecap? value) {
                        if (value != null) {
                          if (value.subTotal < 0) {
                            return 'subtotal must not minus';
                          } else if (value.subTotal == 0) {
                            int total = 0;
                            for (var voucher in value.vouchers) {
                              total += voucher.stock +
                                  voucher.balance +
                                  voucher.restock;
                            }
                            if (total == 0) {
                              return 'Voucher data must not be all zero';
                            }
                          }
                        }
                        return null;
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
                          TableRow(children: [
                            const Text(
                              'Last Debt',
                              textAlign: TextAlign.end,
                            ),
                            const Text(' = '),
                            Text(
                              formatter.format(getLastDebt()),
                              textAlign: TextAlign.right,
                            )
                          ]),
                          widget.item.powerCost > 0
                              ? TableRow(children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      widget.item.powerCost > 0
                                          ? BlocBuilder<SalesEditPowerCubit,
                                              SalesEditPowerState>(
                                              builder: (context, state) {
                                                if (state
                                                    is SalesEditPowerSuccess) {
                                                  var formatter =
                                                      DateFormat('dd-MMM-yy');
                                                  return Text(
                                                      'Last power given at ' +
                                                          formatter.format(state
                                                              .sales.date));
                                                } else if(state is SalesEditPowerLoading){
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }else{
                                                  return Container();
                                                }
                                              },
                                            )
                                          : Container(),
                                      Checkbox(
                                        visualDensity: const VisualDensity(
                                            horizontal: -4, vertical: -4),
                                        onChanged: widget.item.powerCost == 0
                                            ? null
                                            : (bool? value) {
                                                setState(() {
                                                  _power = value ?? false;
                                                  _total = getTotal();
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
                                          formatter.format(_power
                                              ? widget.item.powerCost
                                              : 0) +
                                          ')',
                                      textAlign: TextAlign.right,
                                    ),
                                  )
                                ])
                              : TableRow(children: [
                                  Container(),
                                  Container(),
                                  Container(),
                                ]),
                          TableRow(children: [
                            const Text(
                              'Total',
                              textAlign: TextAlign.end,
                            ),
                            const Text(' = '),
                            Text(
                              formatter.format(_total),
                              textAlign: TextAlign.right,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          ]),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FormBuilderTextField(
                        name: 'cash',
                        controller: _cashController,
                        // initialValue: _total.toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: false),
                        decoration: const InputDecoration(label: Text('Cash')),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.parse(value) < 0) {
                              return 'Cash not allowed minus';
                            } else {
                              if (int.parse(value) > _total) {
                                return 'Cash is more than total, please check';
                              }
                            }
                          }
                          return null;
                        },
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
                    BlocConsumer<SalesEditCubit, SalesEditState>(
                      listener: (context, state) {
                        if (state is SalesEditLoading) {
                          EasyLoading.show(status: 'Saving');
                        } else if (state is SalesEditSaved) {
                          EasyLoading.showSuccess('Success');
                          Navigator.of(context).pop(true);
                        } else if (state is SalesEditError) {
                          EasyLoading.showError(state.message);
                        }
                      },
                      builder: (context, state) {
                        return SizedBox(
                            width: 150,
                            child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState
                                          ?.saveAndValidate() ==
                                      true) {
                                    var cashString =
                                        _formKey.currentState?.value['cash'];
                                    var cash = int.parse(cashString != null &&
                                            cashString.toString().isNotEmpty
                                        ? cashString.toString()
                                        : '0');
                                    var date =
                                        _formKey.currentState!.value['date'];
                                    VoucherRecap voucherRecap = _formKey
                                        .currentState!.value['vouchers'];
                                    List<SalesDetail> details = voucherRecap
                                        .vouchers
                                        .map((e) => SalesDetail(
                                            voucherId: e.id,
                                            price: e.price,
                                            stock: e.stock,
                                            balance: e.balance,
                                            restock: e.restock))
                                        .toList();
                                    context.read<SalesEditCubit>().save(
                                        AddSales(
                                            kioskId: widget.item.id,
                                            subtotal: _subtotal,
                                            kioskProfit: (_subtotal *
                                                    widget.item.kioskShare)
                                                .floor(),
                                            cash: cash,
                                            powerCost: _power
                                                ? widget.item.powerCost
                                                : 0,
                                            total: _total,
                                            details: details,
                                            date: date),
                                        _receiptPath == null
                                            ? null
                                            : File(_receiptPath!));
                                  }
                                },
                                child: const Text('Save')));
                      },
                    ),
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

  int getLastDebt() {
    return _lastSales == null ? 0 : (_lastSales!.total - _lastSales!.cash);
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

  int getTotal() {
    // return 0;
    return _subtotal -
        (widget.item.kioskShare * _subtotal).floor() +
        (_lastSales == null ? 0 : _lastSales!.total - _lastSales!.cash) -
        (_power ? widget.item.powerCost : 0);
  }
}
