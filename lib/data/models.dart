import 'dart:typed_data';
import 'package:aws_polly_api/polly-2016-06-10.dart';
import 'package:aws_rekognition_api/rekognition-2016-06-27.dart';

class SupportedLanguage {
  final String name;
  final String code;
  final LanguageCode? ttsCode;

  SupportedLanguage(this.name, this.code, {this.ttsCode});

  @override
  int get hashCode => Object.hash(name, code);

  @override
  bool operator ==(Object other) {
    return other is SupportedLanguage && other.code == code;
  }
}

class PreviousTTSInfo {
  SupportedLanguage language;
  String text;
  VoiceId voiceId;
  Uint8List? audioStream;
  PreviousTTSInfo(this.language, this.text, this.voiceId, {this.audioStream});

  bool sameInfo(
    SupportedLanguage language,
    String text,
    VoiceId voiceId,
  ) {
    return this.language == language &&
        this.text == text &&
        this.voiceId == voiceId;
  }

  void updateInfo(
    SupportedLanguage language,
    String text,
    VoiceId voiceId,
    Uint8List? audioStream,
  ) {
    if (this.language != language) this.language = language;
    if (this.text != text) this.text = text;
    if (this.voiceId != voiceId) this.voiceId = voiceId;
    if (this.audioStream != audioStream) this.audioStream = audioStream;
  }
}

class FlexTextDetection {
  final TextDetection _textDetection;
  String translatedText = '';
  FlexTextDetection(this._textDetection);

  double? getConfidence() {
    return _textDetection.confidence;
  }

  Geometry? getGeometry() {
    return _textDetection.geometry;
  }

  TextTypes? getType() {
    return _textDetection.type;
  }

  String? getDetectedText() {
    return _textDetection.detectedText;
  }
}
