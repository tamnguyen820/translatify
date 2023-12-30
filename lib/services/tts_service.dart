// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:aws_polly_api/polly-2016-06-10.dart';
import 'package:audioplayers/audioplayers.dart';

class TTSService {
  final Polly _polly;
  final audioPlayer = AudioPlayer();

  TTSService._({
    required String accessKey,
    required String secretKey,
    required String region,
  }) : _polly = Polly(
          region: region,
          credentials: AwsClientCredentials(
            accessKey: accessKey,
            secretKey: secretKey,
          ),
        );

  // Static instance of the class
  static TTSService? _instance;

  factory TTSService({
    required String accessKey,
    required String secretKey,
    required String region,
  }) {
    _instance ??= TTSService._(
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
    );

    return _instance!;
  }

  Future<VoiceId?> getVoiceId(LanguageCode ttsCode) async {
    try {
      DescribeVoicesOutput output = await _polly.describeVoices(
        engine: Engine.standard,
        languageCode: ttsCode,
      );
      if (output.voices != null && output.voices!.isNotEmpty) {
        return output.voices![0].id;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Uint8List?> createSpeech(String text, VoiceId voiceId) async {
    try {
      SynthesizeSpeechOutput output = await _polly.synthesizeSpeech(
        outputFormat: OutputFormat.mp3,
        text: text,
        voiceId: voiceId,
      );
      return output.audioStream;
    } catch (e) {
      print(e);
    }
    return null;
  }

  void playSpeech(Uint8List? audioStream) async {
    if (audioStream != null) {
      await audioPlayer.play(BytesSource(audioStream), volume: 100);
    }
  }
}
