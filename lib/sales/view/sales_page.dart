import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:voucher/sales/sales.dart';

import '../../home/home.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  String? _groupName;
  final logger = Logger();
  List<String>? _groups;
  bool _allStatus=true;

  @override
  void initState() {
    _groups =
        context.read<LocalRepository>().currentUser()?.groups;
    logger.d(_groups);
    if((_groups?.length ?? 0) > 0){
      _groupName = _groups![0];
    }
    _allStatus = context.read<LocalRepository>().currentUser()?.modules?.contains('saleDate')==true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if((_groups?.length ?? 0) > 1) ...[
             Padding(
              padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
              child: FormBuilderDropdown<String>(name:'group',
                decoration: const InputDecoration(label: Text('Group')),
                isExpanded: true,
          initialValue: _groupName,
                  items: _groups!
                      .map((e) => DropdownMenuItem<String>(
                      value:e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState((){
                      _groupName = value;
                    });
                  }),
            )]
            ,
        if(_groupName != null) ...[
            Expanded(
                child: FutureBuilder<String>(
                    future: FirebaseAuth.instance.currentUser?.getIdToken(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return BlocProvider(
                          create: (context) => SalesBloc(snapshot.data!)
                            ..add(SalesRefresh(_groupName!,_allStatus?null:1)),
                          child: _SalesView(groupName: _groupName!,allStatus: _allStatus,),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              )],
      ],
    );
  }
}

class _SalesView extends StatelessWidget {
  const _SalesView({Key? key, required this.groupName, required this.allStatus}) : super(key: key);
  final String groupName;
  final bool allStatus;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final itemsBloc = BlocProvider.of<SalesBloc>(context)
          ..add(SalesRefresh(groupName,allStatus?null:1));

        return itemsBloc.stream.firstWhere((e) => e is! SalesRefresh);
      },
      child: BlocBuilder<SalesBloc, SalesState>(
        buildWhen: (previous, current) => current is SalesLoaded || current is SalesEmpty,
        builder: (context, state) {
          if (state is SalesLoaded) {
            final items = state.kiosks;
            // var languageCode2 = Localizations.localeOf(context).;
            // var formatter = DateFormat('dd MMMM yyyy hh:mm:ss',);
            return _SalesList(items: items, groupName: groupName,allStatus: allStatus,);
          }else if(state is SalesEmpty){
            return const Center(
                child: Text('Data Empty'));
          }else {
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
    required this.groupName, required this.allStatus,
  }) : super(key: key);

  final List<Kiosk> items;
  final String groupName;
  final bool allStatus;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (_, current) => current is AppBarClicked,
      builder: (context, state) {
        List<Kiosk> sortedItems = items;
        if (state is AppBarClicked) {
          if (state.idAction == actionSortByName) {
            sortedItems.sort((a, b) => a.kioskName.compareTo(b.kioskName));
          } else if (state.idAction == actionSortByDays) {
            sortedItems.sort((a, b) {
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
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = sortedItems[index];
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
                child: Text(
                  item.id.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: days >= 7 ? Colors.red : Colors.blue,
              ),
              title: Text(item.kioskName),
              subtitle: Text(days > 0
                  ? days.toString() + " day(s) from last billing"
                  : ""),
              // subtitle: Text(formatter.format(item.createdAt)),
              trailing: InkWell(
                onTap: () async {
                  var result = await Navigator.of(context).push<Sales?>(
                    SalesEdit.route(item),
                  );
                  if (result != null) {
                    context.read<SalesBloc>().add(SalesRefresh(groupName,allStatus?null:1));

                    Navigator.of(context).push<void>(
                      SalesKioskInvoice.route(kiosk: item,sales: result),
                    );
                  }
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
          itemCount: items.length,
        );
      },
    );
  }
}
