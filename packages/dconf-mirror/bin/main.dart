import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _cooldownMs = 500;

enum Prefer { dconf, file }

class Debounce {
  final int milliseconds;

  Timer? _timer;

  Debounce({required this.milliseconds});

  void run(void Function() callback) {
    _timer?.cancel();
    _timer = new Timer(Duration(milliseconds: milliseconds), callback);
  }
}

class WatchConfig {
  final String prefix;
  final String file;
  final Prefer prefer;

  WatchConfig({
    required this.prefix,
    required this.file,
    required this.prefer,
  });

  factory WatchConfig.fromJson(Map<String, dynamic> json) {
    final prefix = json['prefix'] as String;

    if (!prefix.endsWith('/') || !prefix.startsWith("/")) {
      throw ArgumentError(
        'prefix "$prefix" must start and end with \'/\' (dconf can only dump a directory)',
      );
    }

    return WatchConfig(
      prefix: prefix,
      file: json['file'] as String,
      prefer: Prefer.values.byName((json['prefer'] as String?) ?? 'dconf'),
    );
  }
}

class Config {
  final List<WatchConfig> watches;

  Config({required this.watches});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      watches: (json['watches'] as List)
          .map((w) => WatchConfig.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Watch {
  final String prefix;
  final String filepath;
  final Prefer prefer;

  Debounce _debounceFile = Debounce(milliseconds: _cooldownMs);
  Debounce _debounceDconf = Debounce(milliseconds: _cooldownMs);

  String _contentState = "";

  Watch(WatchConfig cfg)
      : prefix = cfg.prefix,
        filepath = cfg.file.startsWith('~/')
            ? '${Platform.environment['HOME']}/${cfg.file.substring(2)}'
            : cfg.file,
        prefer = cfg.prefer;

  Future<void> initSync() async {
    if (prefer == Prefer.file) {
      final file = File(filepath);

      if (await file.exists()) {
        stderr.writeln('init $prefix <- $filepath (prefer=file)');
        await _writeDconf(await file.readAsString());
        return;
      }
    }

    stderr.writeln('init $prefix -> $filepath');
    await _writeFile(await _readDconf());
  }

  Future<void> handleDconfChange() async {
    _debounceDconf.run(_onDconfChange);
  }

  Future<void> handleFileChange() async {
    _debounceFile.run(_onFileChange);
  }

  Future<String> _readDconf() async {
    final result = await Process.run('dconf', ['dump', prefix]);
    return result.stdout as String;
  }

  Future<void> _writeDconf(String content) async {
    final process = await Process.start('dconf', ['load', prefix]);
    process.stdin.write(content);
    await process.stdin.close();
    await process.exitCode;
  }

  Future<void> _writeFile(String content) async {
    final file = File(filepath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<void> _onDconfChange() async {
    final content = await _readDconf();
    if (content == _contentState) {
      return;
    }

    _contentState = content;

    try {
      stderr.writeln('dconf change $prefix -> $filepath');
      await _writeFile(content);
    } catch (e) {
      stderr.writeln('write $filepath: $e');
    }
  }

  Future<void> _onFileChange() async {
    final content = await File(filepath).readAsString();
    if (content == _contentState) {
      return;
    }

    _contentState = content;

    try {
      stderr.writeln('file change $filepath -> $prefix');
      await _writeDconf(content);
    } catch (e) {
      stderr.writeln('dconf load $prefix: $e');
    }
  }
}

Future<void> _watchDconf(Watch w) async {
  final process = await Process.start('dconf', ['watch', w.prefix]);

  await for (final _ in process.stdout.transform(utf8.decoder)) {
    await w.handleDconfChange();
  }

  stderr.writeln('dconf watch exited for ${w.prefix}');
  exit(1);
}

Future<void> _watchDir(String dir, Map<String, Watch> byPath) async {
  final events =
      FileSystemEvent.create | FileSystemEvent.modify | FileSystemEvent.move;

  await for (final event in Directory(dir).watch(events: events)) {
    var path = event.path;
    if (event is FileSystemMoveEvent) {
      path = event.destination ?? event.path;
    }

    final w = byPath[path];
    if (w != null) await w.handleFileChange();
  }
}

Future<void> _watchFiles(List<Watch> watches) {
  final byPath = Map.fromEntries(watches.map((w) => MapEntry(w.filepath, w)));
  final dirs = watches.map((w) => File(w.filepath).parent.path).toSet();

  return Future.wait(dirs.map((dir) => _watchDir(dir, byPath)));
}

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln('usage: dconf-mirror <config.json>');
    exit(1);
  }

  final Config config;
  try {
    config = Config.fromJson(
      jsonDecode(await File(args[0]).readAsString()) as Map<String, dynamic>,
    );
  } catch (e) {
    stderr.writeln('invalid config: $e');
    exit(1);
  }

  if (config.watches.isEmpty) {
    stderr.writeln('no watches configured');
    exit(1);
  }

  final watches = config.watches.map(Watch.new).toList();

  for (final w in watches) {
    await w.initSync();
  }

  await Future.wait([
    ...watches.map(_watchDconf),
    _watchFiles(watches),
  ]);
}
