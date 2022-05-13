import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HttpClient{
  static Dio getClient({String url=kDebugMode?'http://192.168.0.155:5000/api/':'http://192.168.0.155:8080/api/',String? token}){
  // static Dio getClient({String url='http://192.168.0.155:8080/api/',String? token}){

    Dio dio=Dio(BaseOptions(
        contentType: 'application/json', baseUrl: url));
    if(kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true,responseBody: true));
    }
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
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
          options.headers.addAll(headers);
          return handler.next(options);
        },));
    return dio;
  }
}