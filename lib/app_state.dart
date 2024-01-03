import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aws_polly_api/polly-2016-06-10.dart';
import 'package:aws_rekognition_api/rekognition-2016-06-27.dart';

import '/data/models.dart';
import '/data/constants.dart';
import '/services/translate_service.dart';
import '/services/tts_service.dart';
import '/services/image_service.dart';

class AppState extends ChangeNotifier {
  final _translateService = TranslateService(
    accessKey: dotenv.env['AWS_ACCESS_KEY'] as String,
    secretKey: dotenv.env['AWS_SECRET_KEY'] as String,
    region: dotenv.env['AWS_REGION'] as String,
  );
  final _ttsService = TTSService(
    accessKey: dotenv.env['AWS_ACCESS_KEY'] as String,
    secretKey: dotenv.env['AWS_SECRET_KEY'] as String,
    region: dotenv.env['AWS_REGION'] as String,
  );
  final _imageService = ImageService(
    accessKey: dotenv.env['AWS_ACCESS_KEY'] as String,
    secretKey: dotenv.env['AWS_SECRET_KEY'] as String,
    region: dotenv.env['AWS_REGION_IMAGE_DETECTION'] as String,
  );

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

    String result = await _translateService.translateText(
      sourceLanguageCode: languageFrom.code,
      targetLanguageCode: languageTo.code,
      text: sourceText,
    );
    updateTranslatedText(result);
    notifyListeners();
    try {
      SupportedLanguage suggestion = await _translateService.freeDetectLanguage(
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
      return await _ttsService.getVoiceId(language.ttsCode as LanguageCode);
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
      _ttsService.playSpeech(prevTTSInfo.audioStream);
      return;
    }

    final audioStream = await _ttsService.createSpeech(sourceText, ttsVoiceId);
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
    _ttsService.playSpeech(audioStream);
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

  // Image page functions
  List<FlexTextDetection>? flexTextDetections;

  void updateFlexTextDetections(List<FlexTextDetection>? detections) {
    flexTextDetections = detections;
    notifyListeners();
  }

  Future<void> detectTextInImage(Uint8List bytes) async {
    final textDetectionList = await _imageService.detectText(bytes);
    // Only concern about lines, not individual words in those lines
    List<FlexTextDetection> flexTextDetectionList = [];
    String concatSourceText = '';
    for (var item in textDetectionList!) {
      if (item.type == TextTypes.word) break;
      flexTextDetectionList.add(FlexTextDetection(item));
      concatSourceText += "${item.detectedText}\n";
    }
    updateFlexTextDetections(flexTextDetectionList);
    updateSourceText(concatSourceText);
  }

  Future<void> translateImageDetections() async {
    assert(flexTextDetections != null);
    String result = await _translateService.translateText(
      sourceLanguageCode: languageFrom.code,
      targetLanguageCode: languageTo.code,
      text: sourceText,
    );
    List<String> resultLines = result.split('\n');
    for (int i = 0; i < flexTextDetections!.length; i++) {
      flexTextDetections?[i].translatedText = resultLines[i];
    }
    notifyListeners();
  }
}
