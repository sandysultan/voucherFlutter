import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../user.dart';

class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc()..add(const GetUsers()),
      child: const _UserView(),
    );
  }
}

class _UserView extends StatelessWidget {
  const _UserView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (previous, current) =>
          current is GetUserLoading ||
          current is GetUserSuccess ||
          current is GetUserFailed,
      builder: (context, state) {
        if (state is GetUserSuccess) {
          return RefreshIndicator(
              onRefresh: () {
                final itemsBloc = BlocProvider.of<UserBloc>(context)
                  ..add(const GetUsers());

                return itemsBloc.stream.firstWhere((e) => e is! GetUsers);
              },
              child: ListView.separated(
                  itemBuilder: (context, index) => InkWell(

                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            content: SizedBox(
                              width: 300,
                              height: 600,

                              child: ListView.separated(
                                  itemBuilder: (context, index2) => ListTile(
                                    title: Text(state.users[index].userRoles![index2].roleName),
                                    subtitle: Text(state.users[index].userRoles![index2].groups.map((e) => e.groupName).toList().join(', ')),
                                  ),
                                  separatorBuilder: (_, index2) => const Divider(),
                                  itemCount: state.users[index].userRoles?.length??0),
                            ),
                          ));
                    },
                    child: ListTile(
                          title: Text(state.users[index].name),
                          subtitle: Text(state.users[index].email),
                        ),
                  ),
                  separatorBuilder: (_, index) => const Divider(),
                  itemCount: state.users.length));
        } else if (state is GetUserFailed) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: Theme.of(context).errorColor),
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
