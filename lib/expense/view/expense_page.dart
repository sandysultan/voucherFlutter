import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:repository/repository.dart';
import 'package:voucher/expense/expense.dart';
import 'package:voucher/expense/view/expense_edit_page.dart';
import 'package:voucher/home/home.dart';

var _logger = Logger();

class ExpensePage extends StatelessWidget {
  const ExpensePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc()..add(const GetGroups()),
      child: const _GetGroupView(),
    );
  }
}

class _GetGroupView extends StatelessWidget {
  const _GetGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
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
          return _ExpenseView(state.group);
        } else {
          return Container();
        }
      },
    );
  }
}

class _ExpenseView extends StatefulWidget {
  final List<String> groups;

  const _ExpenseView(this.groups);

  @override
  State<_ExpenseView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<_ExpenseView> {
  late String _groupName;
  DateTime _dateTime = DateTime.now();
  final DateFormat _monthFormatter = DateFormat('MMMM yyyy');

  @override
  void initState() {
    _groupName = widget.groups[0];
    context.read<ExpenseBloc>().add(ExpenseRefresh(
        groupName: _groupName,
        year: DateTime.now().year,
        month: DateTime.now().month));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) async {
        _logger.d('expense_page listened to homebloc');
        if (state is AppBarClicked) {
          if (state.idAction == actionAddExpense) {
            await Navigator.of(context)
                .push<bool?>(
              ExpenseEditPage.route(
                  groups: widget.groups,
                  groupName: _groupName,
                  date: _dateTime),
            )
                .then((result) {
              if (result == true) {
                context.read<ExpenseBloc>().add(ExpenseRefresh(
                    groupName: _groupName,
                    year: _dateTime.year,
                    month: _dateTime.month));
              }
            });
          }
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              // textBaseline: TextBaseline.ideographic,
              children: [
                if (widget.groups.length > 1) ...[
                  Flexible(
                    flex: 1,
                    child: FormBuilderDropdown<String>(
                        name: 'group',
                        decoration: const InputDecoration(
                          label: Text('Group'),
                        ),
                        isExpanded: true,
                        initialValue: _groupName,
                        items: widget.groups
                            .map((e) => DropdownMenuItem<String>(
                                value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          // setState(() {
                          _groupName = value!;
                          context.read<ExpenseBloc>().add(ExpenseRefresh(
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
                              ?.copyWith(color: Colors.black54),
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

                                          context.read<ExpenseBloc>().add(
                                              ExpenseRefresh(
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

                                          context.read<ExpenseBloc>().add(
                                              ExpenseRefresh(
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

                                            context.read<ExpenseBloc>().add(
                                                ExpenseRefresh(
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
            child: _ExpenseRefreshableView(
                groupName: _groupName, dateTime: _dateTime),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRefreshableView extends StatelessWidget {
  final String groupName;
  final DateTime dateTime;

  const _ExpenseRefreshableView(
      {Key? key, required this.groupName, required this.dateTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final itemsBloc = BlocProvider.of<ExpenseBloc>(context)
          ..add(ExpenseRefresh(
              groupName: groupName,
              year: dateTime.year,
              month: dateTime.month));

        return itemsBloc.stream.firstWhere((e) => e is! ExpenseRefresh);
      },
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        buildWhen: (previous, current) =>
            current != previous &&
            (current is ExpenseLoaded ||
                current is ExpenseEmpty ||
                current is ExpenseLoading),
        builder: (context, state) {
          if (state is ExpenseLoaded) {
            // final items = state.kiosks;
            // var languageCode2 = Localizations.localeOf(context).;
            // var formatter = DateFormat('dd MMMM yyyy hh:mm:ss',);
            return _ExpenseList(
              items: state.expenses,
            );
          } else if (state is ExpenseEmpty) {
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

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({
    Key? key,
    required this.items,
  }) : super(key: key);

  final List<Expense> items;

  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat('#,###');
    DateFormat dateFormat = DateFormat('d MMMM yyyy');
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        Expense item = items[index];
        return ListTile(
          title: Text(
              '${dateFormat.format(item.date)} Rp. ${numberFormat.format(item.total)}'),

          subtitle: Text(item.description),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: items.length,
    );
  }
}
