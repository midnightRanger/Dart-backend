import 'dart:io';

import 'package:conduit/conduit.dart';

import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppUserController extends ResourceController {
  AppUserController(this.managedContext);
  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header 
 ) async {
  try {
  //Получение ID пользователя 
  final id = AppUtils.getIdFromHeader(header); 
  //Получение данных пользователя по его ID 
  final user = await managedContext.fetchObjectWithID<User>(id);
  //Удаление ненужных параметров 
  user!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

  return AppResponse.ok(
    message: 'Успешное получение профиля: ', body: user.backing.contents);
 } 
 catch (e) {
    return AppResponse.serverError(e, message: 'Ошибка получения профиля')
 }


 }



}