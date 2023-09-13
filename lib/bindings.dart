import 'dart:io';

//iterate through screens and replace Get.put($s()) with Get.find<$s>()
void replaceGetPut(Directory screens) {
  for (var file in screens.listSync(recursive: true)) {
    if (file is File) {
      if (file.path.endsWith('.dart')) {
        String contents = file.readAsStringSync();
        contents = contents.replaceAllMapped(RegExp(r'Get.put<.*>'), (match) {
          return 'Get.put';
        });
        contents = contents.replaceAllMapped(RegExp(r'Get.put\(.*\)'), (match) {
          String? replacement = match.group(0);
          if (replacement == null) return "";
          replacement = replacement
              .replaceFirst("Get.put(", "Get.find<")
              .replaceFirst("())", ">()");
          return replacement;
        });
        file.writeAsStringSync(contents);
      }
    }
  }
}

//iterate through screens collect bindings of widgets
Map<String, List<String>> collectBindings(Directory screens) {
  Map<String, List<String>> bindings = {};
  for (var file in screens.listSync(recursive: true)) {
    if (file is File) {
      String contents = file.readAsStringSync();
      List<String> bindingsInFile = [];
      for (var match in RegExp(r'Get.find<.*>').allMatches(contents)) {
        String? replacement = match.group(0);
        if (replacement == null) continue;
        replacement = replacement
            .replaceFirst("Get.find<", "")
            .replaceFirst("Controller>", "Binding()");
        bindingsInFile.add(replacement);
      }
      if (bindingsInFile.isNotEmpty) {
        //get class name from content
        String className = contents.substring(
              contents.indexOf("class ") + 6,
              contents.indexOf(" extends"),
            ) +
            "()";
        bindings[className] = bindingsInFile;
      }
    }
  }
  return bindings;
}

//iterates through files in dir and creates replicas in a different dir
void createBindingsClasses({
  required Directory dir,
  required String packageName,
}) {
  dir.listSync(recursive: true).forEach((file) {
    if (file is File) {
      //modify content of file to create a bindings file
      String content = file.readAsStringSync();
      String className = content.substring(
          content.indexOf("class ") + 6, content.indexOf(" extends"));
      String importPath = "package:$packageName/src/" +
          file.path.substring(file.path.indexOf("/lib/src") + 8);

      String newPath = file.path.replaceAll("controller", "binding");
      print(newPath);
      var newFile = File(newPath);
      newFile.createSync(recursive: true);
      newFile.writeAsStringSync(
        bindingClass(
          className.replaceAll("Controller", ""),
          importPath,
        ),
      );
    }
  });
}

String bindingClass(String controllerName, String controllerPath) {
  //return template for a binding class
  return """
  import '$controllerPath';
  import 'package:get/get.dart';

  class ${controllerName}Binding extends Bindings {
    @override
    void dependencies() {
      Get.lazyPut<${controllerName}Controller>(() => ${controllerName}Controller());
    }
  }
  """;
}
