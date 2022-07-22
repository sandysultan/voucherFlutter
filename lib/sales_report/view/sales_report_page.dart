import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:repository/repository.dart';
import 'package:iVoucher/sales/sales.dart' as sales;
import 'package:iVoucher/sales_report/sales_report.dart';

class SalesReportPage extends StatelessWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesReportBloc()..add(const GetGroups()),
      child: const _GetGroupView(),
    );
  }
}

class _GetGroupView extends StatelessWidget {
  const _GetGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesReportBloc, SalesReportState>(
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
    context.read<SalesReportBloc>().add(SalesRefresh(
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
                        context.read<SalesReportBloc>().add(SalesRefresh(
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

                                        context.read<SalesReportBloc>().add(
                                            SalesRefresh(
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

                                        context.read<SalesReportBloc>().add(
                                            SalesRefresh(
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

                                          context.read<SalesReportBloc>().add(
                                              SalesRefresh(
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
          child:
              _SalesRefreshableView(groupName: _groupName, dateTime: _dateTime),
        ),
      ],
    );
  }
}

class _SalesRefreshableView extends StatelessWidget {
  final String groupName;
  final DateTime dateTime;

  const _SalesRefreshableView(
      {Key? key, required this.groupName, required this.dateTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final itemsBloc = BlocProvider.of<SalesReportBloc>(context)
          ..add(SalesRefresh(
              groupName: groupName,
              year: dateTime.year,
              month: dateTime.month));

        return itemsBloc.stream.firstWhere((e) => e is! SalesRefresh);
      },
      child: BlocBuilder<SalesReportBloc, SalesReportState>(
        buildWhen: (previous, current) =>
            current != previous &&
            (current is SalesLoaded ||
                current is SalesEmpty ||
                current is SalesLoading),
        builder: (context, state) {
          if (state is SalesLoaded) {
            // final items = state.kiosks;
            // var languageCode2 = Localizations.localeOf(context).;
            // var formatter = DateFormat('dd MMMM yyyy hh:mm:ss',);
            return _SalesList(
              items: state.kiosks,
              totalCashMap: state.totalCashMap,
              totalCash: state.totalCash,
              dateTime: dateTime,
            );
          } else if (state is SalesEmpty) {
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
    required this.totalCashMap,
    required this.totalCash,
    required this.dateTime,
  }) : super(key: key);

  final List<Kiosk> items;
  final Map<Kiosk, int> totalCashMap;
  final int totalCash;
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat('#,###');
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              Kiosk item = items[index];
              return ListTile(
                onTap: () {
                  Navigator.of(context).push<void>(
                    sales.SalesKioskList.route(item, dateTime: dateTime),
                  );
                },
                title: Text(item.kioskName),
                subtitle: Text('${item.sales?.length ?? 0} bills, ${item.sales?.where((element) => element.cash==0).toList().length??0} failed'),
                trailing: SizedBox(
                    width: 70,
                    child: Text(
                      numberFormat.format(totalCashMap[item]),
                      textAlign: TextAlign.end,
                    )),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: items.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                child: Table(
                  columnWidths: const {1: FixedColumnWidth(20)},
                  children: [
                    TableRow(children: [
                      const TableCell(
                        child: Text('Total Cash'),
                      ),
                      const TableCell(
                        child: Text(' : '),
                      ),
                      TableCell(
                        child: Text(
                          numberFormat.format(totalCash),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const TableCell(
                        child: Text('Operator Fee'),
                      ),
                      const TableCell(
                        child: Text(' : '),
                      ),
                      TableCell(
                        child: Text(
                          numberFormat.format(totalCash * 0.1),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const TableCell(
                        child: Text('Total'),
                      ),
                      const TableCell(
                        child: Text(' : '),
                      ),
                      TableCell(
                        child: Text(
                          numberFormat.format(totalCash * 0.9),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
