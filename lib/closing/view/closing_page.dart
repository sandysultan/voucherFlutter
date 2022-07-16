import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:iVoucher/closing/closing.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:repository/src/model/closing_status_response.dart';

var _logger = Logger();

class ClosingPage extends StatelessWidget {
  const ClosingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClosingBloc()..add(GetGroups()),
      child: const _GetGroupView(),
    );
  }
}

class _GetGroupView extends StatelessWidget {
  const _GetGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClosingBloc, ClosingState>(
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
          context.read<ClosingBloc>().add(GetStatus(
                groupName: state.group[0],
              ));
          return _ClosingView(state.group);
        } else {
          return Container();
        }
      },
    );
  }
}

class _ClosingView extends StatelessWidget {
  final List<String> groups;

  const _ClosingView(this.groups);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              if (groups.length > 1) ...[
                Flexible(
                  flex: 1,
                  child: FormBuilderDropdown<String>(
                      name: 'group',
                      decoration: const InputDecoration(
                        label: Text('Group'),
                      ),
                      isExpanded: true,
                      initialValue: groups[0],
                      items: groups
                          .map((e) => DropdownMenuItem<String>(
                              value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        // _groupName = value!;
                        context.read<ClosingBloc>().add(GetStatus(
                              groupName: value!,
                            ));
                      }),
                )
              ],
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<ClosingBloc, ClosingState>(
              buildWhen: (previous, current) =>
                  current is GetStatusLoading ||
                  current is GetStatusSuccess ||
                  current is GetStatusFailed,
              builder: (context, state) {
                if (state is GetStatusSuccess) {
                  return _ClosingDetailView(state.groupName, state.response);
                } else if (state is GetStatusFailed) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ClosingDetailView extends StatefulWidget {
  const _ClosingDetailView(
    this.groupName,
    this.response, {
    Key? key,
  }) : super(key: key);
  final String groupName;
  final StatusClosingResponse response;

  @override
  State<_ClosingDetailView> createState() => _ClosingDetailViewState();
}

class _ClosingDetailViewState extends State<_ClosingDetailView> {
  var _capital = false;
  var _expense = false;
  var _sales = false;
  final Map<User, int> _capitals = {};
  final Map<User, double> _boosters = {};
  late List<User> _investors;
  int _totalCash = 0;
  int _unTransferred = 0;
  int _totalAsset = 0;
  int _totalMaintenance = 0;

  @override
  void initState() {
    widget.response.capitals?.forEach((element) {
      if (_capitals.containsKey(element.user)) {
        _capitals[element.user!] = _capitals[element.user!]! + element.total;
      } else {
        _capitals[element.user!] = element.total;
      }
    });
    _investors = _capitals.keys.toList();
    widget.response.boosters?.forEach((element) {
      _boosters[element.user!] = element.boost;
    });
    widget.response.sales?.forEach((element) {
      if (!element.fundTransferred) {
        _unTransferred += element.cash;
      }
      _totalCash += element.cash;
    });
    widget.response.expenses?.forEach((element) {
      if (element.expenseType?.asset == true) {
        _totalAsset += element.total;
      } else {
        _totalMaintenance += element.total;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("MMMM yyyy");
    NumberFormat numberFormat = NumberFormat("#,###");

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            dateFormat.format(DateTime(
                widget.response.year ?? 0, widget.response.month ?? 0, 1)),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          const Text(
            'Please make sure all this data below already correct before closing, check the box for confirm',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          Card(
            elevation: 4,
            child: Column(
              children: [
                FormBuilderCheckbox(
                  // controlAffinity: ListTileControlAffinity.trailing,

                  title: const Text('Total capitals investment in this month'),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _capital = value == true;
                    });
                  },
                  name: 'capital',
                ),
                _investors.isEmpty
                    ? const Padding(
                        padding:
                            EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                        child: Text("No investment recorded this month"),
                      )
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _investors.length,
                        itemBuilder: (BuildContext context, int index) =>
                            ListTile(
                          title: Text(_investors[index].name),
                          trailing: _boosters.containsKey(_investors[index])
                              ? Text(
                                  'Boosted up to ${(_boosters[_investors[index]]! * 100).toStringAsFixed(2)}%')
                              : null,
                          subtitle: Text(
                              "Rp. ${numberFormat.format(_capitals[_investors[index]])}"),
                        ),
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                      )
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Card(
            elevation: 4,
            child: Column(
              children: [
                FormBuilderCheckbox(
                  onChanged: (value) {
                    setState(() {
                      _sales = value == true;
                    });
                  },
                  name: 'sales',
                  title: const Text("Sales"),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(180),
                      1: FixedColumnWidth(20)
                    },
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
                            "Rp. ${numberFormat.format(_totalCash)}",
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
                            "Rp. ${numberFormat.format(_totalCash * 0.1)}",
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
                            "Rp. ${numberFormat.format(_totalCash * 0.9)}",
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const TableCell(
                          child: Text('Pending Transferred Cash'),
                        ),
                        const TableCell(
                          child: Text(' : '),
                        ),
                        TableCell(
                          child: Text(
                            "Rp. ${numberFormat.format(_unTransferred)}",
                            style: TextStyle(
                                color: _unTransferred > 0 ? Colors.red : null),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Card(
            elevation: 4,
            child: Column(
              children: [
                FormBuilderCheckbox(
                  onChanged: (value) {
                    setState(() {
                      _expense = value == true;
                    });
                  },
                  name: 'expense',
                  title: const Text("Expenses"),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(200),
                      1: FixedColumnWidth(20),
                    },
                    children: [
                      TableRow(children: [
                        const TableCell(
                          child: Text('Total Expense For Asset'),
                        ),
                        const TableCell(
                          child: Text(' : '),
                        ),
                        TableCell(
                          child: Text(
                            "Rp. ${numberFormat.format(_totalAsset)}",
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const TableCell(
                          child: Text('Total Expense For Maintenance'),
                        ),
                        const TableCell(
                          child: Text(' : '),
                        ),
                        TableCell(
                          child: Text(
                            "Rp. ${numberFormat.format(_totalMaintenance)}",
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const TableCell(
                          child: Text('Total Expenses'),
                        ),
                        const TableCell(
                          child: Text(' : '),
                        ),
                        TableCell(
                          child: Text(
                            "Rp. ${numberFormat.format(_totalAsset + _totalMaintenance)}",
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width: double.infinity,
            child: BlocConsumer<ClosingBloc, ClosingState>(
              listenWhen: (previous, current) =>
                  current is CloseLoading ||
                  current is CloseSuccess ||
                  current is CloseFailed,
              listener: (context, state) {
                if(state is CloseLoading){
                  EasyLoading.show(status: "Closing");
                }else if(state is CloseFailed){
                  EasyLoading.showError(state.message);
                }else if(state is CloseSuccess){
                  EasyLoading.showSuccess("Closing Success");
                  context
                      .read<ClosingBloc>()
                      .add(GetStatus(groupName: widget.groupName));
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                  onPressed:
                      _sales == true && _capital == true && _expense == true
                          ? () {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        title: const Text("Confirmation"),
                                        content: Text(
                                          "Are you sure want to close ${dateFormat.format(DateTime(widget.response.year ?? 0, widget.response.month ?? 0, 1))}?",
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel")),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text("Yes")),
                                        ],
                                      )).then((value) {
                                if (value == true) {
                                  context
                                      .read<ClosingBloc>()
                                      .add(Close(groupName: widget.groupName));
                                }
                              });
                            }
                          : null,
                  child: const Text('Close'),
                );
              },
            ),
          ),
          const SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }
}
