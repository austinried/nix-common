{ lib, buildDartApplication }:

buildDartApplication {
  pname = "dconf-mirror";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./pubspec.yaml
      ./pubspec.lock
      ./bin/main.dart
    ];
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  meta = {
    description = "Bidirectional mirror between dconf subtrees and files";
    mainProgram = "dconf-mirror";
  };
}
