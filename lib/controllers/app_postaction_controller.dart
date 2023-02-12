import 'dart:io';

import 'package:conduit/conduit.dart';

import '../model/post.dart';
import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppPostActionController extends ResourceController {
  AppPostActionController(this.managedContext); 

  final ManagedContext managedContext; 

    @Operation.delete("id")
    Future<Response> logicDelete(
       @Bind.header(HttpHeaders.authorizationHeader) String header, 
       @Bind.path("id") int id) async
        {
      try {
        final currentAuthorId = AppUtils.getIdFromHeader(header);
        final post = await managedContext.fetchObjectWithID<Post>(id);

        if (post == null) {
          return AppResponse.ok(message: "Пост не найден");
        }
        if (post.author?.id != currentAuthorId) {
          return AppResponse.ok(message: "Нет доступа к посту");  
        }
        final qLogicDeletePost = Query<Post>(managedContext)
              ..where((x) => x.id).equalTo(id);
        var logicDeletePost  = await qLogicDeletePost.fetchOne();

        if (!logicDeletePost!.status!) {
          return AppResponse.ok(message: "Пост уже удален");
        }

        qLogicDeletePost
              ..values.status = false;  
        
        qLogicDeletePost.updateOne(); 
        return AppResponse.ok(message: "Логическое удаление поста успешно произведено");

      } catch (e) {
        return AppResponse.serverError(e, message: "Ошибка удаления поста");
      }
       }
       


  
     @Operation.put("id")
     Future<Response> logicRestore(
       @Bind.header(HttpHeaders.authorizationHeader) String header, 
       @Bind.path("id") int id) async
        {
      try {
        final currentAuthorId = AppUtils.getIdFromHeader(header);
        final post = await managedContext.fetchObjectWithID<Post>(id);

        if (post == null) {
          return AppResponse.ok(message: "Пост не найден");
        }
        if (post.author?.id != currentAuthorId) {
          return AppResponse.ok(message: "Нет доступа к посту");  
        }
        final qLogicDeletePost = Query<Post>(managedContext)
              ..where((x) => x.id).equalTo(id);
        var logicDeletePost  = await qLogicDeletePost.fetchOne();

        if (logicDeletePost!.status!) {
          return AppResponse.ok(message: "Пост не находится в корзине");
        }

        qLogicDeletePost
              ..values.status = true;  
        
        qLogicDeletePost.updateOne(); 
        return AppResponse.ok(message: "Пост убран из корзины");

      } catch (e) {
        return AppResponse.serverError(e, message: "Ошибка удаления поста из корзины");
      }
       }
}