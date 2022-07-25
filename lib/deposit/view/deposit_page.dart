import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iVoucher/deposit/deposit.dart';
import 'package:iVoucher/widget/month_picker.dart';
import 'package:intl/intl.dart';
import 'package:repository/src/model/deposit.dart';

class DepositPage extends StatelessWidget {
  const DepositPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DepositBloc()..add(GetGroups()),
      child: _DepositView(),
    );
  }
}

class _DepositView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    String? groupName;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<DepositBloc, DepositState>(
            buildWhen: (previous, current) =>
                current is GetGroupLoading ||
                current is GetGroupSuccess ||
                current is GetGroupFailed,
            builder: (context, state) {
              if (state is GetGroupFailed) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state is GetGroupSuccess) {
                if (state.group.length > 1) {
                  return FormBuilderDropdown<String>(
                    name: 'group',
                    decoration: const InputDecoration(label: Text('Group')),
                    isExpanded: true,
                    items: state.group
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        groupName = value;
                        context.read<DepositBloc>().add(
                            GetDeposit(value, dateTime.year, dateTime.month));
                      }
                    },
                    validator: FormBuilderValidators.required(),
                  );
                } else if (state.group.isNotEmpty) {
                  groupName = state.group[0];
                  context.read<DepositBloc>().add(GetDeposit(
                      state.group[0], dateTime.year, dateTime.month));
                  return FormBuilderTextField(
                    name: 'group',
                    decoration: const InputDecoration(label: Text('Group')),
                    readOnly: true,
                    initialValue: state.group[0],
                  );
                } else {
                  return Container();
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MonthPicker(onChanged: (value) {
            dateTime = value;
            if (groupName != null) {
              context
                  .read<DepositBloc>()
                  .add(GetDeposit(groupName!, dateTime.year, dateTime.month));
            }
          }),
        ),
        Expanded(
            child: BlocBuilder<DepositBloc, DepositState>(
          buildWhen: (previous, current) =>
              current is GetDepositLoading ||
              current is GetDepositSuccess ||
              current is GetDepositFailed,
          builder: (context, state) {
            if (state is GetDepositLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GetDepositFailed) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              );
            } else if (state is GetDepositSuccess) {
              return _TabView(state.deposits);
            } else {
              return Container();
            }
          },
        )),
      ],
    );
  }
}

class _TabView extends StatefulWidget {
  const _TabView(this.deposits);

  final List<Deposit> deposits;

  @override
  State<_TabView> createState() => _TabViewState();
}

class _TabViewState extends State<_TabView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  final NumberFormat _numberFormat = NumberFormat('#,###');
  int total = 0;
  final Map<int, Deposit> expenses = {};
  final Map<String?, Deposit> investors = {};

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    for (Deposit deposit in widget.deposits) {
      if (deposit.description != '[CLOSING]') {
        total += deposit.total;
        int expenseKey = deposit.expenseId??(deposit.description=='[OPENING]'?0:-1);
        if (expenses.containsKey(expenseKey)) {
          expenses[expenseKey] = deposit.copy(
              total: expenses[expenseKey]!.total + deposit.total);
        } else {
          expenses[expenseKey] = deposit;
        }
        if (investors.containsKey(deposit.uid)) {
          investors[deposit.uid] = deposit.copy(
              total: investors[deposit.uid]!.total + deposit.total);
        } else {
          investors[deposit.uid] = deposit;
        }
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          tabs: const <Widget>[
            Tab(text: "Expense"),
            Tab(text: "Investor"),
          ],
        ),
        Expanded(
            child: TabBarView(
          controller: _controller,
          children: [
            _ExpenseView(
                deposits:
                    expenses.entries.map<Deposit>((e) => e.value).toList()),
            _InvestorView(
                deposits:
                    investors.entries.map<Deposit>((e) => e.value).toList()),
          ],
        )),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Total : Rp. '),
                Text(_numberFormat.format(total))
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpenseView extends StatefulWidget {
  const _ExpenseView({Key? key, required this.deposits});

  final List<Deposit> deposits;

  @override
  State<_ExpenseView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<_ExpenseView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    NumberFormat numberFormat = NumberFormat("#,###");
    DateFormat dateFormat = DateFormat("d MMMM yyyy");
    return ListView.separated(itemBuilder: (context, index) => ListTile(
      isThreeLine: true,
      title: Text(dateFormat.format(widget.deposits[index].date.toLocal())),
      subtitle: Text(
          '${(widget.deposits[index].description??"")}\nRp. ${numberFormat.format(widget.deposits[index].total)}'),

    ),
        separatorBuilder: (context, index) =>
        const Divider(),
        itemCount: widget.deposits.length);
  }

  @override
  bool get wantKeepAlive => true;
}

class _InvestorView extends StatefulWidget {
  final List<Deposit> deposits;

  const _InvestorView({Key? key, required this.deposits}) : super(key: key);

  @override
  State<_InvestorView> createState() => _InvestorViewState();
}

class _InvestorViewState extends State<_InvestorView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    NumberFormat numberFormat = NumberFormat("#,###");
    return ListView.separated(itemBuilder: (context, index) => ListTile(
      title: Text(widget.deposits[index].user!.name),
      subtitle: Text(
          'Rp. ${numberFormat.format(widget.deposits[index].total)}'),

    ),
        separatorBuilder: (context, index) =>
        const Divider(),
        itemCount: widget.deposits.length);
  }

  @override
  bool get wantKeepAlive => true;
}
