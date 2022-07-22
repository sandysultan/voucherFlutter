import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http_client/http_client.dart';
import 'package:iVoucher/capital/capital.dart';
import 'package:iVoucher/capital/view/capital_add.dart';
import 'package:iVoucher/constant/app_constant.dart';
import 'package:iVoucher/home/home.dart';
import 'package:iVoucher/widget/image_preview.dart';
import 'package:iVoucher/widget/month_picker.dart';
import 'package:intl/intl.dart';

String? _groupName;
String? _uid;
DateTime _dateTime = DateTime.now();

class CapitalPage extends StatelessWidget {
  const CapitalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CapitalBloc()..add(const GetGroups(ModuleConstant.capital)),
      child: _HomeListener(),
    );
  }
}

class _HomeListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) => current is AppBarClicked,
      listener: (context, state) {
        if (state is AppBarClicked && state.idAction == actionAddCapital) {
          Navigator.of(context).push(CapitalAdd.route());
        }
      },
      child: const _GetGroupView(),
    );
  }
}

class _GetGroupView extends StatelessWidget {
  const _GetGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CapitalBloc, CapitalState>(
      buildWhen: (previous, current) =>
          current is GetGroupLoading ||
          current is GetGroupSuccess ||
          current is GetGroupFailed,
      builder: (context, state) {
        if (state is GetGroupFailed) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: Theme.of(context).errorColor),
            ),
          );
        } else if (state is GetGroupSuccess) {
          return _CapitalView(state.group);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class _CapitalView extends StatelessWidget {
  const _CapitalView(this.groups);

  final List<String> groups;

  @override
  Widget build(BuildContext context) {
    _groupName = groups[0];

    return Column(
      children: [
        Row(
          children: [
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: FormBuilderDropdown<String?>(
                  name: 'group',
                  decoration: const InputDecoration(label: Text('Group')),
                  isExpanded: true,
                  initialValue: null,
                  items: groups
                      .map((e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _groupName = value;
                      _uid = null;
                      context.read<CapitalBloc>().add(GetInvestor(value));
                    }
                  },
                  validator: FormBuilderValidators.required(),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: BlocBuilder<CapitalBloc, CapitalState>(
                buildWhen: (previous, current) =>
                    current is GetInvestorLoading ||
                    current is GetInvestorSuccess ||
                    current is GetInvestorFailed,
                builder: (context, state) {
                  if (state is GetInvestorSuccess) {
                    var dropdownItems = state.users
                        .map((e) => DropdownMenuItem<String>(
                            value: e.uid, child: Text(e.name)))
                        .toList();
                    dropdownItems.insert(
                        0,
                        const DropdownMenuItem<String>(
                            value: '', child: Text("-All-")));
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: FormBuilderDropdown<String>(
                          name: 'investor',
                          decoration:
                              const InputDecoration(label: Text('Investor')),
                          isExpanded: true,
                          initialValue: null,
                          items: dropdownItems,
                          onChanged: (value) {
                            // if (value != null) {
                            _uid = value;
                            context.read<CapitalBloc>().add(GetCapital(
                                groupName: _groupName!,
                                uid: value == '' ? null : value,
                                year: _dateTime.year,
                                month: _dateTime.month));
                            // }
                          }),
                    );
                  } else if (state is GetInvestorFailed) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
                    );
                  } else if (state is GetInvestorLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: MonthPicker(onChanged: (value) {
            _dateTime = value;
            if (_uid != null) {
              context.read<CapitalBloc>().add(GetCapital(
                  groupName: _groupName!,
                  uid: _uid == '' ? null : _uid,
                  year: _dateTime.year,
                  month: _dateTime.month));
            }
          }),
        ),
        Expanded(
            child: BlocBuilder<CapitalBloc, CapitalState>(
          buildWhen: (previous, current) =>
              current is GetInvestorLoading ||
              current is GetCapitalLoading ||
              current is GetCapitalSuccess ||
              current is GetCapitalFailed,
          builder: (context, state) {
            if (state is GetCapitalLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GetCapitalFailed) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              );
            } else if (state is GetCapitalSuccess) {
              DateFormat dateFormat = DateFormat("d MMMM yyyy");
              NumberFormat numberFormat = NumberFormat("#,###");
              return ListView.separated(
                  itemBuilder: (BuildContext context, int index) => ListTile(
                      onTap: () {
                        if (state.capitals[index].description ==
                            '[Investment]') {
                          Navigator.of(context).push(ImagePreview.route(
                              network:
                                  '${HttpClient.server}capital/${state.capitals[index].id}/receipt'));
                        }
                      },
                      isThreeLine: true,
                      trailing: _uid == ""
                          ? Text(state.capitals[index].user?.name ?? "")
                          : null,
                      title: Text(
                          "Rp. ${numberFormat.format(state.capitals[index].total)}"),
                      subtitle: Text(
                          "${dateFormat.format(state.capitals[index].date.toLocal())}\n${state.capitals[index].description ?? ""}")),
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: state.capitals.length);
            }
            return Container();
          },
        ))
      ],
    );
  }
}
