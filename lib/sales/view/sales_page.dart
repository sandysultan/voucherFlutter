import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:voucher/sales/sales.dart';

class SalesPage extends StatefulWidget{
  const SalesPage({Key? key}) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  String? _groupName;
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    var groups = context.read<LocalRepository>().currentUser()?.groups;
    if((groups?.length??0)==1){
      _groupName=groups![0];
    }
    return Column(
      children: [
        ((groups?.length??0)>1)?
    Container():Container(),
        _groupName==null?Container():
        Expanded(
          child: FutureBuilder<String>(
              future: FirebaseAuth.instance.currentUser?.getIdToken(),
            builder: (context,snapshot) {
            if(snapshot.connectionState==ConnectionState.done) {
              return BlocProvider(create: (context) =>
              SalesBloc(snapshot.data!)
                ..add(SalesRefresh(_groupName!)),
                child: SalesView(groupName: _groupName!),
              );
            }else{
              return const Center(child: CircularProgressIndicator(),);
            }
            }
          ),
        ),
      ],
    );
  }
}

class SalesView extends StatelessWidget {
  const SalesView({Key? key,required this.groupName}) : super(key: key);
  final String groupName;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator( onRefresh: (){

      final itemsBloc = BlocProvider.of<SalesBloc>(context)..add(SalesRefresh(groupName));

      return itemsBloc.stream.firstWhere((e) => e is! SalesRefresh);
    },child: BlocBuilder<SalesBloc, SalesState>(
      buildWhen: (previous, current) => current is SalesLoaded,
      builder: (context, state) {
        if (state is SalesLoaded) {
          final items = state.kiosks;
          // var languageCode2 = Localizations.localeOf(context).;
          var formatter = DateFormat('dd MMMM yyyy hh:mm:ss',);
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];
              final days = item.sales?.isNotEmpty==true?DateTime.now().difference(item.sales![0].date.toLocal()).inDays:0;
              // Logger().d('timezone ' + DateTime.now().timeZoneName);
              return ListTile(
                onTap: (){
                  //todo
                },
                title: Text(
                  item.kioskName + ' (' + item.id.toString() + ')'
                ),
                subtitle: Text(days>0?days.toString() + " day(s)":""),
                // subtitle: Text(formatter.format(item.createdAt)),
                trailing: InkWell(onTap: () async {
                  var result = await Navigator.of(context).push<bool?>(
                    SalesEdit.route(item),
                  );
                  if(result!=null && result==true){
                    context.read<SalesBloc>().add(SalesRefresh(groupName));
                  }
                }, child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.add,color: Colors.blue,),
                ), ),

              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: items.length,
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    ),);
  }
}