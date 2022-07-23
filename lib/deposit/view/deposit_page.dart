import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iVoucher/deposit/deposit.dart';

class DepositPage extends StatelessWidget {
  const DepositPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DepositBloc()..add(GetGroups()),
      child: _DepositView(),
    );
  }

}

class _DepositView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      
    ],);
  }
}