import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class VoucherSold extends FormBuilderField<VoucherRecap> {
  VoucherSold(
      {Key? key,
      VoucherRecap? initialValue,
      required ValueChanged<VoucherRecap?> onChanged,
      FormFieldValidator<VoucherRecap>? validator})
      : super(
          key: key,
          name: 'vouchers',
          onChanged: onChanged,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<VoucherRecap> field) {
            return Column(
              children: [
                _VoucherTableView(
                    voucherRecap: field.value,
                    onChanged: (voucherRecap) {
                      onChanged(voucherRecap);
                      field.didChange(voucherRecap);
                    }),
                field.hasError
                    ? Text(
                        field.errorText!,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      )
                    : Container()
              ],
            );
            // return Placeholder();
          },
        );
}

class _VoucherTableView extends StatefulWidget {
  final VoucherRecap? voucherRecap;
  final ValueChanged<VoucherRecap> onChanged;
  const _VoucherTableView({this.voucherRecap, required this.onChanged});

  @override
  State<_VoucherTableView> createState() => _VoucherTableViewState();
}

class _VoucherTableViewState extends State<_VoucherTableView> {
  List<VoucherItem>? _vouchers;
  int _subTotal = 0;

  @override
  void initState() {
    _vouchers = widget.voucherRecap?.vouchers;
    for (VoucherItem voucher in _vouchers ?? []) {
      _subTotal +=
          voucher.price * (voucher.stock - voucher.balance - voucher.damage);
      logger.d('_subTotal $_subTotal');
    }
    super.initState();
  }

  final logger = Logger();
  @override
  Widget build(BuildContext context) {
    var list = [
      const TableRow(children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Voucher',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Price',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Stock',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Balance',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Damage',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Restock',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ]),
    ];
    list.addAll(widget.voucherRecap?.vouchers
            .asMap()
            .entries
            .map(
              (e) => _VoucherItemView(e.value, (value) {
                setState(() {
                  _subTotal = 0;
                  for (VoucherItem voucher in _vouchers ?? []) {
                    _subTotal += voucher.price *
                        (voucher.stock - voucher.balance);
                  }
                  // logger.d('_subTotal ' + _subTotal.toString());
                  widget.onChanged(VoucherRecap(
                      vouchers: _vouchers ?? [], subTotal: _subTotal));
                });
              }),
            )
            .toList() ??
        []);

    var formatter = NumberFormat('#,###');

    return Column(
      children: [
        Table(
          children: list,
        ),
        // if (field.hasError)
        //   Text(
        //     field.errorText??"",
        //     style: const TextStyle(color: Colors.red, fontSize: 13),
        //   ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Table(
            columnWidths: const {
              1: FixedColumnWidth(50),
              2: FixedColumnWidth(50),
              3: FixedColumnWidth(20),
              4: FixedColumnWidth(20),
              5: FixedColumnWidth(20),
              6: FixedColumnWidth(60),
            },
            children: _vouchers
                    ?.map((e) => TableRow(
                          children: [
                            Container(),
                            Text(e.name),
                            Text(
                              formatter.format(e.price),
                              textAlign: TextAlign.right,
                            ),
                            const Text(' x '),
                            Text(
                              formatter.format(e.stock - e.balance),
                              textAlign: TextAlign.right,
                            ),
                            const Text(' = '),
                            Text(
                              formatter.format(e.price * (e.stock - e.balance)),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ))
                    .toList() ??
                [],
          ),
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
                const Text(
                  'Subtotal',
                  textAlign: TextAlign.end,
                ),
                const Text(' = '),
                Text(
                  formatter.format(_subTotal),
                  textAlign: TextAlign.right,
                )
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoucherItemView extends TableRow {
  _VoucherItemView(VoucherItem e, ValueChanged<VoucherItem> onChanged)
      : super(
          children: [
            SizedBox(
                height: 30,
                child: Center(
                    child: Text(
                  e.name,
                  style: const TextStyle(fontSize: 12),
                ))),
            _NumberField(
              e.price,
              readOnly: true,
              onChanged: (value) {
                e.price = value == "" ? 0 : int.parse(value);
                onChanged(e);
              },
            ),
            _NumberField(
              e.stock,
              onChanged: (value) {
                e.stock = value == "" ? 0 : int.parse(value);
                onChanged(e);
              },
            ),
            _NumberField(
              e.balance,
              onChanged: (value) {
                e.balance = value == "" ? 0 : int.parse(value);
                onChanged(e);
              },
            ),
            _NumberField(
              e.damage,
              onChanged: (value) {
                e.damage = value == "" ? 0 : int.parse(value);
                onChanged(e);
              },
            ),
            _NumberField(
              e.restock,
              onChanged: (value) {
                e.restock = value == "" ? 0 : int.parse(value);
                onChanged(e);
              },
            ),
          ],
        );
}

class _NumberField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final bool? readOnly;
  final int initialValue;

  const _NumberField(this.initialValue, {this.onChanged, this.readOnly});

  @override
  Widget build(BuildContext context) {
    var s = initialValue.toString();
    var controller = TextEditingController(
      text: s,
    );
    controller.selection =
        TextSelection(baseOffset: s.length, extentOffset: s.length);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
          onChanged: onChanged,
          readOnly: readOnly ?? false,
          maxLength: 3,
          controller: controller,
          decoration: const InputDecoration(isDense: true, counter: Offstage()),
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(
              signed: true, decimal: false)),
    );
  }
}

class VoucherRecap {
  List<VoucherItem> vouchers;
  int subTotal;

  VoucherRecap({required this.vouchers, required this.subTotal});
}

class VoucherItem {
  final int id;
  final String name;
  int price;
  int stock;
  int balance;
  int damage;
  int restock;

  VoucherItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.stock,
      required this.balance,
      required this.damage,
      required this.restock});
}
