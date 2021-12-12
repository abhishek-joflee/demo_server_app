//! NOTE
// TO KILL SERVER IN UBUNTU ( use following command )
// sudo kill -9 `sudo lsof -t -i:8080`
// You can also use $() for command interpolation:
// sudo kill -9 $(sudo lsof -t -i:8080)

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final Router _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler);

Future<Response> _rootHandler(Request req) async {
  // JUST TRYING TO WAIT CLIENT ( it does wait for 2 seconds )
  // await Future.delayed(Duration(seconds: 2));
  String result =
      await File('${Directory.current.path}/bin/index.html').readAsString();
  return Response.ok(
    result,
    headers: {'content-type': 'text/html'},
  );
}

Response _echoHandler(Request request) {
  final String message = request.params['message'] ?? "";
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final _handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(_handler, ip, port);
  print('Server listening on port ${server.port}');
}
