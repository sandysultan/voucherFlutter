import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:voucher/constant/app_constant.dart';
import 'package:voucher/transfer/transfer.dart';
import 'package:voucher/sales/sales.dart' as sales;

var _logger = Logger();

class TransferPage extends StatelessWidget {
  const TransferPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferPageBloc()..add(const GetGroups()),
      child: const _GetGroupView(),
    );
  }
}

class _GetGroupView extends StatelessWidget {
  const _GetGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransferPageBloc, TransferPageState>(
      buildWhen: (previous, current) =>
          previous != current &&
          (current is GetGroupLoading ||
              current is GetGroupSuccess ||
              current is GetGroupFailed),
      builder: (context, state) {
        Logger().d('_GetGroupViewState rebuild with state $state');
        if (state is GetGroupLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is GetGroupFailed) {
          return Center(
            child: Text(state.message),
          );
        } else if (state is GetGroupSuccess) {
          return _TransferView(state.group);
        } else {
          return Container();
        }
      },
    );
  }
}

class _TransferView extends StatefulWidget {
  final List<String> group;

  const _TransferView(this.group);

  @override
  State<_TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<_TransferView> {
  late String _groupName;

  @override
  void initState() {
    _groupName = widget.group[0];
    context.read<TransferPageBloc>().add(SalesRefresh(_groupName));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.group.length > 1) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: FormBuilderDropdown<String>(
                name: 'group',
                decoration: const InputDecoration(label: Text('Group')),
                isExpanded: true,
                initialValue: _groupName,
                items: widget.group
                    .map((e) =>
                        DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _groupName = value!;
                    context
                        .read<TransferPageBloc>()
                        .add(SalesRefresh(_groupName));
                  });
                }),
          )
        ],
        Expanded(
          child: _TransferRefreshableView(
            groupName: _groupName,
          ),
        ),
      ],
    );
  }
}

class _TransferRefreshableView extends StatelessWidget {
  const _TransferRefreshableView({
    Key? key,
    required this.groupName,
  }) : super(key: key);
  final String groupName;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final itemsBloc = BlocProvider.of<TransferPageBloc>(context)
          ..add(SalesRefresh(groupName));

