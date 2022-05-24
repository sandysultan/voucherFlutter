import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:voucher/transfer/transfer.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key? key}) : super(key: key);

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  String? _groupName;
  final logger = Logger();
  List<String>? _groups;

  @override
  void initState() {
    _groups = context.read<LocalRepository>().currentUser()?.groups;
    logger.d(_groups);
    if ((_groups?.length ?? 0) > 0) {
      _groupName = _groups![0];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if ((_groups?.length ?? 0) > 1) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: FormBuilderDropdown<String>(
                name: 'group',
                decoration: const InputDecoration(label: Text('Group')),
                isExpanded: true,
                initialValue: _groupName,
                items: _groups!
                    .map((e) =>
                        DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _groupName = value;
                  });
                }),
          )
        ],
        if (_groupName != null) ...[
          Expanded(
            child: BlocProvider(
              key: ObjectKey(_groupName),
              create: (context) => TransferPageBloc()
                ..add(SalesRefresh(
                  _groupName!,
                )),
              child: _TransferView(
                groupName: _groupName!,
              ),
            ),
          )
        ],
      ],
    );
  }
}

class _TransferView extends StatelessWidget {
  const _TransferView({
    Key? key,
    required this.groupName,
  }) : super(key: key);
  final String groupName;
  @override
  Widget build(BuildContext context) {
    // return Text(groupName);
    return RefreshIndicator(
      onRefresh: () {
        final itemsBloc = BlocProvider.of<TransferPageBloc>(context)
          ..add(SalesRefresh(groupName));

        return itemsBloc.stream.firstWhere((e) => e is! SalesRefresh);
      },
      child: BlocBuilder<TransferPageBloc, TransferPageState>(
        buildWhen: (previous, current) =>
            current is SalesLoaded || current is SalesEmpty,
        builder: (context, state) {
          if (state is SalesLoaded) {
            // return Text(groupName);
            final items = state.sales;
            // var languageCode2 = Localizations.localeOf(context).;
            // var formatter = DateFormat('dd MMMM yyyy hh:mm:ss',);
            return _SalesList(
              items: items,
              groupName: groupName,
            );
          } else if (state is SalesEmpty) {
            // return Text(groupName);
            return const Center(child: Text('Data Empty'));
          } else {
            // return Text(groupName);
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
  const _SalesList({
    Key? key,
    required this.items,
    required this.groupName,
  }) : super(key: key);

  final List<Sales> items;
  final String groupName;

  @override
  State<_SalesList> createState() => _SalesListState();
}

class _SalesListState extends State<_SalesList> {
  final Map<Sales, bool> _selected = {};
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy hh:mm:ss');
  final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    for (var element in widget.items) {
      _selected[element] = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    item.kioskId.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  // backgroundColor: days >= 7 ? Colors.red : Colors.blue,
                ),
                title: Text((item.kiosk?.kioskName ?? "") +
                    ", Rp. " +
                    _numberFormat.format(item.cash)),
                // subtitle: Text(days > 0
                //     ? days.toString() + " day(s) from last billing"
                //     : ""),
                subtitle: Text(_dateFormat.format(item.date!)),
                trailing: InkWell(
                  onTap: () async {
                    setState(() {
                      _selected[item] = !(_selected[item] ?? false);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Checkbox(
                      value: _selected[item] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          _selected[item] = value ?? false;
                        });
                      },
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: widget.items.length,
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
                            _selected.forEach((key, value) {
                              if (value) {
                                cashTotal += key.cash;
                              }
                            });
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
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text('Continue')),
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
      var total = 0;
      List<Sales> sales = [];
      _selected.forEach((key, value) {
        if (value) {
          sales.add(key);
          total += key.cash;
        }
      });
      List<int> salesIds = sales.map((e) => e.id ?? 0).toList();
      context.read<TransferPageBloc>().add(AddTransfer(
          Transfer(total: total, salesIds: salesIds), croppedFile.path));
    }
  }
}