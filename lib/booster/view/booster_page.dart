import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:iVoucher/booster/booster.dart';
import 'package:iVoucher/constant/app_constant.dart';
import 'package:iVoucher/home/home.dart';
import 'package:local_repository/local_repository.dart';

class BoosterPage extends StatelessWidget {
  const BoosterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BoosterBloc()..add(const GetGroups(ModuleConstant.booster)),
      child: const _BoosterView(),
    );
  }
}

class _BoosterView extends StatelessWidget {
  const _BoosterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formKey = GlobalKey<FormBuilderState>();
    String? groupName;
    List<String>? modules =
        context.read<LocalRepository>().currentUser()?.modules;
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) => current is AppBarClicked,
      listener: (context, state) {
        if (state is AppBarClicked && state.idAction == actionAddBooster) {
          Navigator.of(context).push(BoosterAdd.route()).then((value) {
            if (value == true) {
              if(groupName!=null) {
                context.read<BoosterBloc>().add(GetBooster(groupName!));
              }
            }
          });

        }
      },
      child: FormBuilder(
        key: formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
              child: BlocBuilder<BoosterBloc, BoosterState>(
                buildWhen: (previous, current) =>
                    current is GetGroupLoading ||
                    current is GetGroupSuccess ||
                    current is GetGroupFailed,
                builder: (context, state) {
                  if (state is GetGroupLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is GetGroupFailed) {
                    return Center(
                      child: Text(state.message),
                    );
                  } else if (state is GetGroupSuccess) {
                    return FormBuilderDropdown<String>(
                      name: 'group',
                      decoration: const InputDecoration(label: Text('Group')),
                      items: state.group
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          groupName = value;
                          context.read<BoosterBloc>().add(GetBooster(value));
                        }
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Expanded(
                child: RefreshIndicator(
              onRefresh: () {
                if (groupName != null) {
                  final itemsBloc = BlocProvider.of<BoosterBloc>(context)
                    ..add(GetBooster(groupName ?? ""));
                  return itemsBloc.stream.firstWhere((e) => e is! GetBooster);
                } else {
                  return Future<void>.error(
                      ErrorDescription('group must selected'));
                }
              },
              child: BlocBuilder<BoosterBloc, BoosterState>(
                buildWhen: (previous, current) =>
                    current is GetBoosterLoading ||
                    current is GetBoosterFailed ||
                    current is GetBoosterSuccess,
                builder: (context, state) {
                  if (state is GetBoosterSuccess) {
                    if (state.boosters.isEmpty) {
                      return Center(
                        child: Text(
                          "No active booster",
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      );
                    } else {
                      return BlocListener<BoosterBloc, BoosterState>(
                        listenWhen: (previous, current) =>
                            current is DeactivateBoosterLoading ||
                            current is DeactivateBoosterSuccess ||
                            current is DeactivateBoosterFailed,
                        listener: (context, state) {
                          if (state is DeactivateBoosterLoading) {
                            EasyLoading.show(status: "Deactivating booster");
                          } else if (state is DeactivateBoosterFailed) {
                            EasyLoading.showError(state.message);
                          } else if (state is DeactivateBoosterSuccess) {
                            EasyLoading.showSuccess("Booster Deactivated");
                            context
                                .read<BoosterBloc>()
                                .add(GetBooster(groupName!));
                          }
                        },
                        child: ListView.separated(
                            itemBuilder: (context, index) => ListTile(
                                  title: Text(state.boosters[index].user!.name),
                                  subtitle: Text(
                                      'Boosted up to ${(state.boosters[index].boost * 100).toStringAsFixed(2)}%'),
                                  trailing: modules?.contains(
                                              ModuleConstant.boosterDelete) ==
                                          true
                                      ? IconButton(
                                          onPressed: () {
                                            showDialog<bool?>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                      content: Text(
                                                          'Deactivate ${state.boosters[index].user!.name} boost?'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'Cancel')),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true);
                                                            },
                                                            child: const Text(
                                                                'Yes')),
                                                      ],
                                                    )).then((value) {
                                              if (value == true) {
                                                context.read<BoosterBloc>().add(
                                                    DeactivateBooster(state
                                                        .boosters[index].id!));
                                              }
                                            });
                                          },
                                          icon: const Icon(Icons.delete))
                                      : null,
                                ),
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: state.boosters.length),
                      );
                    }
                  } else if (state is GetBoosterFailed) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
                    );
                  } else if (state is GetBoosterLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ))
          ],
        ),
      ),
    );
  }
}
