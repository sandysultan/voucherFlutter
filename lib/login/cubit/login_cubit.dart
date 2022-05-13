import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  final logger=Logger();

  Future<void> login(String email, String password ) async {
    emit(const LoginLoading('Logging in'));
    try {
      var credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if(credential.user!=null) {
        credential.user?.getIdToken().then((value){

          emit(LoginSuccess(token: value,email: email));}
        ).catchError((error) {
          emit(const LoginFailed('Login Failed'));
        });
      }else{
        emit(const LoginFailed('Login Failed'));
      }
    } on Exception catch (e,stack) {
      logger.e(e);
      FirebaseCrashlytics.instance.recordError(e, stack);
      emit(LoginFailed(e.toString()));
    }
  }
  //
  // @override
  // LoginState? fromJson(Map<String, dynamic> json) {
  //   var logger=Logger();
  //     logger.d(json);
  //   return LoginSuccess(json['token']);
  // }
  //
  // @override
  // Map<String, dynamic>? toJson(LoginState state) {
  //   var logger=Logger();
  //   if(state is LoginSuccess){
  //     logger.d('token:'+state.token);
  //     return {'token':state.token};
  //   }
  //   return null;
  // }

  // Future<void> updateToken(String value) async {
  //   var logger=Logger();
  //   logger.d('token:' + value);
  //   emit(LoginSuccess(value));
  // }


}
