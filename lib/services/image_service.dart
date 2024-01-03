// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:aws_rekognition_api/rekognition-2016-06-27.dart';

class ImageService {
  final Rekognition _rekognition;

  // Private constructor
  ImageService._({
    required String accessKey,
    required String secretKey,
    required String region,
  }) : _rekognition = Rekognition(
          region: region,
          credentials: AwsClientCredentials(
            accessKey: accessKey,
            secretKey: secretKey,
          ),
        );

  // Static instance of the class
  static ImageService? _instance;

  factory ImageService({
    required String accessKey,
    required String secretKey,
    required String region,
  }) {
    _instance ??= ImageService._(
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
    );

    return _instance!;
  }

  Future<List<TextDetection>?> detectText(Uint8List bytes) async {
    try {
      final reponse = await _rekognition.detectText(
        image: Image(bytes: bytes),
        filters: DetectTextFilters(
          wordFilter: DetectionFilter(
            minBoundingBoxHeight: 0.02,
            minBoundingBoxWidth: 0.05,
            minConfidence: 0.5,
          ),
        ),
      );
      return reponse.textDetections;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
