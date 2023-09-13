import 'dart:io';

class TranslationCollector {
  static final Set<String> validFunctions = {
    'BasicResponse',
    'CompleteModal',
    'Text',
    'TextFormBuilder',
    'dialog',
    'getSettingOption',
    'getNotificationOption',
    'IconButton',
    'SliverPersistentHeader',
    'Tab',
    'ConfirmDialog',
    'AlertDialog',
    'Container',
    'BottomFloatingButton',
    'RadioListTile',
    'ElevatedButton',
    'Pinput',
    'TextButton',
    'RichText',
    'TextSpan',
    'CheckboxListTile',
    'LocationSearchTextField',
    'ChatBubble',
    'InputDecoration',
    'toast',
    'TutorialItem',
    'handleErrorResponse',
    'requestEmailVerification',
    'InfoWindow',
    'OnboardingInfo',
    'Suggestion',
    'print',
    '_getLegendText',
    '_buildFilterButton',
    'LineTooltipItem',
    'ForegroundNotificationConfig',
  };

  static Map<String, String> collectTranslationsInDir(Directory dir) {
    final Map<String, String> translations = {};
    final RegExp exp = RegExp(r'(\b\w+)\s*\(([^)]*)\)');

    for (var file in dir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        String contents = file.readAsStringSync();

        for (var match in exp.allMatches(contents)) {
          final String? functionName = match.group(1);
          final String? arguments = match.group(2);

          if (functionName == null || arguments == null || arguments.isEmpty) {
            continue;
          }

          if (!validFunctions.contains(functionName)) continue;

          final RegExp stringExp =
              RegExp(r'''(["'])(?:(?:(?!\1)[\s\S])|\\[\s\S])*?\1''');

          for (var argumentMatch in stringExp.allMatches(arguments)) {
            String? replacement = argumentMatch.group(0);

            if (replacement == null || replacement.isEmpty) continue;
            if (replacement.startsWith("'") || replacement.startsWith('"')) {
              replacement = replacement.substring(1, replacement.length - 1);
            }

            final String key = replacement
                .trim()
                .replaceAll(RegExp(r'[^\w\s]+'), '_')
                .replaceAll(' ', '_')
                .toLowerCase()
                .replaceAll('__', '_')
                .replaceAll(RegExp(r'^_|_$'), '');

            translations[key] = replacement;
            final String replacementKey = '"$key".tr';

            contents =
                contents.replaceAll("'${translations[key]}'", replacementKey);
            contents =
                contents.replaceAll('"${translations[key]}"', replacementKey);
          }

          if (contents.contains('.tr') &&
              !contents.contains('import \'package:get/get.dart\';')) {
            contents = 'import \'package:get/get.dart\';\n' + contents;
          }
          file.writeAsStringSync(contents);
        }
      }
    }

    return translations;
  }
}

Map<String, String> collectTranslations(Directory dir) {
  final List<String> paths = [
    '/pages',
    '/screens',
    '/widgets',
    '/controllers',
  ];

  final Map<String, String> translations = {};

  for (String path in paths) {
    final Directory directory = Directory(dir.path + path);
    if (directory.existsSync()) {
      translations
          .addAll(TranslationCollector.collectTranslationsInDir(directory));
    }
  }

  for (String key in translations.keys) {
    final String t = translations[key]!.replaceAll("'", "\\'");
    print("'$key': '$t',");
  }

  return translations;
}
