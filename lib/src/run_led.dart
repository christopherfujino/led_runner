import 'dart:convert';
import 'dart:io' show Process;

Future<Response> runLed(String name, {Config config = const Config()}) async {
  final result = Process.runSync(
      'led', <String>['get-builder', 'luci.flutter.${config.pool}:$name']);
  print('Launching LED build for "$name"...');
  final process = await Process.start('led', <String>['launch']);
  process.stdin.write(result.stdout);
  await process.stdin.flush();
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception('Trying to launch led build for $name failed');
  }
  final stdout = (await process.stdout.transform(utf8.decoder).join()).trim();
  return Response.fromJson(stdout);
}

/// Configuration for a LED build.
class Config {
  /// One of {try|prod|staging}.
  ///
  /// Scheduling prod or staging builds requires elevated permissions.
  final String pool;

  const Config({this.pool = 'try'});
}

/// STDOUT response from `led launch`.
///
/// ```
/// {
///   "buildbucket": {
///     "build_id": 8737050088984306881,
///     "host_name": "cr-buildbucket.appspot.com"
///   }
/// }
/// ```
class Response {
  late final int buildId;
  late final String hostName;

  Response.fromJson(String input) {
    try {
      final blob = json.decode(input.trim()) as Map<String, Object?>;
      final buildBucket = blob['buildbucket'] as Map<String, Object?>;
      buildId = buildBucket['build_id'] as int;
      hostName = buildBucket['host_name'] as String;
    } on Object catch (err) {
      throw Exception('Failed to parse the LED response:\n\n$input\n\n$err');
    }
  }
}
