import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iVoucher/profit/profit.dart';

class ProfitCapitalPage extends StatelessWidget {
  const ProfitCapitalPage({Key? key}) : super(key: key);

  static Route<bool> route() {
    return MaterialPageRoute<bool>(
      settings: const RouteSettings(name: '/profit_capital'),
      builder: (context) => const ProfitCapitalPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit to Capital'),
      ),
      body: BlocProvider(
        create: (context) => ProfitBloc()..add(GetGroups()),
        child: _ProfitCapitalView(),
      ),
    );
  }
}

class _ProfitCapitalView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? groupName;
    DateTime? dateTime=DateTime.now();
    return FormBuilder(child: Column(
      children: [
        BlocBuilder<ProfitBloc, ProfitState>(
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
                          GetInvestor(value,));
                    }
                  },
                  validator: FormBuilderValidators.required(),
                );
              } else if (state.group.isNotEmpty) {
                groupName = state.group[0];
                context.read<ProfitBloc>().add(
                    GetInvestor(state.group[0],));
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
        BlocBuilder<ProfitBloc, ProfitState>(
          buildWhen: (previous, current) =>
          current is GetInvestorLoading ||
              current is GetInvestorSuccess ||
              current is GetInvestorFailed,
          builder: (context, state) {
            if (state is GetInvestorFailed) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is GetInvestorSuccess) {
              if (state.users.length > 1) {
                return FormBuilderDropdown<String>(
                  name: 'uid',
                  decoration:
                  const InputDecoration(label: Text('Investor')),
                  isExpanded: true,
                  items: state.users
                      .map((e) => DropdownMenuItem(
                      value: e.uid, child: Text(e.name)))
                      .toList(),
                  onChanged: (value) {
                    uid = value;
                  },
                  validator: FormBuilderValidators.required(),
                );
              } else if (state.users.isNotEmpty) {
                uid = state.users[0].uid;
                return FormBuilderTextField(
                  name: 'uid',
                  decoration:
                  const InputDecoration(label: Text('Investor')),
                  readOnly: true,
                  initialValue: state.users[0].name,
                );
              } else {
                return Container();
              }
            } else if (state is GetInvestorLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container();
            }
          },
        ),

        FormBuilderTextField(
          name: 'total',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(label: Text('Total')),
          validator: FormBuilderValidators.required(),
        ),
        
        ElevatedButton(onPressed: (){
          //todo
        }, child: const Text('Convert'))
      ],
    ));
  }
}

