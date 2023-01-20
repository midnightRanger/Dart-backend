import 'package:conduit/conduit.dart';

import 'Author.dart';

class Post extends ManagedObject<_Post> implements _Post {}

class _Post {
  @primaryKey
  int? id; //Номер поста 

  String? content; //Содержание поста 

  //Аннотация для связи (#переменная с которой хотим сделать связь; обязательна ли эта связь; что делать при удалении записи)
  @Relate(#postList, isRequired: true, onDelete: DeleteRule.cascade)
  Author? author; //Создаем связь с моделью Author
}