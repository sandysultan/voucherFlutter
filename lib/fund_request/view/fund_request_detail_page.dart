import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:voucher/constant/app_constant.dart';
import 'package:voucher/expense/expense.dart';
import 'package:voucher/fund_request/fund_request.dart';

class FundRequestDetailPage extends StatelessWidget {
  const FundRequestDetailPage(
      {Key? key, required this.fundRequest, required this.groups})
      : super(key: key);
  final FundRequest fundRequest;
  final List<String> groups;

  static Route<bool?> route(FundRequest fundRequest, List<String> groups) {
    return MaterialPageRoute<bool?>(
      settings: const RouteSettings(name: '/fund_request_detail'),
      builder: (context) =>
          FundRequestDetailPage(fundRequest: fundRequest, groups: groups),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd MMMM yyyy hh:mm:ss');
    NumberFormat numberFormat = NumberFormat('#,###');
    List<String> paids = [];
    return WillPopScope(
      onWillPop: () async {
        if (paids.isNotEmpty) {
          Navigator.pop(context, false);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Fund Request"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'date',
                  initialValue: dateFormat.format(fundRequest.createdAt!),
                  readOnly: true,
                  decoration: const InputDecoration(label: Text('Date & Time')),
                ),
                FormBuilderTextField(
                  name: 'requestedBy',
                  initialValue: fundRequest.requestedByUser!.name,
                  readOnly: true,
                  decoration:
                      const InputDecoration(label: Text('Requested By')),
                ),
                FormBuilderTextField(
                  name: 'expenseType',
                  initialValue: fundRequest.expenseType!.expenseTypeName,
                  readOnly: true,
                  decoration: const InputDecoration(label: Text('Expense')),
                ),
                FormBuilderTextField(
                  name: 'total',
                  initialValue: "Rp. ${numberFormat.format(fundRequest.total)}",
                  readOnly: true,
                  decoration: const InputDecoration(label: Text('Total')),
                ),
                BlocProvider(
                  create: (context) => FundRequestBloc()..add(GetModulesPay()),
                  child: _ListView(
                    fundRequest: fundRequest,
                    onPaid: (value) => paids = value,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListView extends StatefulWidget {
  final FundRequest fundRequest;
  final ValueChanged<List<String>> onPaid;

  const _ListView({Key? key, required this.fundRequest, required this.onPaid})
      : super(key: key);

  @override
  State<_ListView> createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  final List<String> _paids = [];
  late List<FundRequestDetail> _detail;

  @override
  void initState() {
    _detail = widget.fundRequest.fundRequestDetails;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat('#,###');
    return BlocBuilder<FundRequestBloc, FundRequestState>(
      buildWhen: (previous, current) =>
          current is GetModulePayLoading ||
          current is GetModulePayError ||
          current is GetModulePaySuccess,
      builder: (context, state) {
        if (state is GetModulePaySuccess) {
          return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => ListTile(
                  key: ObjectKey(_paids),
                  title: Text(_detail[index].groupName),
                  subtitle: Text(
                      '${(_detail[index].percentage! * 100).toStringAsFixed(2)}% x ${numberFormat.format(widget.fundRequest.total)} = Rp. ${numberFormat.format((_detail[index].percentage! * widget.fundRequest.total).ceil())}'),
                  trailing: (_detail[index].expenseId == null
                      ? (state.groups.contains(_detail[index].groupName) == true
                          ? ElevatedButton(
                              onPressed: () async {
                                await Navigator.of(context)
                                    .push<Expense?>(
                                  ExpenseEditPage.route(
                                      groups: [
                                        widget.fundRequest
                                            .fundRequestDetails[index].groupName
                                      ],
                                      groupName: widget.fundRequest
                                          .fundRequestDetails[index].groupName,
                                      fundRequest: widget.fundRequest,
                                      fundRequestDetail: widget.fundRequest
                                          .fundRequestDetails[index],
                                      date: DateTime.now()),
                                )
                                    .then((result) {
                                  if (result != null) {
                                    Logger().d('SetState triggered');
                                    setState(() {
                                      _detail[index] = _detail[index].copy(
                                          expenseId: result.id,
                                          expense: result);
                                      _paids.add(_detail[index].groupName);
                                    });
                                  }
                                });
                              },
                              child: const Text('Pay'),
                            )
                          : null)
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push<Expense?>(
                              ExpenseEditPage.route(
                                  groups: [_detail[index].groupName],
                                  groupName: _detail[index].groupName,
                                  fundRequest: widget.fundRequest,
                                  fundRequestDetail: _detail[index],
                                  expense: _detail[index].expense,
                                  date: DateTime.now()),
                            );
                          },
                          child: const Text('Paid')))),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: widget.fundRequest.fundRequestDetails.length);
        } else if (state is GetModulePayError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
