import 'dart:io';

import 'package:parser/bindings.dart';
import 'package:parser/routing.dart';

void main(List<String> arguments) {
  String projectPath = "/home/dave/elsabi-mobile-flutter/lib";
  Directory dir = Directory(projectPath);
  // createBindingsClasses(
  //   dir: Directory.fromUri(
  //     Uri.file("$projectPath/src/controller/"),
  //   ),
  //   packageName: "elsabi",
  // );
  // replaceGetPut(Directory.fromUri(Uri.file(projectPath)));

  // changeRoutes(dir, projectPath + "/src/routes/routes.dart", "elsabi");
  // changeNavigationToGet(Directory.fromUri(Uri.file(projectPath)));
  addBindingsToPages(
    dir: dir,
    pagesRoute: projectPath + "/src/routes/pages.dart",
  );
}
