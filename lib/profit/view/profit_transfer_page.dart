import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iVoucher/profit/profit.dart';
import 'package:iVoucher/constant/function.dart';
import 'package:intl/intl.dart';

class ProfitTransferPage extends StatelessWidget {
  const ProfitTransferPage({
    Key? key,
  }) : super(key: key);

  static Route<bool> route() {
    return MaterialPageRoute<bool>(
      settings: const RouteSettings(name: '/profit_transfer'),
      builder: (context) => const ProfitTransferPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profit Transfer"),
      ),
      body: BlocProvider(
        create: (context) =>
            ProfitBloc()..add(GetGroups()),
        child: const SingleChildScrollView(child: _ProfitTransferView()),
      ),
    );
  }
}

String? uid;
String? path;

class _ProfitTransferView extends StatelessWidget {
  const _ProfitTransferView({
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
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<ProfitBloc>()
                              ..add(GetInvestor(value))
                              ..add(GetLastClosing(groupName: value));
                          }
                        },
                        validator: FormBuilderValidators.required(),
                      );
                    } else if (state.group.isNotEmpty) {
                      context.read<ProfitBloc>()
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
              BlocBuilder<ProfitBloc, ProfitState>(
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
              BlocConsumer<ProfitBloc, ProfitState>(
                listenWhen: (previous, current) =>
                    current is PickReceiptStart ||
                    current is ProfitTransferLoading ||
                    current is ProfitTransferFailed ||
                    current is ProfitTransferSuccess,
                buildWhen: (previous, current) => current is PickReceiptDone,
                listener: (context, state) {
                  if (state is PickReceiptStart) {
                    showImageDialog(context, (croppedFile) {
                      context
                          .read<ProfitBloc>()
                          .add(ProfitTransferReceiptRetrieved(croppedFile));
                    });
                  } else if (state is ProfitTransferLoading) {
                    EasyLoading.show(status: "Transferring Profit");
                  } else if (state is ProfitTransferFailed) {
                    EasyLoading.showError(state.message);
                  }
                  if (state is ProfitTransferSuccess) {
                    EasyLoading.showSuccess("Profit Transferred");
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
                                  .read<ProfitBloc>()
                                  .add( PickProfitTransferReceipt()),
                              child: Image.file(File(path!))),
                          ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState?.saveAndValidate() ==
                                    true) {
                                  context.read<ProfitBloc>().add(ProfitTransfer(
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
                            .read<ProfitBloc>()
                            .add(PickProfitTransferReceipt());
                      },
                      child: const Text("Receipt"));
                },
              ),
            ],
          )),
    );
  }
}
