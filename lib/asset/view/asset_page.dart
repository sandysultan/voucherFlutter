import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iVoucher/asset/asset.dart';
import 'package:iVoucher/widget/month_picker.dart';
import 'package:intl/intl.dart';
import 'package:repository/repository.dart';

class AssetPage extends StatelessWidget {
  const AssetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AssetBloc()..add(GetGroups()),
      child: _AssetView(),
    );
  }
}

class _AssetView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    String? groupName;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<AssetBloc, AssetState>(
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
                        context.read<AssetBloc>().add(
                            GetAsset(value, dateTime.year, dateTime.month));
                      }
                    },
                    validator: FormBuilderValidators.required(),
                  );
                } else if (state.group.isNotEmpty) {
                  groupName = state.group[0];
                  context.read<AssetBloc>().add(
                      GetAsset(state.group[0], dateTime.year, dateTime.month));
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
                  .read<AssetBloc>()
                  .add(GetAsset(groupName!, dateTime.year, dateTime.month));
            }
          }),
        ),
        Expanded(
            child: BlocBuilder<AssetBloc, AssetState>(
          buildWhen: (previous, current) =>
              current is GetAssetLoading ||
              current is GetAssetSuccess ||
              current is GetAssetFailed,
          builder: (context, state) {
            if (state is GetAssetLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GetAssetFailed) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              );
            } else if (state is GetAssetSuccess) {
              return _TabView(state.assets);
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
  const _TabView(this.assets);

  final List<Asset> assets;

  @override
  State<_TabView> createState() => _TabViewState();
}

class _TabViewState extends State<_TabView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  final NumberFormat _numberFormat = NumberFormat('#,###');
  int total = 0;
  final Map<User, List<Asset>> investors = {};
  final Map<User, int> investorTotal = {};

  @override
  void initState() {
    for (Asset asset in widget.assets) {
      if (asset.percentage != null) {
        total += asset.total;
        // if (expenses.containsKey(asset.expenseId)) {
        //   expenses[asset.expenseId] = asset.copy(
        //       total: expenses[asset.expenseId]!.total + asset.total);
        // } else {
        //   expenses[asset.expenseId] = asset;
        // }
        if (investors.containsKey(asset.user)) {
          investors[asset.user]!.add(asset);
          investorTotal[asset.user] = investorTotal[asset.user]! + asset.total;
        } else {
          investors[asset.user] = [asset];
          investorTotal[asset.user] = asset.total;
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
                  ))
              .toList(),
          // tabs: const <Widget>[
          //   Tab(text: "Expense"),
          //   Tab(text: "Investor"),
          // ],
        ),
        Expanded(
            child: TabBarView(
          controller: _controller,
          children: investors.entries
              .map((e) => _InvestorView(
                    assets: e.value,
                    name: e.key.name,
                    total: investorTotal[e.key] ?? 0,
                  ))
              .toList(),
          // children: [
          //   _ExpenseView(
          //       deposits:
          //       expenses.entries.map<Deposit>((e) => e.value).toList()),
          //   _InvestorView(
          //       deposits:
          //       investors.entries.map<Deposit>((e) => e.value).toList()),
          // ],
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

// class _ExpenseView extends StatefulWidget {
//   const _ExpenseView({Key? key, required this.deposits});
//
//   final List<Deposit> deposits;
//
//   @override
//   State<_ExpenseView> createState() => _ExpenseViewState();
// }
//
// class _ExpenseViewState extends State<_ExpenseView>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     NumberFormat numberFormat = NumberFormat("#,###");
//     return ListView.separated(itemBuilder: (context, index) => ListTile(
//       title: Text(widget.deposits[index].description??""),
//       subtitle: Text(
//           'Rp. ${numberFormat.format(widget.deposits[index].total)}'),
//
//     ),
//         separatorBuilder: (context, index) =>
//         const Divider(),
//         itemCount: widget.deposits.length);
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }
//
class _InvestorView extends StatefulWidget {
  final List<Asset> assets;
  final String name;
  final int total;

  const _InvestorView(
      {Key? key, required this.assets, required this.name, required this.total})
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
                    title: Text(
                        dateFormat.format(widget.assets[index].date.toLocal())),
                    subtitle: Text(
                        '${(widget.assets[index].expense != null ? widget.assets[index].expense!.description : "Asset Last Month")}\nRp. ${numberFormat.format(widget.assets[index].total)}'),
                  ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: widget.assets.length),
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
