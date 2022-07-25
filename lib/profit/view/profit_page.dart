import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http_client/http_client.dart';
import 'package:iVoucher/home/home.dart';
import 'package:iVoucher/profit/profit.dart';
import 'package:iVoucher/widget/image_preview.dart';
import 'package:iVoucher/widget/month_picker.dart';
import 'package:intl/intl.dart';
import 'package:repository/repository.dart';

class ProfitPage extends StatelessWidget {
  const ProfitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfitBloc()..add(GetGroups()),
      child: _AssetView(),
    );
  }
}

class _AssetView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    String? groupName;

    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) => current is AppBarClicked,
      listener: (context, state) {
        if (state is AppBarClicked && state.idAction == actionProfitTransfer) {
          Navigator.of(context).push(ProfitTransferPage.route());
        }else if (state is AppBarClicked && state.idAction == actionProfitCapital) {
          Navigator.of(context).push(ProfitCapitalPage.route());
        }
      },
  child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<ProfitBloc, ProfitState>(
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
                        context.read<ProfitBloc>().add(
                            GetProfit(value, dateTime.year, dateTime.month));
                      }
                    },
                    validator: FormBuilderValidators.required(),
                  );
                } else if (state.group.isNotEmpty) {
                  groupName = state.group[0];
                  context.read<ProfitBloc>().add(
                      GetProfit(state.group[0], dateTime.year, dateTime.month));
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
                  .read<ProfitBloc>()
                  .add(GetProfit(groupName!, dateTime.year, dateTime.month));
            }
          }),
        ),
        Expanded(
            child: BlocBuilder<ProfitBloc, ProfitState>(
              buildWhen: (previous, current) =>
              current is GetProfitLoading ||
                  current is GetProfitSuccess ||
                  current is GetProfitFailed,
              builder: (context, state) {
                if (state is GetProfitLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is GetProfitFailed) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                  );
                } else if (state is GetProfitSuccess) {
                  return _TabView(state.profits);
                } else {
                  return Container();
                }
              },
            )),
      ],
    ),
);
  }
}

class _TabView extends StatefulWidget {
  const _TabView(this.profits);

  final List<Profit> profits;

  @override
  State<_TabView> createState() => _TabViewState();
}

class _TabViewState extends State<_TabView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  final NumberFormat _numberFormat = NumberFormat('#,###');
  int total = 0;
  final Map<User, List<Profit>> investors = {};
  final Map<User, int> investorTotal = {};

  @override
  void initState() {
    for (Profit profit in widget.profits) {
      if (profit.description != '[CLOSING]') {
        total += profit.total;
        if (investors.containsKey(profit.user)) {
          investors[profit.user]!.add(profit);
          investorTotal[profit.user!] = investorTotal[profit.user]! + profit.total;
        } else {
          investors[profit.user!] = [profit];
          investorTotal[profit.user!] = profit.total;
        }
      }
    }
    _controller = TabController(length: investors.length, vsync: this);
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
          tabs: investors.keys
              .map((e) => Tab(
            text: e.name,
          )).toList(),
        ),
        Expanded(
            child: TabBarView(
              controller: _controller,
              children: investors.entries
                  .map((e) => _InvestorView(
                profits: e.value,
                name: e.key.name,
                total: investorTotal[e.key] ?? 0,
              ))
                  .toList(),
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

class _InvestorView extends StatefulWidget {
  final List<Profit> profits;
  final String name;
  final int total;

  const _InvestorView(
      {Key? key, required this.profits, required this.name, required this.total})
      : super(key: key);

  @override
  State<_InvestorView> createState() => _InvestorViewState();
}

class _InvestorViewState extends State<_InvestorView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    NumberFormat numberFormat = NumberFormat("#,###");
    DateFormat dateFormat = DateFormat("d MMMM yyyy");
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
              itemBuilder: (context, index) => ListTile(
                onTap: widget.profits[index].total<0?(){
                  Navigator.of(context).push(ImagePreview.route(
                      network:
                      '${HttpClient.server}profit/${widget.profits[index].id}/receipt'));
                }:null,
                title: Text(
                    dateFormat.format(widget.profits[index].date.toLocal())),
                subtitle: Text(
                    '${(widget.profits[index].description != null ? ('${widget.profits[index].description!}\n') : "")}Rp. ${numberFormat.format(widget.profits[index].total)}'),
              ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: widget.profits.length),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${widget.name} Total : Rp. '),
                Text(numberFormat.format(widget.total))
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
