import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/history.dart';

import '../model/model_response.dart';
import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppHistoryController extends ResourceController {
  AppHistoryController(this.managedContext);

  final ManagedContext managedContext;

   @Operation.get()
    Future<Response> getHistory(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
    ) async {

      try {
      final id = AppUtils.getIdFromHeader(header); 
      final qGetHistory = Query<History>(managedContext)
            ..where((x) => x.user?.id).equalTo(id);
          
      final List<History> list = await qGetHistory.fetch(); 

      if (list.isEmpty)
          return Response.notFound(
            body: ModelResponse(data: [], message: 'История пуста'));
      
      return Response.ok(list);
      
    }
    
    catch (e) {
      return AppResponse.serverError(e); 
    }
}

}