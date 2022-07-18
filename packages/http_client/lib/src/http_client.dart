import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HttpClient{
  static const String server=
    kDebugMode?'http://10.0.2.2:5000/api/':'https://ivoucher.my.id/api/';
  // static const String server=
  //    kDebugMode?'http://192.168.0.155:5000/api/':'https://ivoucher.my.id/api/';
  // static const String server='https://ivoucher.my.id/api/';
  static const String serverDev=
     'https://ivoucher.my.id/devapi/';

  static bool debugServer=false;
  // static const String server='https://ivoucher.my.id/api/';

  static setDev(bool dev){
    debugServer=dev;
  }

  static String getDioErrorMessage(DioError error){
    if(error.response?.data is Map<String,dynamic>){
      if((error.response!.data as Map<String,dynamic>).containsKey('message')){
        return (error.response!.data as Map<String,dynamic>)['message'];
      }
    }
    return error.message;
  }


  static Dio getClient({String? token}){
  // static Dio getClient({String url='http://192.168.0.155:8080/api/',String? token}){

    Dio dio=Dio(BaseOptions(
        contentType: 'application/json', baseUrl: _getServer()));
    if(kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true,responseBody: true));
    }
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          var headers = {
            'platform': kIsWeb
                ? 'web'
                : Platform.isAndroid
                ? 'android'
                : 'ios'
          };
          if (token!=null) {
            headers['x-access-token'] = token;
          }
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          headers['version'] = packageInfo.buildNumber;
          options.headers.addAll(headers);
          if(kDebugMode) {
            print(headers);
          }
          return handler.next(options);
        },));
    return dio;
  }

  static _getServer() {
    if(debugServer) {
      return serverDev;
    }
    return server;
  }
}