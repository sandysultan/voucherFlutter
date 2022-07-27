import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iVoucher/capital/capital.dart';
import 'package:iVoucher/constant/app_constant.dart';
import 'package:iVoucher/constant/function.dart';
import 'package:intl/intl.dart';

class CapitalAdd extends StatelessWidget {
  const CapitalAdd({
    Key? key,
  }) : super(key: key);

  static Route<bool> route() {
    return MaterialPageRoute<bool>(
      settings: const RouteSettings(name: '/capital_add'),
      builder: (context) => const CapitalAdd(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Capital"),
      ),
      body: BlocProvider(
        create: (context) =>
            CapitalBloc()..add(const GetGroups(ModuleConstant.capitalAdd)),
        child: const SingleChildScrollView(child: _CapitalAddView()),
      ),
    );
  }
}

String? uid;
String? path;

class _CapitalAddView extends StatelessWidget {
  const _CapitalAddView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formKey = GlobalKey<FormBuilderState>();
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: FormBuilder(
          key: formKey,
          child: Column(
            children: [
              BlocBuilder<CapitalBloc, CapitalState>(
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
                            context.read<CapitalBloc>()
                              ..add(GetInvestor(value))
                              ..add(GetLastClosing(groupName: value));
                          }
                        },
                        validator: FormBuilderValidators.required(),
                      );
                    } else if (state.group.isNotEmpty) {
                      context.read<CapitalBloc>()
                        ..add(GetInvestor(state.group[0]))
                        ..add(GetLastClosing(groupName: state.group[0]));
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
              BlocBuilder<CapitalBloc, CapitalState>(
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
              BlocBuilder<CapitalBloc, CapitalState>(
                buildWhen: (previous, current) =>
                    current is GetLastClosingLoading ||
                    current is GetLastClosingSuccess ||
                    current is GetLastClosingFailed,
                builder: (context, state) {
                  if (state is GetLastClosingSuccess) {
                    DateTime? minDate;
                    if (state.closing != null) {
                      minDate = DateTime(
                          state.closing!.year, state.closing!.month + 1, 1);
                    }
                    return FormBuilderDateTimePicker(
                      name: 'date',
                      format: DateFormat('dd MMMM yyyy'),
                      inputType: InputType.date,
                      initialValue: DateTime.now(),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        (value) {
                          if (minDate != null) {
                            if (value?.isBefore(minDate) == true) {
                              return "Minimum date is ${DateFormat('dd MMMM yyyy').format(minDate)}";
                            }
                          }
                          return null;
                        }
                      ]),
                      decoration: const InputDecoration(
                          label: Text('Date'), isDense: true),
                    );
                  } else if (state is GetLastClosingFailed) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
                    );
                  } else if (state is GetLastClosingLoading) {
                    return const Center(child: CircularProgressIndicator());
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
              BlocConsumer<CapitalBloc, CapitalState>(
                listenWhen: (previous, current) =>
                    current is PickReceiptStart ||
                    current is AddCapitalLoading ||
                    current is AddCapitalFailed ||
                    current is AddCapitalSuccess,
                buildWhen: (previous, current) => current is PickReceiptDone,
                listener: (context, state) {
                  if (state is PickReceiptStart) {
                    showImageDialog(context, (croppedFile) {
                      context
                          .read<CapitalBloc>()
                          .add(CapitalReceiptRetrieved(croppedFile));
                    });
                  } else if (state is AddCapitalLoading) {
                    EasyLoading.show(status: "Adding Capital");
                  } else if (state is AddCapitalFailed) {
                    EasyLoading.showError(state.message);
                  }
                  if (state is AddCapitalSuccess) {
                    EasyLoading.showSuccess("Capital Added");
                    Navigator.of(context).pop(true);
                  }
                },
                builder: (context, state) {
                  if (state is PickReceiptDone) {
                    if (path != state.croppedFile.path) {
                      path = state.croppedFile.path;
                      return Column(
                        children: [
                          InkWell(
                              onTap: () => context
                                  .read<CapitalBloc>()
                                  .add(PickCapitalReceipt()),
                              child: Image.file(File(path!))),
                          ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState?.saveAndValidate() ==
                                    true) {
                                  context.read<CapitalBloc>().add(AddCapital(
                                      uid: uid!,
                                      file: File(path!),
                                      total: int.parse(formKey
                                          .currentState!.value['total']!
                                          .toString()),
                                      groupName: formKey
                                          .currentState!.value['group']!
                                          .toString(),
                                      date: formKey
                                          .currentState!.value['date']!));
                                }
                              },
                              child: const Text("Save"))
                        ],
                      );
                    }
                  }
                  return ElevatedButton(
                      onPressed: () {
                        context
                            .read<CapitalBloc>()
                            .add(PickCapitalReceipt());
                      },
                      child: const Text("Receipt"));
                },
              ),
            ],
          )),
    );
  }
}
