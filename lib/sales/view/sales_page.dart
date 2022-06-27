import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:voucher/sales/sales.dart';

import '../../home/home.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesBloc()..add(const GetGroups()),
      child: const _GetGroupView(),
    );
  }
}

class _GetGroupView extends StatelessWidget {
  const _GetGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesBloc, SalesState>(
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
          return _SalesView(state.group);
        } else {
          return Container();
        }
      },
    );
  }
}

class _SalesView extends StatefulWidget {
  final List<String> group;

  const _SalesView(this.group);

  @override
  State<_SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<_SalesView> {
  late String _groupName;
  int? _status;

  @override
  void initState() {
    _groupName = widget.group[0];
    //saleAdd means this user can input sales on inactive kiosk
    _status = context
                .read<LocalRepository>()
                .currentUser()
                ?.modules
                ?.contains('saleAdd') ==
            true
        ? null
        : 1;
    // if(widget.group.length==1){
    context.read<SalesBloc>().add(SalesRefresh(_groupName, _status));
    // }
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
                        .read<SalesBloc>()
                        .add(SalesRefresh(_groupName, _status));
                  });
                }),
          )
        ],
        Expanded(
          child: _SalesRefreshableView(
            groupName: _groupName,
            status: _status,
          ),
        ),
      ],
    );
  }
}

class _SalesRefreshableView extends StatelessWidget {
  const _SalesRefreshableView({Key? key, required this.groupName, this.status})
      : super(key: key);
  final String groupName;
  final int? status;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final itemsBloc = BlocProvider.of<SalesBloc>(context)
          ..add(SalesRefresh(groupName, status));

        return itemsBloc.stream.firstWhere((e) => e is! SalesRefresh);
      },
      child: BlocBuilder<SalesBloc, SalesState>(
        buildWhen: (previous, current) =>
            current is SalesLoaded ||
            current is SalesEmpty ||
            current is SalesLoading,
        builder: (context, state) {
          if (state is SalesLoaded) {
            final items = state.kiosks;
            // var languageCode2 = Localizations.localeOf(context).;
            // var formatter = DateFormat('dd MMMM yyyy hh:mm:ss',);

            return _SalesList(
              // key: ObjectKey(items),
              items: items,
              groupName: groupName,
              status: status,
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
  const _SalesList({
    Key? key,
    required this.items,
    required this.groupName,
    this.status,
  }) : super(key: key);

  final List<Kiosk> items;
  final String groupName;
  final int? status;

  @override
  State<_SalesList> createState() => _SalesListState();
}

class _SalesListState extends State<_SalesList> {
  late List<Kiosk> _sortedItems;
  bool _sortByDay = true;
  bool _allKiosk = true;

  @override
  void initState() {
    _sortedItems = widget.items.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is AppBarClicked) {
          if (state.idAction == actionSortByName) {
            _sortByDay = false;
          } else if (state.idAction == actionSortByDays) {
            _sortByDay = true;
          } else if (state.idAction == actionActiveKioskOnly) {
            _allKiosk = false;
          } else if (state.idAction == actionAllKiosk) {
            _allKiosk = true;
          }
          _sortedItems = widget.items.toList();
          if (!_allKiosk) {
            _sortedItems.removeWhere((element) => element.status == false);
          }
          if (_sortByDay) {
            _sortedItems.sort((a, b) {
              return (b.sales?.isNotEmpty == true
                      ? DateTime.now()
                          .difference(b.sales![0].date!.toLocal())
                          .inDays
                      : 0)
                  .compareTo(a.sales?.isNotEmpty == true
                      ? DateTime.now()
                          .difference(a.sales![0].date!.toLocal())
                          .inDays
                      : 0);
            });
          }
          // if (state.idAction == actionSortByName) {
          //   _sortedItems.sort((a, b) => a.kioskName.compareTo(b.kioskName));
          // } else if (state.idAction == actionSortByDays) {
          //   _sortedItems.sort((a, b) {
          //     return (b.sales?.isNotEmpty == true
          //         ? DateTime.now()
          //         .difference(b.sales![0].date!.toLocal())
          //         .inDays
          //         : 0)
          //         .compareTo(a.sales?.isNotEmpty == true
          //         ? DateTime.now()
          //         .difference(a.sales![0].date!.toLocal())
          //         .inDays
          //         : 0);
          //   });
          // } else if (state.idAction == actionActiveKioskOnly) {
          //   _sortedItems.removeWhere((element) => element.status==false);
          // }
          setState(() {});
        }
      },
      listenWhen: (_, current) => current is AppBarClicked,
      builder: (context, state) {
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = _sortedItems[index];
            final NumberFormat numberFormat = NumberFormat('#,###');
            final debt = item.sales?.isNotEmpty == true
                ? item.sales![0].total - item.sales![0].cash
                : 0;
            final days = item.sales?.isNotEmpty == true
                ? DateTime.now()
                    .difference(item.sales![0].date!.toLocal())
                    .inDays
                : 0;
            // Logger().d('timezone ' + DateTime.now().timeZoneName);
            return ListTile(
              onTap: () {
                Navigator.of(context).push<void>(
                  SalesKioskList.route(item),
                );
              },
              leading: CircleAvatar(
                backgroundColor: days >= 7 ? Colors.red : Colors.blue,
                child: Text(
                  item.id.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Row(
                children: [
                  Text(item.kioskName),
                  if (!item.status) ...[
                    const Card(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        'inactive',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    )),
                  ]
                ],
              ),
              subtitle: Text(
                  "${days > 0 ? "$days day(s), " : ""} Debt: ${numberFormat.format(debt)}"),
              // subtitle: Text(formatter.format(item.createdAt)),
              trailing: InkWell(
                onTap: () async {
                  Navigator.of(context)
                      .push<Sales?>(
                    SalesEdit.route(item, widget.groupName),
                  )
                      .then((value) {
                    if (value != null) {
                      context
                          .read<SalesBloc>()
                          .add(SalesRefresh(widget.groupName, widget.status));

                      Navigator.of(context).push<void>(
                        SalesKioskInvoice.route(kiosk: item, sales: value),
                      );
                    }
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: _sortedItems.length,
        );
      },
    );
  }
}