        return itemsBloc.stream.firstWhere((e) => e is! SalesRefresh);
      },
      child: BlocBuilder<TransferPageBloc, TransferPageState>(
        buildWhen: (previous, current) =>
            previous != current &&
            (current is SalesLoaded ||
                current is SalesEmpty ||
                current is SalesLoading),
        builder: (context, state) {
          if (state is SalesLoaded) {
            _logger.d('state is SalesLoaded');
            // final items = state.sales;
            // var languageCode2 = Localizations.localeOf(context).;
            // var formatter = DateFormat('dd MMMM yyyy hh:mm:ss',);
            return _SalesList(
              key: ObjectKey(state.sales),
              sales: state.sales,
              groupName: groupName,
            );
          } else if (state is SalesEmpty) {
            return const Center(child: Text('Data Empty'));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class _SalesList extends StatefulWidget {
  _SalesList({
    Key? key,
    required List<Sales> sales,
    required this.groupName,
  }) : super(key: key) {
    for (var sale in sales) {
      if (!users.containsKey(sale.operatorUser)) {
        users[sale.operatorUser] = [];
      }
      users[sale.operatorUser]!.add(sale);
    }
  }

  // final List<Sales> items;
  final Map<User?, List<Sales>> users = {};
  final String groupName;

  @override
  State<_SalesList> createState() => _SalesListState();
}

class _SalesListState extends State<_SalesList> {
  final List<Sales> _selected = [];

  // final DateFormat _dateFormat = DateFormat('dd MMMM yyyy hh:mm:ss');
  final NumberFormat _numberFormat = NumberFormat('#,###');

  List<String>? _modules;

  @override
  void initState() {
    _logger.d('_SalesListState initState');
    _modules = context.read<LocalRepository>().currentUser()?.modules;
    _selected.clear();
    for (var element in widget.users.entries) {
      for (var sale in element.value) {
        _selected.add(sale);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: widget.users.entries
                .map((e) => _StickyHeaderList(
                    operator: e.key, sales: e.value, selected: _selected))
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: BlocConsumer<TransferPageBloc, TransferPageState>(
              listenWhen: (previous, current) =>
                  current is AddTransferError ||
                  current is AddTransferLoading ||
                  current is AddTransferSuccess,
              listener: (context, state) {
                if (state is AddTransferError) {
                  EasyLoading.showError(state.message);
                } else if (state is AddTransferLoading) {
                  EasyLoading.show(status: 'Saving Transfer');
                } else if (state is AddTransferSuccess) {
                  EasyLoading.showSuccess('Saving Success');
                  context
                      .read<TransferPageBloc>()
                      .add(SalesRefresh(widget.groupName));
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                    onPressed: () async {
                      var result = await showDialog<bool?>(
                          context: context,
                          builder: (_) {
                            var cashTotal = 0;
                            for (var sale in _selected) {
                                cashTotal += sale.cash;
                            }
                            return AlertDialog(
                              content: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Table(
                                  columnWidths: const {
                                    0: FixedColumnWidth(120),
                                    1: FixedColumnWidth(20)
                                  },
                                  children: [
                                    TableRow(children: [
                                      const TableCell(
                                          child: Text(
                                        'Cash Total',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                      const TableCell(
                                          child: Text(
                                        ' : ',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                      TableCell(
                                          child: Text(
                                        _numberFormat.format(cashTotal),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(
                                          child: Text(
                                        'Operator Fee',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                      const TableCell(
                                          child: Text(
                                        ' : ',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                      TableCell(
                                          child: Text(
                                        _numberFormat
                                            .format((cashTotal / 10).ceil()),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(
                                          child: Text(
                                        'Transfer Amount',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                      const TableCell(
                                          child: Text(
                                        ' : ',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                      TableCell(
                                          child: Text(
                                        _numberFormat.format(cashTotal -
                                            ((cashTotal / 10).ceil())),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                    ]),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close')),
                                if(_modules?.contains(ModuleConstant.transferAdd)==true) ...[
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text('Continue')),]
                              ],
                            );
                          });
                      if (result == true) {
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
                                          final ImagePicker picker =
                                              ImagePicker();
                                          picker
                                              .pickImage(
                                                  source: ImageSource.camera)
                                              .then((value) {
                                            if (value != null) {
                                              cropImage(value).then((value) {
                                                if (value != null) {
                                                  saveTransfer(context, value);
                                                }
                                                Navigator.of(context).pop();
                                              });
                                            } else {
                                              Navigator.of(context).pop();
                                            }
                                          });
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Gallery'),
                                        leading: const Icon(Icons.image_search),
                                        onTap: () async {
                                          final ImagePicker picker =
                                              ImagePicker();
                                          picker
                                              .pickImage(
                                                  source: ImageSource.gallery)
                                              .then((value) {
                                            if (value != null) {
                                              cropImage(value).then((value) {
                                                if (value != null) {
                                                  saveTransfer(context, value);
                                                }
                                                Navigator.of(context).pop();
                                              });
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
                    },
                    child: const Text('Continue'));
              },
            ),
          ),
        )
      ],
    );
  }

  void saveTransfer(BuildContext context, CroppedFile value) {
    var total = 0;
    List<Sales> sales = [];
    for (var sale in _selected) {
        sales.add(sale);
        total += sale.cash;
    }
    List<int> salesIds = sales.map((e) => e.id ?? 0).toList();
    context.read<TransferPageBloc>().add(
        AddTransfer(Transfer(total: total, salesIds: salesIds), value.path));
  }

  Future<CroppedFile?> cropImage(XFile image) async {
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
    return croppedFile;
  }
}

class _StickyHeaderList extends StatefulWidget {
  const _StickyHeaderList({
    Key? key,
    required this.sales,
    this.operator,
    required this.selected,
  }) : super(key: key);

  final List<Sales> sales;
  final List<Sales> selected;
  final User? operator;

  @override
  State<_StickyHeaderList> createState() => _StickyHeaderListState();
}

class _StickyHeaderListState extends State<_StickyHeaderList> {
  late final List<Sales> _selected;
  int _total=0;
  int _totalSelected=0;

  @override
  void initState() {
    _selected = widget.selected;
    _total=0;

    _totalSelected =0;
    for (var sale in widget.sales) {
      _total +=sale.cash;
      if(_selected.contains(sale)) {
        _totalSelected++;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy hh:mm:ss');
    final NumberFormat numberFormat = NumberFormat('#,###');
    return SliverStickyHeader(
      header: _Header(
          name: widget.operator?.name ?? '',
          total: '${numberFormat.format(_total)} - 10% = ${numberFormat.format(_total*0.9)}',
          value: _totalSelected==0?false:(_totalSelected==widget.sales.length?true:null)),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => ListTile(
            onTap: () async {
              Navigator.of(context).push<void>(
                sales.SalesKioskInvoice.route(
                    kiosk: widget.sales[i].kiosk!, sales: widget.sales[i]),
              );
            },
            leading: CircleAvatar(
              child: Text(
                widget.sales[i].kioskId.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              // backgroundColor: days >= 7 ? Colors.red : Colors.blue,
            ),
            title: Text(
                "${widget.sales[i].kiosk?.kioskName ?? ""}, Rp. ${numberFormat.format(widget.sales[i].cash)}"),

            subtitle: Text(dateFormat.format(widget.sales[i].date!)),
            trailing: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Checkbox(
                value: _selected.contains(widget.sales[i]),
                // value:  false,
                onChanged: (bool? value) {
                  setState(() {
                    if(_selected.contains(widget.sales[i])) {
                      _selected.remove(widget.sales[i]);
                      _total-=widget.sales[i].cash;
                      _totalSelected--;
                    } else {
                      _selected.add(widget.sales[i]);
                      _total+=widget.sales[i].cash;
                      _totalSelected++;
                    }
                  });
                },
              ),
            ),
          ),
          childCount: widget.sales.length,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
    required this.name,
    required this.total,
    this.value,

  }) : super(key: key);

  final String name;
  final String total;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // print('hit $index');
      },
      child: Container(
        height: 50,
        color: Colors.lightBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Text(
              total,
              style: const TextStyle(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Checkbox(
                value: value,
                onChanged: (value) {},
                tristate: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}
