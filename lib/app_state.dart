import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aws_polly_api/polly-2016-06-10.dart';
import 'package:translatify/services/tts_service.dart';

import '/data/models.dart';
import '/data/constants.dart';
import '/services/translate_service.dart';

class AppState extends ChangeNotifier {
  final translateService = TranslateService(
    accessKey: dotenv.env['AWS_ACCESS_KEY'] as String,
    secretKey: dotenv.env['AWS_SECRET_KEY'] as String,
    region: dotenv.env['AWS_REGION'] as String,
  );
  final ttsService = TTSService(
    accessKey: dotenv.env['AWS_ACCESS_KEY'] as String,
    secretKey: dotenv.env['AWS_SECRET_KEY'] as String,
    region: dotenv.env['AWS_REGION'] as String,
  );

  // Text main page
  SupportedLanguage languageFrom = englishLanguage;
  SupportedLanguage languageTo = frenchLanguage;
  SupportedLanguage? suggestedLanguage;
  String sourceText = "";
  String translatedText = "";
  VoiceId? ttsVoiceIdFrom;
  VoiceId? ttsVoiceIdTo;
  PreviousTTSInfo? prevTTSFromInfo;
  PreviousTTSInfo? prevTTSToInfo;

  AppState() {
    initializeTtsVoiceIds();
  }

  void clearStateWhenNavigate() {
    suggestedLanguage = null;
    sourceText = '';
    translatedText = '';
    ttsVoiceIdFrom = null;
    ttsVoiceIdTo = null;
    prevTTSFromInfo = null;
    prevTTSToInfo = null;
  }

  // Text page functions

  Future<void> initializeTtsVoiceIds() async {
    ttsVoiceIdFrom = await getVoiceId(languageFrom);
    ttsVoiceIdTo = await getVoiceId(languageTo);
    notifyListeners();
  }

  void changeLanguageFrom(SupportedLanguage target) async {
    languageFrom = target;
    notifyListeners();
    ttsVoiceIdFrom = await getVoiceId(languageFrom);
    notifyListeners();
  }

  void changeLanguageTo(SupportedLanguage target) async {
    languageTo = target;
    notifyListeners();
    ttsVoiceIdTo = await getVoiceId(languageTo);
    notifyListeners();
  }

  void changeSuggestedLanguage(SupportedLanguage? target) {
    suggestedLanguage = target;
    notifyListeners();
  }

  void swapLanguageFromAndTo() {
    // Can only swap local variable
    var tempLang = languageFrom;
    languageFrom = languageTo;
    languageTo = tempLang;
    notifyListeners();
  }

  void swapVoiceId() {
    var tempVoiceId = ttsVoiceIdFrom;
    ttsVoiceIdFrom = ttsVoiceIdTo;
    ttsVoiceIdTo = tempVoiceId;
    notifyListeners();
  }

  void swapPrevTTSInfo() {
    var tempPrevTTSInfo = prevTTSFromInfo;
    prevTTSFromInfo = prevTTSToInfo;
    prevTTSToInfo = tempPrevTTSInfo;
    notifyListeners();
  }

  void updateSourceText(String text) {
    sourceText = text;
    notifyListeners();
  }

  void updateTranslatedText(String text) {
    translatedText = text;
    notifyListeners();
  }

  void triggerTranslation() async {
    changeSuggestedLanguage(null);
    if (sourceText.isEmpty) {
      updateTranslatedText('');
      return;
    }
    var tempTranslatedText = translatedText;
    if (translatedText.isEmpty) {
      tempTranslatedText = 'Translating...';
    } else {
      tempTranslatedText += '...';
    }
    updateTranslatedText(tempTranslatedText);

    String result = await translateService.translateText(
      sourceLanguageCode: languageFrom.code,
      targetLanguageCode: languageTo.code,
      text: sourceText,
    );
    updateTranslatedText(result);
    notifyListeners();
    try {
      SupportedLanguage suggestion = await translateService.freeDetectLanguage(
        targetLanguageCode: languageTo.code,
        text: sourceText,
      );
      if (suggestion != languageFrom) {
        changeSuggestedLanguage(suggestion);
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void acceptSuggestedLanguage() {
    if (suggestedLanguage != null && suggestedLanguage == languageTo) {
      changeSuggestedLanguage(null);
      swapLanguageFromAndTo();
      swapVoiceId();
      swapPrevTTSInfo();
      return;
    }
    changeLanguageFrom(suggestedLanguage!);
    changeSuggestedLanguage(null);
    notifyListeners();
  }

  Future<VoiceId?> getVoiceId(SupportedLanguage language) async {
    if (language.ttsCode != null) {
      return await ttsService.getVoiceId(language.ttsCode as LanguageCode);
    }
    return null;
  }

  void _playSpeech({
    VoiceId? ttsVoiceId,
    PreviousTTSInfo? prevTTSInfo,
    String sourceText = '',
  }) async {
    if (ttsVoiceId == null) return;

    if (prevTTSInfo != null &&
        prevTTSInfo.sameInfo(languageFrom, sourceText, ttsVoiceId)) {
      ttsService.playSpeech(prevTTSInfo.audioStream);
      return;
    }

    final audioStream = await ttsService.createSpeech(sourceText, ttsVoiceId);
    if (prevTTSInfo != null) {
      prevTTSInfo.updateInfo(languageFrom, sourceText, ttsVoiceId, audioStream);
    } else {
      prevTTSInfo = PreviousTTSInfo(
        languageFrom,
        sourceText,
        ttsVoiceId,
        audioStream: audioStream,
      );
    }
    ttsService.playSpeech(audioStream);
  }

  void playSourceTextSpeech() async {
    _playSpeech(
      ttsVoiceId: ttsVoiceIdFrom,
      prevTTSInfo: prevTTSFromInfo,
      sourceText: sourceText,
    );
  }

  void playTranslatedTextSpeech() async {
    _playSpeech(
      ttsVoiceId: ttsVoiceIdTo,
      prevTTSInfo: prevTTSToInfo,
      sourceText: translatedText,
    );
  }
}
