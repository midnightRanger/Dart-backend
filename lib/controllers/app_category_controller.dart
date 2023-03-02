import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/category.dart';

import '../model/author.dart';
import '../model/history.dart';
import '../model/model_response.dart';
import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppCategoryController extends ResourceController {
  AppCategoryController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> createCategory(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Category category) async {
    try {
      //Получениe Id пользователя из хэдера
      final id = AppUtils.getIdFromHeader(header);
      //Запрос из БД автора по его Id
      var author = await managedContext.fetchObjectWithID<Author>(id);


      //Если автора не существует, то нужно его создать
      if (author == null) {
        //Создание автора с Id пользователя
        final qCreateAuthor = Query<Author>(managedContext)..values.id = id;
        await qCreateAuthor.insert();
      }
      author = await managedContext.fetchObjectWithID<Author>(id);

      
        final qCreateCategory = Query<Category>(managedContext)
          ..values.categoryName = category.categoryName
          ..values.author = author;
        await qCreateCategory.insert();


      var qHistoryAdd = Query<History>(managedContext)
        ..values.dateTime = DateTime.now()
        ..values.type = "Category with name ${category.categoryName} created"
        ..values.user?.id = id;
      qHistoryAdd.insert();

      return AppResponse.ok(message: 'Успешное создание категории');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка создания категории');
    }
  }

  @Operation.get()
  Future<Response> getCategories(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      {@Bind.query('keyword') String? keyword,
      @Bind.query('pageLimit') int pageLimit = 0,
      @Bind.query('skipRows') int skipRows = 0}) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      if (keyword == null) {
        final qGetCategory = Query<Category>(managedContext)
          ..fetchLimit = pageLimit
          ..offset = pageLimit * skipRows
          ..where((x) => x.author!.id).equalTo(id);

        final List<Category> list = await qGetCategory.fetch();

        if (list.isEmpty)
          return Response.notFound(
              body: ModelResponse(data: [], message: 'Категорий не обнаружено'));

        return Response.ok(list);
      } else {
        // final qGetPost = Query<Post>(managedContext)
        //       ..where((x) => x.author!.id).equalTo(id) ..where((x) => x.content).contains(keyword);
        //

        final qGetCategory = Query<Category>(managedContext)
          ..fetchLimit = pageLimit
          ..offset = pageLimit * skipRows
          ..predicate = new QueryPredicate(
              "LOWER(categoryName) like '%' || LOWER(@keyword) || '%'",
              {"keyword": keyword});
        final List<Category> list = await qGetCategory.fetch();

        if (list.isEmpty)
          return Response.notFound(
              body: ModelResponse(data: [], message: 'Категорий не обнаружено'));

        var qHistoryAdd = Query<History>(managedContext)
          ..values.dateTime = DateTime.now()
          ..values.type = "Listed categories"
          ..values.user?.id = id;
        qHistoryAdd.insert();

        return Response.ok(list);
      }
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.get('id')
  Future<Response> getCategory(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      //final post = await managedContext.fetchObjectWithID<Post>(id);

      final qGetCategory = Query<Category>(managedContext)
        ..where((x) => x.author!.id).equalTo(currentAuthorId)
        ..where((x) => x.id).equalTo(id)
        ..join(object:(x) => x.author);

      final category = await qGetCategory.fetchOne();

      if (category == null) {
        return AppResponse.ok(message: "Категория не найдена");
      }
      if (category.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к категории");
      }

      var qHistoryAdd = Query<History>(managedContext)
        ..values.dateTime = DateTime.now()
        ..values.type = "Listed category ${category.categoryName}"
        ..values.user?.id = currentAuthorId;
      qHistoryAdd.insert();

      category.backing.removeProperty("author");

      var response = AppResponse.ok(message: 'Найдена категория', body: category.backing.contents);
      return response;
    } catch (e) {
      return AppResponse.serverError(e, message: "Ошибка поиска категории");
    }
  }

  @Operation.put('id')
  Future<Response> updateCategory(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.query("categoryName") String categoryName) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);

      final qGetCategory = Query<Category>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..join(object: (x) => x.author);
      
      var category = await qGetCategory.fetchOne();

      if (category == null) {
        return AppResponse.ok(message: "Категория не найдена");
      }
      if (category.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к категории");
      }

      final qUpdateCategory = Query<Category>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.categoryName = categoryName; 

      await qUpdateCategory.update();

      var qHistoryAdd = Query<History>(managedContext)
        ..values.dateTime = DateTime.now()
        ..values.type = "Category with name ${categoryName} updated"
        ..values.user?.id = currentAuthorId;
      qHistoryAdd.insert();
      
var response = AppResponse.ok(message: 'Категория успешно обновлена'); 
      return response; 
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.delete("id")
  Future<Response> deleteCategory(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final category = await managedContext.fetchObjectWithID<Category>(id);

      if (category == null) {
        return AppResponse.ok(message: "Категория не найдена");
      }
      if (category.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к категории");
      }
      final qDeleteCategory = Query<Category>(managedContext)
        ..where((x) => x.id).equalTo(id);

      await qDeleteCategory.delete();

      var qHistoryAdd = Query<History>(managedContext)
        ..values.dateTime = DateTime.now()
        ..values.type = "Category with name ${category.categoryName} deleted"
        ..values.user?.id = currentAuthorId;
      qHistoryAdd.insert();

      return AppResponse.ok(message: "Категория успешно удален");
    } catch (e) {
      return AppResponse.serverError(e, message: "Ошибка удаления категории");
    }
  }
}