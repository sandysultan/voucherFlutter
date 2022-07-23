import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iVoucher/deposit/deposit.dart';
import 'package:iVoucher/widget/month_picker.dart';

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
    return Column(children: [
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
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<DepositBloc>().add(GetDeposit(value, dateTime.year, dateTime.month));
                    }
                  },
                  validator: FormBuilderValidators.required(),
                );
              } else if (state.group.isNotEmpty) {
                context
                    .read<DepositBloc>()
                    .add(GetDeposit(state.group[0], dateTime.year, dateTime.month));
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
      MonthPicker(onChanged: (value){
        dateTime = value;
      }),
    ],);
  }
}