import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:repository/repository.dart';
import 'package:iVoucher/fund_request/fund_request.dart';
import 'package:iVoucher/home/home.dart';

List<String> _groups=[];

class FundRequestPage extends StatelessWidget {
  const FundRequestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FundRequestBloc()..add(GetGroups()),
      child: _FundRequestGroupView(),
    );
  }
}

class _FundRequestGroupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FundRequestBloc, FundRequestState>(
      buildWhen: (previous, current) =>
          current is GetGroupLoading ||
          current is GetGroupSuccess ||
          current is GetGroupFailed,
      builder: (context, state) {
        if(state is GetGroupFailed){
          return Center(child: Text(state.message,style: const TextStyle(color: Colors.red),),);
        }else if(state is GetGroupSuccess){
          _groups=state.groups;
          return _FundRequestView();
        }else{
          return const Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }
}

class _FundRequestView extends StatefulWidget {
  const _FundRequestView( {
    Key? key,
  }) : super(key: key);

  @override
  State<_FundRequestView> createState() => _FundRequestViewState();
}

class _FundRequestViewState extends State<_FundRequestView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) => current is AppBarClicked,
      listener: (context, state) {
        if (state is AppBarClicked && state.idAction == actionAddFundRequest) {
          Navigator.of(context)
              .push<FundRequest?>(
            FundRequestAdd.route(),
          )
              .then((value) {
            if (value != null) {
              context.read<FundRequestBloc>().add(GetUnpaid());
              Navigator.of(context).push<void>(
                FundRequestDetailPage.route(value,_groups),
              );
            }
          });
        }
      },
      child: Column(
        children: [
          TabBar(
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.black,
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'Unpaid',
              ),
              Tab(
                text: 'Paid',
              ),
            ],
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: [
              _RefreshableUnpaidList(),
              _PaidView(),
            ],
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _PaidView extends StatefulWidget {
  @override
  State<_PaidView> createState() => _PaidViewState();
}

class _PaidViewState extends State<_PaidView> {
  DateTime _dateTime = DateTime.now();
  final DateFormat _monthFormatter = DateFormat('MMMM yyyy');

  @override
  void initState() {
    context
        .read<FundRequestBloc>()
        .add(GetPaid(year: _dateTime.year, month: _dateTime.month));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          IconButton(
              onPressed: () {
                setState(() {
                  _dateTime = DateTime(
                      _dateTime.month == 1
                          ? _dateTime.year - 1
                          : _dateTime.year,
                      _dateTime.month == 1 ? 12 : _dateTime.month - 1,
                      1);

                  context.read<FundRequestBloc>().add(
                      GetPaid(year: _dateTime.year, month: _dateTime.month));
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
              if (newDate != null && newDate != _dateTime) {
                setState(() {
                  _dateTime = newDate;

                  context.read<FundRequestBloc>().add(
                      GetPaid(year: _dateTime.year, month: _dateTime.month));
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
                    _dateTime.month == 12 ? _dateTime.year + 1 : _dateTime.year,
                    _dateTime.month == 12 ? 1 : _dateTime.month + 1,
                    1);

                if (newDate.isBefore(DateTime.now())) {
                  setState(() {
                    _dateTime = newDate;

                    context.read<FundRequestBloc>().add(
                        GetPaid(year: _dateTime.year, month: _dateTime.month));
                  });
                }
              },
              icon: const Icon(Icons.chevron_right)),
        ]),
        Container(
          color: Colors.grey,
          width: double.infinity,
          height: 1,
        ),
        // Expanded(child: Placeholder()),
        Expanded(
            child: _RefreshablePaidList(
                year: _dateTime.year, month: _dateTime.month))
      ],
    );
  }
}

class _RefreshablePaidList extends StatelessWidget {
  final int year;
  final int month;

  const _RefreshablePaidList(
      {Key? key, required this.year, required this.month})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () {
          final itemsBloc = BlocProvider.of<FundRequestBloc>(context)
            ..add(GetPaid(year: year, month: month));

          return itemsBloc.stream.firstWhere((e) => e is! GetPaid);
        },
        child: BlocBuilder<FundRequestBloc, FundRequestState>(
          buildWhen: (previous, current) =>
              current != previous &&
              (current is GetPaidLoading ||
                  current is GetPaidSuccess ||
                  current is GetPaidFailed),
          builder: (context, state) {
            if (state is GetPaidSuccess) {
              return _FundRequestList(
                items: state.fundRequests,
              );
            } else if (state is GetPaidFailed) {
              return Center(child: Text(state.message));
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class _RefreshableUnpaidList extends StatefulWidget {
  @override
  State<_RefreshableUnpaidList> createState() => _RefreshableUnpaidListState();
}

class _RefreshableUnpaidListState extends State<_RefreshableUnpaidList> {
  @override
  void initState() {
    context.read<FundRequestBloc>().add(GetUnpaid());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () {
          final itemsBloc = BlocProvider.of<FundRequestBloc>(context)
            ..add(GetUnpaid());

          return itemsBloc.stream.firstWhere((e) => e is! GetUnpaid);
        },
        child: BlocBuilder<FundRequestBloc, FundRequestState>(
          buildWhen: (previous, current) =>
              current != previous &&
              (current is GetUnpaidLoading ||
                  current is GetUnpaidSuccess ||
                  current is GetUnpaidFailed),
          builder: (context, state) {
            if (state is GetUnpaidSuccess) {
              return _FundRequestList(
                items: state.fundRequests,
              );
            } else if (state is GetUnpaidFailed) {
              return Center(child: Text(state.message));
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class _FundRequestList extends StatelessWidget {
  final List<FundRequest> items;

  const _FundRequestList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat('#,###');
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) => ListTile(
        onTap: () {
          Navigator.of(context).push<bool?>(
            FundRequestDetailPage.route(items[index],_groups),
          ).then((value) {
            if(value!=null){
              context.read<FundRequestBloc>().add(GetUnpaid());
            }
          });

        },
        title: Text(
            "Rp. ${numberFormat.format(items[index].total)} req. by ${items[index].requestedByUser?.name ?? ""}"),
        subtitle: Text(items[index].expenseType?.expenseTypeName ?? ""),
      ),
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemCount: items.length,
    );
  }
}
