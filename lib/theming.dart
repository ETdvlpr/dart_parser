//iterate through screens collect bindings of widgets
import 'dart:io';
import 'dart:math';

Map<String, String> collectColors(Directory screens) {
  List<String> colors = [];
  for (var file in screens.listSync(recursive: true)) {
    if (file is File) {
      if (file.path.endsWith('.dart')) {
        String contents = file.readAsStringSync();
        for (var match in RegExp(r'Color\(.*?\)').allMatches(contents)) {
          String? replacement = match.group(0);
          if (replacement == null) continue;
          if (replacement.contains("0x")) {
            colors.add(replacement
                .toUpperCase()
                .replaceAll("COLOR", "Color")
                .replaceAll("0X", "0x"));
          }
        }
      }
    }
  }

  List<String> sortedKeys = colors.toSet().toList()..sort();
  Map<String, String> result = {};
  for (int i = 0; i < sortedKeys.length; i++) {
    result[sortedKeys[i]] = "color$i";
  }
  return result;
}

void changeColorsToTheme(Directory dir) {
  Map<String, String> colors = collectColors(dir);
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File) {
      if (entity.path.endsWith('.dart')) {
        var file = File(entity.path);
        bool changed = false;
        String contents = file.readAsStringSync();
        //replace all navigator.pop(context) with Get.back()
        contents = contents.replaceAllMapped(
          RegExp(r'Color\(.*?\)'),
          (match) {
            String? replacement = match.group(0);
            if (replacement == null) return "";
            if (replacement.contains("0x")) {
              changed = true;
              replacement = "AppTheme." +
                  (colors[replacement
                          .toUpperCase()
                          .replaceAll("COLOR", "Color")
                          .replaceAll("0X", "0x")] ??
                      "${Random().nextInt(500) + 100}");
              return replacement;
            }
            return replacement;
          },
        );

        if (changed) {
          contents =
              "import 'package:haufa/utils/theme/app_theme.dart';\n" + contents;
          file.writeAsStringSync(contents);
        }
      }
    }
  }

  for (String key in colors.keys) {
    print("$key: ${colors[key]}");
  }
}

Map<String, String> collectTextStyles(Directory screens) {
  List<String> styles = [];
  for (var file in screens.listSync(recursive: true)) {
    if (file is File) {
      if (file.path.endsWith('.dart')) {
        String contents = file.readAsStringSync();
        for (var match
            in RegExp(r'GoogleFonts.inter\((.|\n)*?\)').allMatches(contents)) {
          String? result = match.group(0);
          if (result == null) continue;
          result = result.replaceAll("GoogleFonts.inter(", "");
          result = result.substring(0, result.length - 1);
          var split = result.split(",");
          Map<String, String> attribs = {};
          for (String s in split) {
            s = s.trim();
            if (s.contains(":") && !s.startsWith("//")) {
              var pair = s.split(":");
              attribs[pair[0].trim()] = pair[1].trim();
            }
          }
          var sortedKeys = attribs.keys.toList()..sort();
          String key = "";
          for (String s in sortedKeys) {
            key += s + attribs[s]!;
          }
          if (key.isNotEmpty) {
            styles.add(key);
          }
        }
      }
    }
  }

  List<String> sortedKeys = styles.toSet().toList()..sort();
  Map<String, String> result = {};
  for (int i = 0; i < sortedKeys.length; i++) {
    result[sortedKeys[i]] = "style$i";
  }
  return result;
}

void changeStylesToTheme(Directory dir) {
  Map<String, String> styles = collectTextStyles(dir);
  Map<String, String> themeStyles = {};
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File) {
      if (entity.path.endsWith('.dart')) {
        var file = File(entity.path);
        bool changed = false;
        String contents = file.readAsStringSync();
        //replace all navigator.pop(context) with Get.back()
        contents = contents.replaceAllMapped(
          RegExp(r'GoogleFonts.inter\((.|\n)*?\)'),
          (match) {
            String? replacement = match.group(0);
            if (replacement == null) return "";
            changed = true;

            String result = replacement.replaceAll("GoogleFonts.inter(", "");
            result = result.substring(0, result.length - 1);
            var split = result.split(",");
            Map<String, String> attribs = {};
            for (String s in split) {
              s = s.trim();
              if (s.contains(":") && !s.startsWith("//")) {
                var pair = s.split(":");
                attribs[pair[0].trim()] = pair[1].trim();
              }
            }
            var sortedKeys = attribs.keys.toList()..sort();
            String key = "";
            for (String s in sortedKeys) {
              key += s + attribs[s]!;
            }
            if (key.isNotEmpty) {
              themeStyles[styles[key]!] = replacement;
              replacement = "AppTheme." + styles[key]!;
            }
            return replacement;
          },
        );

        if (changed) {
          contents =
              "import 'package:haufa/utils/theme/app_theme.dart';\n" + contents;
          file.writeAsStringSync(contents);
        }
      }
    }
  }

  for (String key in themeStyles.keys) {
    print("static const TextStyle title = $key: ${themeStyles[key]};");
  }
}
