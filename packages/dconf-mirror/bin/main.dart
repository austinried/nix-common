import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

const _cooldownMs = 500;

final _configHome = Platform.environment['XDG_CONFIG_HOME'] ?? '~/.config';

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

  factory WatchConfig.fromJson(Map<String, dynamic> json, String configDir) {
    final prefix = json['prefix'] as String;

    if (!prefix.endsWith('/') || !prefix.startsWith("/")) {
      throw ArgumentError(
        'prefix "$prefix" must start and end with \'/\' (dconf can only dump a directory)',
      );
    }

    var file = json['file'] as String?;
    if (file != null) {
      file =
          !file.startsWith('/') ? '${configDir}/${file}' : _normalizeHome(file);
    } else {
      final parts = prefix.split('/').where((s) => s.isNotEmpty).toList();
      file = '${configDir}/${parts.join('/')}.ini';
    }

    return WatchConfig(
      prefix: prefix,
      file: file,
      prefer: Prefer.values.byName((json['prefer'] as String?) ?? 'dconf'),
    );
  }
}

class Config {
  final List<WatchConfig> watches;

  Config({required this.watches});

  factory Config.fromJson(Map<String, dynamic> json, String configDir) {
    return Config(
      watches: (json['watches'] as List)
          .map((w) => WatchConfig.fromJson(
                w as Map<String, dynamic>,
                configDir,
              ))
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
        filepath = cfg.file,
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

  Future<void> syncOnce(Prefer from) async {
    _contentState = "";

    switch (from) {
      case Prefer.dconf:
        await _onDconfChange();
      case Prefer.file:
        await _onFileChange();
    }
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

final _parser = ArgParser()
  ..addOption(
    'config',
    abbr: 'c',
    defaultsTo: '${_configHome}/dconf-mirror/config.json',
    valueHelp: 'config-path',
    help: 'Path to configuration file',
  )
  ..addOption(
    'sync-dir',
    abbr: 's',
    valueHelp: 'sync-path',
    help:
        'Path to sync files to if watch file is relative.\nDefaults to parent directory of <config-path>',
  )
  ..addOption(
    'once-from',
    abbr: 'o',
    allowed: Prefer.values.asNameMap().keys,
    valueHelp: 'location',
    help: 'Sync all configured watches once from <location> and exit',
  )
  ..addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Print this help message',
  );

void _printUsage() {
  final usage = _parser.usage.splitMapJoin('\n', onNonMatch: (l) => '\t${l}');

  stderr.writeln('Usage:');
  stderr.writeln(usage);
}

ArgResults _parseArgs(List<String> args) {
  try {
    final res = _parser.parse(args);

    if (res.flag('help')) {
      _printUsage();
      exit(0);
    }

    return res;
  } catch (err) {
    _printUsage();
    exit(1);
  }
}

Future<void> _sync(List<Watch> watches) async {
  for (final w in watches) {
    await w.initSync();
  }

  await Future.wait([
    ...watches.map(_watchDconf),
    _watchFiles(watches),
  ]);
}

Future<void> _syncOnce(List<Watch> watches, Prefer from) async {
  for (final w in watches) {
    await w.syncOnce(from);
  }
}

String _normalizeHome(String path) {
  return path.startsWith('~/')
      ? '${Platform.environment['HOME']}/${path.substring(2)}'
      : path;
}

Future<void> main(List<String> rawArgs) async {
  final args = _parseArgs(rawArgs);

  final configFile = File(_normalizeHome(args.option('config')!));
  final configDir = args.option('sync-dir') != null
      ? Directory(_normalizeHome(args.option('sync-dir')!)).absolute
      : configFile.parent.absolute;

  final Config config;
  try {
    config = Config.fromJson(
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>,
      configDir.path,
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

  final onceFrom = args.option('once-from');
  if (onceFrom != null) {
    await _syncOnce(watches, Prefer.values.byName(onceFrom));
  } else {
    await _sync(watches);
  }
}
