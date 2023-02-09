import 'dart:io';

import 'package:conduit/conduit.dart';

import '../model/author.dart';
import '../model/model_response.dart';
import '../model/post.dart';
import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppPostController extends ResourceController {
  AppPostController(this.managedContext); 

  final ManagedContext managedContext; 

  @Operation.post()
  Future<Response> createPost(
    @Bind.header(HttpHeaders.authorizationHeader) String header, 
    @Bind.body() Post post) async {
      try {
        //Получениe Id пользователя из хэдера 
        final id = AppUtils.getIdFromHeader(header); 
        //Запрос из БД автора по его Id 
        final author = await managedContext.fetchObjectWithID<Author>(id);

        //Если автора не существует, то нужно его создать 
        if (author == null) {
          //Создание автора с Id пользователя 
          final qCreateAuthor = Query<Author>(managedContext)..values.id = id; 
          await qCreateAuthor.insert(); 
          } 

          //Запрос для создания поста, передаем ID пользователя, контент из модели 
          final qCreatePost = Query<Post>(managedContext)
              ..values.author!.id = id
              ..values.content = post.content; 

              await qCreatePost.insert(); 

              return AppResponse.ok(message: 'Успешное создание поста');
      } catch (error) {
          return AppResponse.serverError(error, message: 'Ошибка создания поста');
      }
    }

    @Operation.get()
    Future<Response> getPosts(
      @Bind.header(HttpHeaders.authorizationHeader) String header
    ) async {

      try {
      final id = AppUtils.getIdFromHeader(header); 

      final qGetPost = Query<Post>(managedContext)
            ..where((x) => x.author!.id).equalTo(id);
          
      final List<Post> list = await qGetPost.fetch(); 

      if (list.isEmpty)
          return Response.notFound(
            body: ModelResponse(data: [], message: 'Постов не обнаружено'));
      
      return Response.ok(list);
    }
    
    catch (e) {
      return AppResponse.serverError(e); 
    }
}

@Operation.get("id")
    Future<Response> getPost(
       @Bind.header(HttpHeaders.authorizationHeader) String header, 
       @Bind.path("id") int id, 
    ) async {
      try {
        final currentAuthorId = AppUtils.getIdFromHeader(header); 
        final post = await managedContext.fetchObjectWithID<Post>(id); 

        if (post == null) {
          return AppResponse.ok(message: "Пост не найден");
        }
        if (post.author?.id != currentAuthorId) {
          return AppResponse.ok(message: "Нет доступа к посту");
        }
        post.backing.removeProperty("author");
        return AppResponse.ok(
          body: post.backing.contents, message: "Успешный вывод поста"
        );
      } catch (e) {
        return AppResponse.serverError(e, message: "Ошибка создания поста");
      }
    }

    @Operation.put('id')
    Future<Response> updatePost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.body() Post bodyPost) async {
          try {
            final currentAuthorId = AppUtils.getIdFromHeader(header); 
            final post = await managedContext.fetchObjectWithID<Post>(id); 
            
            if(post == null) {
              return AppResponse.ok(message: "Пост не найден"); 
            }
            if (post.author?.id != currentAuthorId) {
              return AppResponse.ok(message: "Нет доступа к посту");
            }

            final qUpdatePost = Query<Post>(managedContext)
                  ..where((x) => x.id).equalTo(id)
                  ..values.content = bodyPost.content; 
            
            await qUpdatePost.update(); 
            return AppResponse.ok(message: 'Пост успешно обновлен');
            } catch (e) {
              return AppResponse.serverError(e); 
            }

      }
    }