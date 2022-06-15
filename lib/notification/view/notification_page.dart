import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:voucher/notification/notification.dart';
import 'package:repository/repository.dart' as repository;

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc()..add(NotificationRefresh()),
      child: const NotificationView(),
    );
  }

}

class NotificationView extends StatelessWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final itemsBloc = BlocProvider.of<NotificationBloc>(context)
          ..add(NotificationRefresh());

        return itemsBloc.stream.firstWhere((e) => e is! NotificationRefresh);
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        buildWhen: (previous, current) =>
        current != previous &&
            (current is NotificationLoaded ||
                current is NotificationEmpty ||
                current is NotificationLoading),
        builder: (context, state) {
          if (state is NotificationLoaded) {
            // final items = state.kiosks;
            // var languageCode2 = Localizations.localeOf(context).;
            // var formatter = DateFormat('dd MMMM yyyy hh:mm:ss',);
            return _NotificationList(
              items: state.notifications,
            );
          } else if (state is NotificationEmpty) {
            return Center(child: Text(state.message));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<repository.Notification> items;

  const _NotificationList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd MMMM yyyy hh:mm:ss');
    return ListView.separated(itemBuilder: (BuildContext context, int index) => ListTile(
      title: Text(items[index].message),
      subtitle: Text(dateFormat.format(items[index].createdAt.toLocal()))),

        separatorBuilder: (context, index) => const Divider(), itemCount: items.length);
  }
}
