import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iVoucher/booster/booster.dart';
import 'package:iVoucher/constant/app_constant.dart';
import 'package:intl/intl.dart';
import 'package:repository/repository.dart';

class BoosterAdd extends StatelessWidget {
  const BoosterAdd({Key? key}) : super(key: key);

  static Route<bool> route() {
    return MaterialPageRoute<bool>(
      settings: const RouteSettings(name: '/booster_add'),
      builder: (context) => const BoosterAdd(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Booster"),
      ),
      body: BlocProvider(
        create: (context) =>
            BoosterBloc()..add(const GetGroups(ModuleConstant.boosterAdd)),
        child: SingleChildScrollView(child: _BoosterAddView()),
      ),
    );
  }
}

class _BoosterAddView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var formKey = GlobalKey<FormBuilderState>();
    return BlocListener<BoosterBloc, BoosterState>(
      listenWhen: (previous, current) =>
          current is AddBoostLoading ||
          current is AddBoostSuccess ||
          current is AddBoostFailed,
      listener: (context, state) {
        if(state is AddBoostLoading){
          EasyLoading.show(status: "Saving Booster");
        }else if(state is AddBoostFailed){
          EasyLoading.showError(state.message);
        }else if(state is AddBoostSuccess){
          EasyLoading.showSuccess("Booster Saved");
          Navigator.of(context).pop(true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: FormBuilder(
          key: formKey,
          child: Column(
            children: [
              BlocBuilder<BoosterBloc, BoosterState>(
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
                            context.read<BoosterBloc>().add(GetInvestor(value));
                          }
                        },
                        validator: FormBuilderValidators.required(),
                      );
                    } else if (state.group.isNotEmpty) {
                      context
                          .read<BoosterBloc>()
                          .add(GetInvestor(state.group[0]));
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
              BlocBuilder<BoosterBloc, BoosterState>(
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
                      return FormBuilderDropdown<User>(
                        name: 'investor',
                        decoration:
                            const InputDecoration(label: Text('Investor')),
                        isExpanded: true,
                        items: state.users
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text(e.name)))
                            .toList(),
                        validator: FormBuilderValidators.required(),
                      );
                    } else if (state.users.isNotEmpty) {
                      // uid = state.users[0].uid;
                      return FormBuilderTextField(
                        name: 'investor',
                        decoration:
                            const InputDecoration(label: Text('Investor')),
                        readOnly: true,
                        initialValue: state.users[0].name,
                        validator: FormBuilderValidators.required(),
                      );
                    } else {
                      return FormBuilderTextField(
                        name: 'investor',
                        decoration:
                            const InputDecoration(label: Text('Investor')),
                        readOnly: true,
                        validator: FormBuilderValidators.required(),
                      );
                    }
                  } else if (state is GetInvestorLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return FormBuilderTextField(
                      name: 'investor',
                      decoration:
                          const InputDecoration(label: Text('Investor')),
                      readOnly: true,
                      validator: FormBuilderValidators.required(),
                    );
                  }
                },
              ),
              FormBuilderSlider(
                name: 'boost',
                decoration: const InputDecoration(label: Text('Boost')),
                initialValue: 5,
                min: 5,
                max: 100,
                numberFormat: NumberFormat("#'%'"),
                label: 'Boost',
                divisions: 19,
                validator: FormBuilderValidators.required(),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.saveAndValidate() == true) {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                content: const Text(
                                    'Any active booster for this investor will be deactivated within this group and replaced with this new booster'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('OK')),
                                ],
                              )).then((value) {
                        if (value == true) {
                          context.read<BoosterBloc>().add(AddBoost(Booster(
                              groupName: formKey.currentState!.value['group'],
                              uid: formKey.currentState!.value['investor'].uid,
                              boost:
                                  formKey.currentState!.value['boost'] / 100)));
                        }
                      });
                    }
                  },
                  child: const Text('Boost'))
            ],
          ),
        ),
      ),
    );
  }
}
