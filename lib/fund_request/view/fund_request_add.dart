import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:local_repository/local_repository.dart';
import 'package:repository/repository.dart';
import 'package:voucher/constant/app_constant.dart';
import 'package:voucher/constant/function.dart';
import 'package:voucher/fund_request/bloc/fund_request_bloc.dart';

class FundRequestAdd extends StatelessWidget {
  const FundRequestAdd({Key? key}) : super(key: key);

  static Route<FundRequest?> route() {
    return MaterialPageRoute<FundRequest?>(
      settings: const RouteSettings(name: '/fund_request_add'),
      builder: (context) => const FundRequestAdd(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String>? modules =
        context.read<LocalRepository>().currentUser()?.modules;
    return BlocProvider(
      create: (context) {
        var fundRequestBloc = FundRequestBloc()
          ..add(GetGroups())
          ..add(GetExpenseType());
        if (modules?.contains(ModuleConstant.fundRequestUser) == true) {
          fundRequestBloc.add(GetFinanceUsers());
        }
        return fundRequestBloc;
      },
      child: _FundRequestAddView(modules),
    );
  }
}

class _FundRequestAddView extends StatefulWidget {
  final List<String>? modules;

  const _FundRequestAddView(
    this.modules, {
    Key? key,
  }) : super(key: key);

  @override
  State<_FundRequestAddView> createState() => _FundRequestAddViewState();
}

class _FundRequestAddViewState extends State<_FundRequestAddView> {
  String? _imagePath;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Request'),
      ),
      body: SingleChildScrollView(
          child: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'total',
                validator: FormBuilderValidators.required(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total'),
              ),
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              if (widget.modules?.contains(ModuleConstant.fundRequestUser) ==
                  true) ...[
                BlocBuilder<FundRequestBloc, FundRequestState>(
                  buildWhen: (previous, current) =>
                      current is GetFinanceUserLoading ||
                      current is GetFinanceUserSuccess ||
                      current is GetFinanceUserFailed,
                  builder: (context, state) {
                    if (state is GetFinanceUserSuccess) {
                      return FormBuilderDropdown<User>(
                        name: 'requestedBy',
                        items: state.users
                            .map((e) => DropdownMenuItem<User>(
                                value: e, child: Text(e.name)))
                            .toList(),
                        decoration: const InputDecoration(
                          label: Text('Requested By'),
                        ),
                        validator: FormBuilderValidators.required(),
                      );
                    } else if (state is GetFinanceUserFailed) {
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
                ),
              ],
              BlocBuilder<FundRequestBloc, FundRequestState>(
                buildWhen: (previous, current) =>
                    current is GetExpenseTypeLoading ||
                    current is GetExpenseTypeSuccess ||
                    current is GetExpenseTypeError,
                builder: (context, state) {
                  if (state is GetExpenseTypeSuccess) {
                    return FormBuilderDropdown<ExpenseType>(
                      name: 'expenseType',
                      items: state.expenseTypes
                          .map((e) => DropdownMenuItem(
                              value: e, child: Text(e.expenseTypeName)))
                          .toList(),
                      decoration: const InputDecoration(
                        label: Text('Expense'),
                      ),
                      validator: FormBuilderValidators.required(),
                    );
                  } else if (state is GetExpenseTypeError) {
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
              ),
              BlocBuilder<FundRequestBloc, FundRequestState>(
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
                    return FormBuilderCheckboxGroup<String>(
                      name: 'groups',
                      validator: FormBuilderValidators.required(),
                      decoration: const InputDecoration(labelText: 'Groups'),
                      options: state.groups
                          .map((e) => FormBuilderFieldOption(value: e))
                          .toList(),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              if (_imagePath != null) ...[
                InkWell(
                  onTap: () {
                    showImageDialog(context, (croppedFile) {
                      setState(() {
                        _imagePath = croppedFile.path;
                      });
                    });
                  },
                  child: Image.file(
                    File(_imagePath!),
                    height: 200,
                    width: 200,
                  ),
                )
              ],
              BlocListener<FundRequestBloc, FundRequestState>(
                listenWhen: (previous, current) =>
                    current is AddFundRequestLoading ||
                    current is AddFundRequestSuccess ||
                    current is AddFundRequestFailed,
                listener: (context, state) {
                  if (state is AddFundRequestLoading) {
                    EasyLoading.show(status: 'Saving Fund Request');
                  } else if (state is AddFundRequestFailed) {
                    EasyLoading.showError(state.message);
                  } else if (state is AddFundRequestSuccess) {
                    EasyLoading.showSuccess('Saving Fund Success');
                    Navigator.of(context).pop(state.fundRequest);
                  }
                },
                child: ElevatedButton(
                    onPressed: () {
                      if (_imagePath == null) {
                        showImageDialog(context, (croppedFile) {
                          setState(() {
                            _imagePath = croppedFile.path;
                          });
                        });
                      } else {
                        if (_formKey.currentState?.saveAndValidate() == true) {
                          context.read<FundRequestBloc>().add(AddFundRequest(
                              total: int.parse(
                                  _formKey.currentState?.value['total']),
                              description:
                                  _formKey.currentState?.value['description'],
                              requestedBy: (_formKey.currentState
                                      ?.value['requestedBy'] as User?)
                                  ?.uid,
                              expenseType: _formKey.currentState
                                  ?.value['expenseType'] as ExpenseType,
                              imagePath: _imagePath!,
                              groups: _formKey.currentState?.value['groups']));
                        }
                      }
                    },
                    child: Text(_imagePath == null ? 'Continue' : 'Save')),
              )
            ],
          ),
        ),
      )),
    );
  }
}
