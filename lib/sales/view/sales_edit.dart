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
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:voucher/sales/cubit/sales_edit_save_cubit.dart';
import 'package:voucher/sales/cubit/sales_edit_power_cubit.dart';
import 'package:voucher/sales/sales.dart';

class SalesEdit extends StatelessWidget {
  const SalesEdit(this.item, {Key? key}) : super(key: key);
  final Kiosk item;

  static Route<Sales?> route(Kiosk item) {
    return MaterialPageRoute<Sales?>(
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
                  create: (context) => SalesEditSaveCubit(snapshot.data!),
                ),
                BlocProvider(
                  create: (context) =>
                      SalesEditPowerCubit(snapshot.data!)..get(item.id),
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
  int _kioskProfit = 0;
  int _debt = 0;
  int _powerCost = 0;
  List<VoucherItem> _vouchers = [];

  final _cashController = TextEditingController();

  @override
  void initState() {
    if (widget.item.sales?.isNotEmpty == true) {
      _lastSales = widget.item.sales![0];
      _debt = _lastSales == null ? 0 : (_lastSales!.total - _lastSales!.cash);
    }
    _powerCost = widget.item.powerCost;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.kioskName),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              context
                          .read<LocalRepository>()
                          .currentUser()
                          ?.modules
                          ?.contains('saleDate') ==
                      true
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FormBuilderDateTimePicker(
                        name: 'date',
                        initialDate: _lastSales != null
                            ? _lastSales!.date!.add(const Duration(days: 7))
                            : null,
                        initialValue: _lastSales != null
                            ? _lastSales!.date!.add(const Duration(days: 7))
                            : null,
                        lastDate: DateTime.now(),
                        inputType: InputType.date,
                        validator: FormBuilderValidators.required(),
                        format: DateFormat('dd MMMM yyyy'),
                        decoration: const InputDecoration(label: Text('Date')),
                      ),
                    )
                  : Container(),
              const SizedBox(
                height: 16,
              ),
              BlocConsumer<VoucherCubit, VoucherState>(
                buildWhen: (previous, current) =>
                    current is VoucherLoaded || current is VoucherLoading,
                listenWhen: (previous, current) => current is VoucherLoaded,
                builder: (context, state) {
                  logger.d('builder');
                  if (state is VoucherLoaded) {
                    logger.d('builder finish');
                    return VoucherSold(
                      initialValue:
                          VoucherRecap(vouchers: _vouchers, subTotal: 0),
                      onChanged: (VoucherRecap? value) {
                        setState(() {
                          _subtotal = value?.subTotal ?? 0;
                          _kioskProfit =
                              (_subtotal * widget.item.kioskShare).floor();
                          _total = getTotal();
                          _cashController.text =
                              ((_total/1000).floor()*1000).toString();
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
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
                listener: (BuildContext context, Object? state) {
                  if (state is VoucherLoaded) {
                    setState(() {
                      _vouchers = [];
                      Map<int, SalesDetail> mapLastDetails = {};
                      if (widget.item.sales?.isNotEmpty == true) {
                        _lastSales = widget.item.sales![0];
                        for (SalesDetail detail
                            in _lastSales?.salesDetails ?? []) {
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
                        _vouchers.add(VoucherItem(
                            id: voucher.id,
                            name: voucher.name,
                            price: voucher.price,
                            stock: stock,
                            balance: 0,
                            damage: 0,
                            restock: 0));
                        _subtotal += voucher.price * (stock);
                      }
                      _kioskProfit =
                          (_subtotal * widget.item.kioskShare).floor();
                      _total = getTotal();
                      _cashController.text =
                          ((_total/1000).floor()*1000).toString();
                      logger.d('listener finish');
                    });
                  }
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
                        '(' + formatter.format(_kioskProfit) + ')',
                        textAlign: TextAlign.right,
                      )
                    ]),
                    TableRow(children: [
                      InkWell(
                        onLongPress: () async {
                          final formDebtKey = GlobalKey<FormBuilderState>();
                          var lastDebt = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Debt'),
                                  content: FormBuilder(
                                      key: formDebtKey,
                                      child: FormBuilderTextField(
                                        initialValue: _debt.toString(),
                                        validator:
                                            FormBuilderValidators.required(),
                                        name: 'debt',
                                        keyboardType: TextInputType.number,
                                      )),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () {
                                          if (formDebtKey.currentState
                                                  ?.saveAndValidate() ==
                                              true) {
                                            Navigator.of(context).pop(
                                                formDebtKey.currentState!
                                                    .value['debt']);
                                          }
                                        },
                                        child: const Text('OK')),
                                  ],
                                );
                              });

                          if (lastDebt != null) {
                            setState(() {
                              _debt = int.parse(lastDebt);
                              _total = getTotal();
                              _cashController.text =
                                  ((_total/1000).floor()*1000).toString();
                            });
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Debt',
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(' = '),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          formatter.format(_debt),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ]),
                    _powerCost > 0
                        ? TableRow(children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _powerCost > 0
                                    ? BlocBuilder<SalesEditPowerCubit,
                                        SalesEditPowerState>(
                                        buildWhen: (previous, current) =>
                                            current
                                                is SalesEditGetPowerSuccess ||
                                            current is SalesEditGetPowerLoading,
                                        builder: (context, state) {
                                          if (state
                                              is SalesEditGetPowerSuccess) {
                                            if (state.sales != null) {
                                              var formatter =
                                                  DateFormat('dd-MMM-yy');
                                              return Text(
                                                'Last power ' +
                                                    formatter.format(state
                                                        .sales!.date!
                                                        .toLocal()),
                                                style: TextStyle(fontSize: 12),
                                              );
                                            }
                                          } else if (state
                                              is SalesEditGetPowerLoading) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          return Container();
                                        },
                                      )
                                    : Container(),
                                Checkbox(
                                  visualDensity: const VisualDensity(
                                      horizontal: -4, vertical: -4),
                                  onChanged: _powerCost == 0
                                      ? null
                                      : (bool? value) {
                                          setState(() {
                                            _power = value ?? false;
                                            _total = getTotal();
                                            _cashController.text =
                                                ((_total/1000).floor()*1000).toString();
                                          });
                                        },
                                  value: _power,
                                ),
                                BlocListener<SalesEditPowerCubit,
                                    SalesEditPowerState>(
                                  listenWhen: (previous, current) =>
                                      current is SalesEditUpdatePowerLoading ||
                                      current is SalesEditUpdatePowerSuccess ||
                                      current is SalesEditUpdatePowerError,
                                  listener: (context, state) {
                                    if (state is SalesEditUpdatePowerLoading) {
                                      EasyLoading.show(
                                          status: "Updating Power Cost");
                                    } else if (state
                                        is SalesEditUpdatePowerError) {
                                      EasyLoading.showError(state.message);
                                    } else if (state
                                        is SalesEditUpdatePowerSuccess) {
                                      EasyLoading.showSuccess('Updating success');
                                      setState((){
                                        _powerCost=state.kiosk.powerCost;
                                        _total=getTotal();
                                      });
                                    }
                                  },
                                  child: InkWell(
                                    onLongPress: () async {
                                      final formPowerCost =
                                          GlobalKey<FormBuilderState>();
                                      var powerCost = await showDialog<String>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Power Cost'),
                                              content: FormBuilder(
                                                  key: formPowerCost,
                                                  child: FormBuilderTextField(
                                                    initialValue:
                                                        _debt.toString(),
                                                    validator:
                                                        FormBuilderValidators
                                                            .required(),
                                                    name: 'powerCost',
                                                    keyboardType:
                                                        TextInputType.number,
                                                  )),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child:
                                                        const Text('Cancel')),
                                                TextButton(
                                                    onPressed: () {
                                                      if (formPowerCost
                                                              .currentState
                                                              ?.saveAndValidate() ==
                                                          true) {
                                                        Navigator.of(context)
                                                            .pop(formPowerCost
                                                                    .currentState!
                                                                    .value[
                                                                'powerCost']);
                                                      }
                                                    },
                                                    child: const Text('OK')),
                                              ],
                                            );
                                          });

                                      if (powerCost != null) {
                                        FirebaseAuth.instance.currentUser
                                            ?.getIdToken()
                                            .then((token) {
                                          context
                                              .read<SalesEditPowerCubit>()
                                              .updatePowerCost(
                                                  token,
                                                  widget.item.copy(
                                                      powerCost: int.parse(
                                                          powerCost)));
                                        });
                                      }
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text('Power Cost'),
                                    ),
                                  ),
                                ),
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
                                    formatter.format(_power ? _powerCost : 0) +
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
                        // _total.toString(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                  source: ImageSource.camera);
                                          if (photo != null) {
                                            await cropImage(photo);
                                          }
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Gallery'),
                                        leading: const Icon(Icons.image_search),
                                        onTap: () async {
                                          final ImagePicker _picker =
                                              ImagePicker();
                                          final XFile? image =
                                              await _picker.pickImage(
                                                  source: ImageSource.gallery);
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
              BlocConsumer<SalesEditSaveCubit, SalesEditSaveState>(
                listener: (context, state) {
                  if (state is SalesEditSaveLoading) {
                    EasyLoading.show(status: 'Saving');
                  } else if (state is SalesEditSaved) {
                    EasyLoading.showSuccess('Success');
                    Navigator.of(context).pop(state.sale);
                  } else if (state is SalesEditError) {
                    EasyLoading.showError(state.message);
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                      width: 150,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.saveAndValidate() ==
                                true) {
                              var cashString =
                                  _formKey.currentState?.value['cash'];
                              var cash = int.parse(cashString != null &&
                                      cashString.toString().isNotEmpty
                                  ? cashString.toString()
                                  : '0');
                              DateTime? date;
                              if (_formKey.currentState!.value
                                      .containsKey('date') ==
                                  true) {
                                date = _formKey.currentState!.value['date'];
                              }

                              VoucherRecap voucherRecap =
                                  _formKey.currentState!.value['vouchers'];
                              List<SalesDetail> details = [];
                              for (var detail in voucherRecap.vouchers) {
                                if (detail.stock +
                                        detail.balance +
                                        detail.damage +
                                        detail.restock >
                                    0) {
                                  details.add(SalesDetail(
                                      voucherId: detail.id,
                                      price: detail.price,
                                      stock: detail.stock,
                                      balance: detail.balance,
                                      damage: detail.damage,
                                      voucher: Voucher(
                                          id: detail.id,
                                          name: detail.name,
                                          price: detail.price),
                                      restock: detail.restock));
                                }
                              }
                              var currentUser =
                                  context.read<LocalRepository>().currentUser();
                              var modules = currentUser?.modules;
                              var isOperator = (modules?.contains('saleAdd') ==
                                      true &&
                                  modules?.contains('saleOperator') == false);
                              var sales = Sales(
                                  kioskId: widget.item.id,
                                  subtotal: _subtotal,
                                  kioskProfit: (_kioskProfit).floor(),
                                  cash: cash,
                                  debt: _debt,
                                  powerCost: _power ? _powerCost : 0,
                                  total: _total,
                                  operator: isOperator
                                      ? FirebaseAuth.instance.currentUser?.uid
                                      : null,
                                  // user: isOperator?User(uid: FirebaseAuth.instance.currentUser?.uid, email: FirebaseAuth.instance.currentUser?.email, name: FirebaseAuth.instance.currentUser?.n):null,
                                  salesDetails: details,
                                  fundTransferred: false,
                                  date: date);

                              var result =
                                  await Navigator.of(context).push<bool>(
                                SalesKioskInvoice.route(
                                    kiosk: widget.item,
                                    sales: sales,
                                    imageLocalPath: _receiptPath),
                              );
                              if (result == true) {
                                String? token = await FirebaseAuth
                                    .instance.currentUser
                                    ?.getIdToken();
                                if (token != null) {
                                  context.read<SalesEditSaveCubit>().save(
                                      token,
                                      sales,
                                      _receiptPath != null
                                          ? File(_receiptPath!)
                                          : null);
                                }
                              }
                            }
                          },
                          child: const Text('Continue')));
                },
              ),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
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

  int getTotal() {
    // return 0;
    return _subtotal -
        (widget.item.kioskShare * _subtotal).floor() -
        (_power ? _powerCost : 0) +
        _debt;
  }
}
