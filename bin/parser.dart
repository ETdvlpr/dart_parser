import 'dart:io';

import 'package:parser/bindings.dart';
import 'package:parser/routing.dart';
import 'package:parser/text.dart';
import 'package:parser/theming.dart';

void main(List<String> arguments) {
  String projectPath = "/home/dave/Desktop/elnet/projects/houfa_mobile/lib";
  Directory dir = Directory(projectPath);

  Map<String, String> translations = collectTranslations(dir);

  // createBindingsClasses(
  //   dir: Directory.fromUri(
  //     Uri.file("$projectPath/controllers/"),
  //   ),
  //   packageName: "haufa",
  // );
  // replaceGetPut(Directory.fromUri(Uri.file(projectPath)));

  // changeRoutes(dir, projectPath + "/utils/routes/routes.dart", "haufa");
  // changeNavigationToGet(Directory.fromUri(Uri.file(projectPath)));
  // addBindingsToPages(
  //   dir: dir,
  //   pagesRoute: projectPath + "/utils/routes/pages.dart",
  // );

  // changeColorsToTheme(dir);
  // changeStylesToTheme(dir);
}
