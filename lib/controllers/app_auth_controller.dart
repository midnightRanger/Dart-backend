import 'dart:html';

import 'package:conduit/conduit.dart';

import '../model/model_response.dart';
import '../model/user.dart';
import ''


import '../utils/app_response.dart';class AppAuthController extends ResourceController {
  AppAuthController(this.managedContext);

  final ManagedContext managedContext;

@Operation.post() 
Future<Response> signIn(@Bind.body() User user) async {
  if(user.password == null || user.userName == null) {
    return Response.badRequest(
      body: ModelResponse(message: 'Поля: password и username обязательны'));
  }

  try {
    final qFindUser = Query<User>(managedContext)..where((element) => element.userName).equalTo(user.userName)..
    returningProperties((element) => [
      element.id,
      element.salt,
      element.hashPassword],
      );

    //Получение первого элемента из списка
    final findUser = await qFindUser.fetchOne();

    if (findUser == null) {
      throw QueryException.input("Пользователь не найден", []);
    }

    // генерация хэша пароля для дальнейшей проверки
    final requestHashPassword = 
      generatePasswordHash(user.password ?? ' ', findUser.salt ?? ' ');

    // Проверка пароля 
    if (requestHashPassword == findUser.hashPassword) {
      //Обновления token пароля
      _updateTokens(findUser.id ?? -1, managedContext); 

      //Получаем данные пользователя 
      final newUser = 
        await managedContext.fetchObjectWithID<User>(findUser.id);

      return Response.ok(ModelResponse(
        data: newUser!.backing.contents, 
        message: "Успешная авторизация!",
      ));
    }
        else {
          throw QueryException.input("Неверный пароль", []);
        } 
  }
      
    catch (e) {
      return AppResponse.serverError(e);
    }
  }
}