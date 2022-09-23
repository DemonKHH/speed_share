import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:speed_share/app/controller/chat_controller.dart';
import 'package:speed_share/config/config.dart';
import 'package:file_manager_view/file_manager_view.dart' as f;

var app = Router();
final corsHeader = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': '*',
  'Access-Control-Allow-Methods': '*',
  'Access-Control-Allow-Credentials': 'true',
};

class Server {
  // 启动消息服务端
  static Future<int> start() async {
    ChatController controller = Get.find();
    app.post('/', (Request request) async {
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      Map<String, dynamic> data = jsonDecode(await request.readAsString());
      controller.handleMessage(data);
      // 这儿应该返回本机信息
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });
    // 给web用的接口
    // 用来轮询新的消息
    app.get('/message', (Request request) {
      if (controller.messageWebCache.isNotEmpty) {
        return Response.ok(
          jsonEncode(controller.messageWebCache.removeAt(0)),
          headers: corsHeader,
        );
      }
      return Response.ok(
        '',
        headers: corsHeader,
      );
    });
    // 返回速享网页的handler
    var handler = createStaticHandler(
      RuntimeEnvir.filesPath,
      listDirectories: true,
      defaultDocument: 'index.html',
    );
    app.mount('/', (r) {
      // `http://192.168.0.103:12000/sdcard/`的形式，说明是想要访问文件
      if (r.requestedUri.path.startsWith('/sdcard')) {
        try {
          return f.Server.getFileServerHandler().call(r);
        } catch (e) {
          return Response.notFound(
            e.toString(),
            headers: corsHeader,
          );
        }
      } else {
        // `http://192.168.0.103:12000/`的形式，说明是想要打开速享网页端
        return handler(r);
      }
    });
    int port = await getSafePort(
      Config.chatPortRangeStart,
      Config.chatPortRangeEnd,
    );
    // ignore: unused_local_variable
    HttpServer server = await io.serve(
      app,
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    return port;
  }
}

Future<String> execCmd(
  String cmd, {
  bool throwException = true,
}) async {
  final List<String> args = cmd.split(' ');
  ProcessResult execResult;
  if (Platform.isWindows) {
    execResult = await Process.run(
      RuntimeEnvir.binPath + Platform.pathSeparator + args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
  } else {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
  }
  if ('${execResult.stderr}'.isNotEmpty) {
    if (throwException) {
      Log.w('adb stderr -> ${execResult.stderr}');
      throw Exception(execResult.stderr);
    }
  }
  // Log.e('adb stdout -> ${execResult.stdout}');
  return execResult.stdout.toString().trim();
}
