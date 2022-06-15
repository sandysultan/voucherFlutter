import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:repository/repository.dart';
import 'package:voucher/expense/expense.dart';

class ExpenseEditPage extends StatelessWidget {
  const ExpenseEditPage(
      {Key? key,
      required this.groupName,
      required this.date,
      required this.groups})
      : super(key: key);
  final String groupName;
  final List<String> groups;
  final DateTime date;

  static Route<bool?> route(
      {required String groupName,
      required DateTime date,
      required List<String> groups}) {
    return MaterialPageRoute<bool?>(
        builder: (_) => ExpenseEditPage(
              groups: groups,
              groupName: groupName,
              date: date,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseBloc()..add(const GetExpenseType()),
      child: _ExpenseEditView(
        groupName: groupName,
        date: date,
        groups: groups,
      ),
    );
  }
}

class _ExpenseEditView extends StatelessWidget {
  const _ExpenseEditView(
      {Key? key,
      required this.groupName,
      required this.date,
      required this.groups})
      : super(key: key);
  final String groupName;
  final DateTime date;
  final List<String> groups;

  @override
  Widget build(BuildContext context) {
    var formKey = GlobalKey<FormBuilderState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense"),
      ),
      body: FormBuilder(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (groups.length > 1) ...[
                  FormBuilderDropdown(
                      name: 'groupName',
                      initialValue: groupName,
                      validator: FormBuilderValidators.required(),
                      decoration: const InputDecoration(
                          label: Text('Group'), isDense: true),
                      items: groups
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList()),
                ],
                FormBuilderDateTimePicker(
                  name: 'date',
                  format: DateFormat('dd MMMM yyyy'),
                  inputType: InputType.date,
                  initialValue: date,
                  validator: FormBuilderValidators.required(),
                  decoration:
                      const InputDecoration(label: Text('Date'), isDense: true),
                ),
                BlocBuilder<ExpenseBloc, ExpenseState>(
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
                        decoration:
                        const InputDecoration(label: Text('Expense'),),
                        validator: FormBuilderValidators.required(),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                FormBuilderTextField(
                  name: 'description',
                  decoration: const InputDecoration(label: Text('Description')),
                ),
                FormBuilderTextField(
                  name: 'total',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(label: Text('Total')),
                  validator: FormBuilderValidators.required(),
                ),
                BlocListener<ExpenseBloc, ExpenseState>(
                  listenWhen: (previous, current) =>
                      current is AddExpenseLoading ||
                      current is AddExpenseSuccess ||
                      current is AddExpenseError,
                  listener: (context, state) {
                    if (state is AddExpenseLoading) {
                      EasyLoading.show(status: 'Saving expense');
                    } else if (state is AddExpenseError) {
                      EasyLoading.showError(state.message);
                    } else if (state is AddExpenseSuccess) {
                      EasyLoading.showSuccess("Saving success");
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.saveAndValidate() == true) {
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: const Text("Image Source"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: const Text('Camera'),
                                          leading: const Icon(Icons.camera),
                                          onTap: () {
                                            final ImagePicker picker =
                                                ImagePicker();
                                            picker
                                                .pickImage(
                                                    source: ImageSource.camera)
                                                .then((photo) {
                                              if (photo != null) {
                                                cropImage(
                                                        context, formKey, photo)
                                                    .then((value) =>
                                                        Navigator.of(context)
                                                            .pop());
                                              } else {
                                                Navigator.of(context).pop();
                                              }
                                            });
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Gallery'),
                                          leading:
                                              const Icon(Icons.image_search),
                                          onTap: () {
                                            final ImagePicker picker =
                                                ImagePicker();
                                            picker
                                                .pickImage(
                                                    source: ImageSource.gallery)
                                                .then((image) {
                                              if (image != null) {
                                                cropImage(
                                                        context, formKey, image)
                                                    .then((value) =>
                                                        Navigator.of(context)
                                                            .pop());
                                              } else {
                                                Navigator.of(context).pop();
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ));
                        }
                      },
                      child: const Text('Continue')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> cropImage(BuildContext context,
      GlobalKey<FormBuilderState> formKey, XFile image) async {
    ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    ).then((croppedFile) {
      if (croppedFile != null) {
        context.read<ExpenseBloc>().add(AddExpense(
            Expense(
                date: formKey.currentState?.value['date'],
                groupName: groups.length > 1
                    ? formKey.currentState?.value['groupName']
                    : groupName,
                expenseTypeId: (formKey.currentState?.value['expenseType'] as ExpenseType).id,
                total: int.parse(formKey.currentState?.value['total']),
                description: formKey.currentState?.value['description'],
                closed: false),
            File(croppedFile.path)));
      } else {
        EasyLoading.showError('Receipt is mandatory');
      }
    });
  }
}
