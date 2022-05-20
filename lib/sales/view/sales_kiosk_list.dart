import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

import '../sales.dart';

final logger = Logger();

class SalesKioskList extends StatefulWidget {
  const SalesKioskList(this.item, {Key? key}) : super(key: key);
  final Kiosk item;

  static Route<void> route(Kiosk item) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/sales_kiosk_list'),
      builder: (context) => SalesKioskList(item),
    );
  }

  @override
  State<SalesKioskList> createState() => _SalesKioskListState();
}

class _SalesKioskListState extends State<SalesKioskList> {
  late DateTime _dateTime;
  final DateFormat _monthFormatter = DateFormat('MMMM yyyy');
  final DateFormat _yearFormatter = DateFormat('yyyy');

  bool _isYear = false;

  @override
  void initState() {
    _dateTime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.kioskName),
        actions: [
          PopupMenuButton<bool>(
            onSelected: (value) {
              setState(() {
                _isYear = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: false, child: Text('Month')),
              const PopupMenuItem(value: true, child: Text('Year'))
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.calendar_today_outlined),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Row(children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    if (_isYear) {
                      _dateTime = DateTime(_dateTime.year - 1, 1, 1);
                    } else {
                      _dateTime = DateTime(
                          _dateTime.month == 1
                              ? _dateTime.year - 1
                              : _dateTime.year,
                          _dateTime.month == 1 ? 12 : _dateTime.month - 1,
                          1);
                    }
                  });
                },
                icon: const Icon(Icons.chevron_left)),
            Expanded(
                child: Text(
              _isYear
                  ? _yearFormatter.format(_dateTime)
                  : _monthFormatter.format(_dateTime),
              textAlign: TextAlign.center,
            )),
            IconButton(
                onPressed: () {
                  DateTime newDate;
                  if (_isYear) {
                    newDate = DateTime(_dateTime.year + 1, 1, 1);
                  } else {
                    newDate = DateTime(
                        _dateTime.month == 12
                            ? _dateTime.year + 1
                            : _dateTime.year,
                        _dateTime.month == 12 ? 1 : _dateTime.month + 1,
                        1);
                  }
                  if (newDate.isBefore(DateTime.now())) {
                    setState(() {
                      _dateTime = newDate;
                    });
                  }
                },
                icon: const Icon(Icons.chevron_right)),
          ]),
          Expanded(
              child: FutureBuilder<String>(
                  future: FirebaseAuth.instance.currentUser?.getIdToken(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return BlocProvider(
                        create: (context) {
                          var token = snapshot.data;
                          Logger().d('token '+ token.toString());
                          return SalesBloc(token!)..add(SalesListRefresh(kioskId: widget.item.id, year: _dateTime.year,month: _isYear?null:_dateTime.month));
                        },
                        child: _ListSales(
                          kiosk: widget.item,
                            month: _dateTime.month,
                            year: _dateTime.year,
                            isYear: _isYear,),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }))
        ],
      ),
    );
  }
}

class _ListSales extends StatelessWidget {
  const _ListSales(
      {required this.kiosk, required this.month, required this.year, required this.isYear, });
  final Kiosk kiosk;
  final int month;
  final int year;
  final bool isYear;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final itemsBloc = BlocProvider.of<SalesBloc>(context)
          ..add(SalesListRefresh(kioskId:kiosk.id,year: year, month: isYear ? null : month));

        return itemsBloc.stream.firstWhere((e) => e is! SalesListRefresh);
      },
      child: BlocBuilder<SalesBloc, SalesState>(
        buildWhen: (previous, current) => current is SalesListLoaded,
        builder: (context, state) {
          if (state is SalesListLoaded) {
            final items = state.sales;
            DateFormat formatter = DateFormat('dd MMMM yyyy');
            NumberFormat numberFormat = NumberFormat('#,###');
            return ListView.separated(
              itemBuilder: (BuildContext context, int index) => ListTile(
                onTap: (){

                  Navigator.of(context).push<void>(
                    SalesKioskInvoice.route(kiosk: kiosk, sales: items[index]),
                  );
                },
                title: Text(formatter.format(items[index].date!.toLocal())),
                subtitle: Text(numberFormat.format(items[index].cash)),
              ),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
