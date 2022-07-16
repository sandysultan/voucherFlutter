import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http_client/http_client.dart';
import 'package:iVoucher/transfer_report/bloc/transfer_report_bloc.dart';
import 'package:iVoucher/widget/image_preview.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:repository/repository.dart';

var _logger = Logger();

class TransferReportPage extends StatelessWidget {
  const TransferReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferReportBloc()..add(const GetGroups()),
      child: const _GetGroupView(),
    );
  }
}

class _GetGroupView extends StatelessWidget {
  const _GetGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransferReportBloc, TransferReportState>(
      buildWhen: (previous, current) =>
          previous != current &&
          (current is GetGroupLoading ||
              current is GetGroupSuccess ||
              current is GetGroupFailed),
      builder: (context, state) {
        _logger.d('_GetGroupViewState rebuild with state $state');
        if (state is GetGroupLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is GetGroupFailed) {
          return Center(
            child: Text(state.message),
          );
        } else if (state is GetGroupSuccess) {
          return _SalesReportView(state.group);
        } else {
          return Container();
        }
      },
    );
  }
}

class _SalesReportView extends StatefulWidget {
  final List<String> group;

  const _SalesReportView(this.group);

  @override
  State<_SalesReportView> createState() => _SalesReportViewState();
}

class _SalesReportViewState extends State<_SalesReportView> {
  late String _groupName;
  DateTime _dateTime = DateTime.now();
  final DateFormat _monthFormatter = DateFormat('MMMM yyyy');

  @override
  void initState() {
    _groupName = widget.group[0];
    context.read<TransferReportBloc>().add(TransferRefresh(
        groupName: _groupName,
        year: DateTime.now().year,
        month: DateTime.now().month));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            // textBaseline: TextBaseline.ideographic,
            children: [
              if (widget.group.length > 1) ...[
                Flexible(
                  flex: 1,
                  child: FormBuilderDropdown<String>(
                      name: 'group',
                      decoration: const InputDecoration(
                        label: Text('Group'),
                      ),
                      isExpanded: true,
                      initialValue: _groupName,
                      items: widget.group
                          .map((e) => DropdownMenuItem<String>(
                              value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        // setState(() {
                        _groupName = value!;
                        context.read<TransferReportBloc>().add(TransferRefresh(
                            groupName: _groupName,
                            year: _dateTime.year,
                            month: _dateTime.month));
                        // });
                      }),
                )
              ],
              Flexible(
                flex: 2,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, left: 16),
                      child: Text(
                        'Month',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Theme.of(context).hintColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          Row(
                              // textBaseline: TextBaseline.ideographic,
                              // mainAxisAlignment: MainAxisAlignment.center,
                              //   crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _dateTime = DateTime(
                                            _dateTime.month == 1
                                                ? _dateTime.year - 1
                                                : _dateTime.year,
                                            _dateTime.month == 1
                                                ? 12
                                                : _dateTime.month - 1,
                                            1);

                                        context.read<TransferReportBloc>().add(
                                            TransferRefresh(
                                                groupName: _groupName,
                                                year: _dateTime.year,
                                                month: _dateTime.month));
                                      });
                                    },
                                    icon: const Icon(Icons.chevron_left)),
                                Expanded(
                                    child: InkWell(
                                  onTap: () async {
                                    DateTime? newDate = await showMonthPicker(
                                        context: context,
                                        initialDate: _dateTime,
                                        lastDate: DateTime.now());
                                    if (newDate != null &&
                                        newDate != _dateTime) {
                                      setState(() {
                                        _dateTime = newDate;

                                        context.read<TransferReportBloc>().add(
                                            TransferRefresh(
                                                groupName: _groupName,
                                                year: _dateTime.year,
                                                month: _dateTime.month));
                                      });
                                    }
                                  },
                                  child: Text(
                                    _monthFormatter.format(_dateTime),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                                IconButton(
                                    onPressed: () {
                                      DateTime newDate;
                                      newDate = DateTime(
                                          _dateTime.month == 12
                                              ? _dateTime.year + 1
                                              : _dateTime.year,
                                          _dateTime.month == 12
                                              ? 1
                                              : _dateTime.month + 1,
                                          1);

                                      if (newDate.isBefore(DateTime.now())) {
                                        setState(() {
                                          _dateTime = newDate;

                                          context
                                              .read<TransferReportBloc>()
                                              .add(TransferRefresh(
                                                  groupName: _groupName,
                                                  year: _dateTime.year,
                                                  month: _dateTime.month));
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.chevron_right)),
                              ]),
                          Container(
                            color: Colors.grey,
                            width: double.infinity,
                            height: 1,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _TransferRefreshableView(
              groupName: _groupName, dateTime: _dateTime),
        ),
      ],
    );
  }
}

class _TransferRefreshableView extends StatelessWidget {
  final String groupName;
  final DateTime dateTime;

  const _TransferRefreshableView(
      {Key? key, required this.groupName, required this.dateTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final itemsBloc = BlocProvider.of<TransferReportBloc>(context)
          ..add(TransferRefresh(
              groupName: groupName,
              year: dateTime.year,
              month: dateTime.month));

        return itemsBloc.stream.firstWhere((e) => e is! TransferRefresh);
      },
      child: BlocBuilder<TransferReportBloc, TransferReportState>(
        buildWhen: (previous, current) =>
            current != previous &&
            (current is TransferLoaded ||
                current is TransferEmpty ||
                current is TransferLoading),
        builder: (context, state) {
          if (state is TransferLoaded) {
            // final items = state.kiosks;
            // var languageCode2 = Localizations.localeOf(context).;
            // var formatter = DateFormat('dd MMMM yyyy hh:mm:ss',);
            return _SalesList(
              items: state.transfers,
            );
          } else if (state is TransferEmpty) {
            return Center(child: Text(state.message));
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

class _SalesList extends StatelessWidget {
  const _SalesList({
    Key? key,
    required this.items,
  }) : super(key: key);

  final List<Transfer> items;

  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat('#,###');
    DateFormat dateFormat = DateFormat('d MMMM yyyy');
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        Transfer item = items[index];
        return ListTile(
          onTap: () {
            var cashTotal = 0;
            for (Sales sales in item.sales ?? []) {
              cashTotal += sales.cash;
            }
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      content: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                  itemBuilder: (context, index) => ListTile(
                                        title: Text(item.sales?[index].kiosk
                                                ?.kioskName ??
                                            ""),
                                        subtitle: Text(item
                                                    .sales?[index].date ==
                                                null
                                            ? ''
                                            : dateFormat.format(
                                                item.sales![index].date!)),
                                        trailing: Text(numberFormat
                                            .format(item.sales![index].cash)),
                                      ),
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemCount: item.sales?.length ?? 0),
                            ),
                            Card(
                              child: Padding(
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
                                        numberFormat.format(cashTotal),
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
                                        numberFormat
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
                                        numberFormat.format(cashTotal -
                                            ((cashTotal / 10).ceil())),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                    ]),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push<void>(
                                ImagePreview.route(
                                    network:
                                         '${HttpClient.server}transfer/${item.id}/receipt'
                                        ),
                              );
                            },
                            child: const Text('Receipt')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close')),
                      ],
                    ));
          },
          title: Text('Rp. ${numberFormat.format(item.total)}'),

          subtitle: Text(dateFormat.format(item.createdAt!)),
          trailing: Text('${item.sales?.length ?? 0} sales'),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: items.length,
    );
  }
}
