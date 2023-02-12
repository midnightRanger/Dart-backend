import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration15 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_Post", SchemaColumn("status", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "true", isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    