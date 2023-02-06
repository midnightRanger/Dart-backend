import 'dart:io';

import 'package:conduit/conduit.dart';

import '../model/user.dart';
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

 @Operation.post()
 Future<Response> updateProfile(
  @Bind.header(HttpHeaders.authorizationHeader) String header,
  @Bind.body() User user
   ) async {

    try {
      //Получение Id пользователя 
      final id = AppUtils.getIdFromHeader(header);
      final fUser = await managedContext.fetchObjectWithID<User>(id);

      final qUpdateUser = Query<User> (managedContext)
        ..where((x) => x.id)
          .equalTo(id) // поиск пользователя по id 
        ..values.userName = user.userName ?? fUser!.userName
        ..values.email = user.email ?? fUser!.email; 

        //Вызов функции для обновления данных пользователя
        await qUpdateUser.updateOne();
        //Получение обновленного пользователя 
        final findUser = await managedContext.fetchObjectWithID<User>(id);
        findUser!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

        return AppResponse.ok(message: 'Успешное обновление данных', body: findUser.backing.contents);
      
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления данных');
    }

   }

@Operation.put 
Future<Response> updatePassword(
  @Bind.header(HttpHeaders.authorizationHeader) String header, 
  @Bind.query('newPassword') String newPassword, 
  @Bind.query('oldPassword') String oldPassword 
) async {
  try {
    final id = AppUtils.getIdFromHeader(header);

    final qFindUser = Query<User>(managedContext)
      ..where((x) => x.id).equalTo(id)
      ..returningProperties((x) => [
        x.salt,
        x.hashPassword
      ]); 
    
    //Получаем только одну строчку
    final fUser = await qFindUser.fetchOne();

    //Создаем hash старого пароля 
    final oldHashPassword = 
          generatePasswordHash(oldPassword, fUser!.salt ?? "");

    //Проверка старого пароля с паролем в БД
    if (oldHashPassword != fUser.hashPassword) {
      return AppResponse.badRequest(
        message: 'Неверный старый пароль'
      ); 
    }

    //Создание хэшированного нового пароля
    final newHashPassword = 
          generatePasswordHash(newPassword, fUser.salt ?? "");
    
    //Создание запроса на обновление пароля 
    final qUpdateUser = Query<User>(managedContext)
          ..where((x) => x.id).equalTo(id)
          ..values.hashPassword = newHashPassword; 
    
    //Обновление пароля 
    await qUpdateUser.fetchOne();

    return AppResponse.ok (body: 'Пароль успешно обновлен'); 
  } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления пароля'); 
    
  }




  }
  

}



}