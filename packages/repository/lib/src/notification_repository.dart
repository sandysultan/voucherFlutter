import 'package:dio/dio.dart';
import 'package:repository/src/model/kiosk_sales_response.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'notification_repository.g.dart';

@RestApi()
abstract class NotificationRepository{
  factory NotificationRepository(Dio dio,{String baseUrl}) = _NotificationRepository;

  @GET('/notification')
  Future<NotificationResponse?> getNotification();

}