import 'dart:io';

import 'package:yaml/yaml.dart';

import 'package:led_runner/led_runner.dart';

bool shouldRun(String name) {
  final prefix = name.split(' ').first.toLowerCase();

  return prefix == 'mac_ios' ||
      prefix == 'mac_x64_ios' ||
      prefix == 'mac_arm64_ios';
}

Future<void> main(List<String> arguments) async {
  final file = File('/usr/local/google/home/fujino/git/flutter/.ci.yaml');
  final map = loadYaml(file.readAsStringSync()) as YamlMap;
  final targets = (map['targets'] as List<Object?>).cast<YamlMap>();
  final namesThatShouldRun =
      targets.map((target) => target['name'] as String).where(shouldRun);
  final urls = <String>[];
  for (final name in namesThatShouldRun) {
    final response = await runLed(name);
    urls.add('https://ci.chromium.org/b/${response.buildId}');

    print('success');
  }
  print(urls.join('\n'));
}
