import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/history.dart';

class User extends ManagedObject<_User> implements _User {}

class _User {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? userName; 
  @Column(unique: true, indexed: true)
  String? email;
  @Serialize(input: true, output: false)
  String? password; 
  @Column(nullable: true) 
  String? accessToken;
  @Column(nullable: true) 
  String? refreshToken; 

  @Column(omitByDefault: true) 
  String? salt; 
  @Column(omitByDefault: true)
  String? hashPassword; 
  @Column(defaultValue: "true", nullable: true)
  bool? isActive;

  ManagedSet<History>? historyList;
}