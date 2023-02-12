import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration12 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_User", SchemaColumn("isActive", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    