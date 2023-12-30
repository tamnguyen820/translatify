// ignore_for_file: avoid_print

import 'package:aws_translate_api/translate-2017-07-01.dart';
import 'package:translator/translator.dart';

import '/data/models.dart';
import '/data/constants.dart';

class TranslateService {
  // Both translators should use ISO 639 codes, but maybe different versions
  // Also they may supported different languages, so we rely on the main translator
  final Translate _mainTranslator;
  final GoogleTranslator _altTranslator = GoogleTranslator();

  // Private constructor
  TranslateService._({
    required String accessKey,
    required String secretKey,
    required String region,
  }) : _mainTranslator = Translate(
          region: region,
          credentials: AwsClientCredentials(
            accessKey: accessKey,
            secretKey: secretKey,
          ),
        );

  // Static instance of the class
  static TranslateService? _instance;

  factory TranslateService({
    required String accessKey,
    required String secretKey,
    required String region,
  }) {
    _instance ??= TranslateService._(
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
    );

    return _instance!;
  }

  Future<String> translateText({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  }) async {
    try {
      // Use main translator
      final response = await _mainTranslator.translateText(
        sourceLanguageCode: sourceLanguageCode,
        targetLanguageCode: targetLanguageCode,
        text: text,
      );
      print(response.sourceLanguageCode);
      return response.translatedText;
    } catch (e) {
      print(e);
    }
    try {
      // Use alt translator
      final result = await _altTranslator.translate(
        text,
        from: sourceLanguageCode,
        to: targetLanguageCode,
      );
      return result.toString();
    } catch (e) {
      print(e);
      return 'ERROR: cannot translate at this time!';
    }
  }

  Future<SupportedLanguage> freeDetectLanguage({
    required String targetLanguageCode,
    required String text,
  }) async {
    // Use alt translator to detect
    final result = await _altTranslator.translate(text, to: targetLanguageCode);
    if (result.sourceLanguage.code == detectLanguage.code) {
      // (Target language - target language) translation
      return supportedLanguages
          .firstWhere((lang) => lang.code == targetLanguageCode);
    }
    // Other pair or error case
    final suggestedLanguage = supportedLanguages
        .firstWhere((lang) => lang.code == result.sourceLanguage.code);
    return suggestedLanguage;
  }
}
