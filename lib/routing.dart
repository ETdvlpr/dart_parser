import 'dart:io';

import 'package:parser/bindings.dart';

//iterate through files to replace Navigator.pushNamed with Get.to
void changeNavigationToGet(Directory dir) {
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File) {
      if (entity.path.endsWith('.dart')) {
        var file = File(entity.path);
        bool changed = false;
        var content = file.readAsStringSync();
        content = content.replaceAllMapped(
          RegExp(r'Navigator.pushNamed\((.|\n)*?\)'),
          (match) {
            String? replacement = match.group(0);
            if (replacement == null) return "";
            replacement = replacement
                .replaceFirst("Navigator.pushNamed(", "Get.toNamed(")
                .replaceFirst("context,", "");
            changed = true;
            return replacement;
          },
        );
        content = content.replaceAllMapped(
          RegExp(r'Navigator.pushReplacementNamed\((.|\n)*?\)'),
          (match) {
            String? replacement = match.group(0);
            if (replacement == null) return "";
            replacement = replacement
                .replaceFirst(
                    "Navigator.pushReplacementNamed(", "Get.offNamed(")
                .replaceFirst("context,", "");
            changed = true;
            return replacement;
          },
        );
        //replace all navigator.pop(context) with Get.back()
        content = content.replaceAllMapped(
          RegExp(r'Navigator\.pop\((.|\n)*?\)'),
          (match) {
            String? replacement = match.group(0);
            if (replacement == null) return "";
            replacement = replacement
                .replaceFirst("Navigator.pop(", "Get.back(")
                .replaceFirst("context,", "")
                .replaceFirst("context", "");
            String value = replacement.substring(
                replacement.indexOf("(") + 1, replacement.indexOf(")"));
            if (value.trim().isNotEmpty) {
              replacement = replacement.replaceFirst("back(", "back(result:");
            }
            changed = true;
            return replacement;
          },
        );
        String newContent =
            content.replaceAll("Navigator.of(context).pop()", "Get.back()");
        newContent =
            newContent.replaceAll("Navigator.maybePop(context)", "Get.back()");

        if (changed || newContent != content) {
          newContent = "import 'package:get/get.dart';\n" + newContent;
          file.writeAsStringSync(newContent);
        }
      }
    }
  }
}

void changeRoutes(Directory dir, String routesFilePath, String packageName) {
  Map<String, String> routes = getRoutesFromFile(File(routesFilePath));
  //iterate through files to replace named routes with constants
  for (FileSystemEntity entity in dir.listSync(recursive: true)) {
    if (entity is File) {
      if (entity.path != routesFilePath && entity.path.endsWith('.dart')) {
        String content = entity.readAsStringSync();
        bool changed = false;
        for (String route in routes.keys) {
          //check if content contains route with quotes
          if (content.contains('"$route"') || content.contains("'$route'")) {
            changed = true;
            content = content.replaceAll('"$route"', "Routes.${routes[route]}");
            content = content.replaceAll("'$route'", "Routes.${routes[route]}");
          }
        }
        if (changed) {
          String importPath = "package:$packageName/src/" +
              routesFilePath.substring(routesFilePath.indexOf("/lib/src") + 8);
          content = "import '$importPath';\n" + content;
          entity.writeAsStringSync(content);
        }
      }
    }
  }
}

Map<String, String> getRoutesFromFile(File routeConstants) {
  Map<String, String> routes = {};
  String content = routeConstants.readAsStringSync();
  content = content.substring(
    content.indexOf("{") + 1,
    content.lastIndexOf("}"),
  );
  content = content.replaceAll("static const String ", '');
  content = content.replaceAll(" = ", ':');
  content = content.replaceAll(";", '');
  content = content.replaceAll("'", '');
  //split by new line
  List<String> lines = content.split('\n');
  for (String line in lines) {
    if (line.contains(':')) {
      List<String> parts = line.split(':');
      routes[parts[1].trim()] = parts[0].trim();
    }
  }
  return routes;
}

void addBindingsToPages({required Directory dir, required String pagesRoute}) {
  Map<String, List<String>> bindings = collectBindings(dir);
  File pageFile = File(pagesRoute);
  String content = pageFile.readAsStringSync();
  //replace all pages with bindings
  for (String page in bindings.keys) {
    //find instance of page
    int index = content.indexOf(page);
    if (index != -1) {
      //replace page with page:binding
      content = content.replaceRange(
        index,
        index + page.length,
        '$page, bindings:[${bindings[page]!.join(', ')}]',
      );
    }
    pageFile.writeAsStringSync(content);
  }
}
