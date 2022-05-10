import 'package:flutter/material.dart';

class UserPage extends StatelessWidget{
  const UserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(onRefresh: () {
          return Future<void>(() {
            return null;
          },);
        },
        child: ListView()),
        Align(

          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(onPressed: (){
              //todo
            },
              heroTag: 'UserPage',

              child: const Icon(Icons.add),),
          ),
        )
      ],
    );
  }

}