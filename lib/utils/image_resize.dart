import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;

// Uint8List resizeImage(Uint8List bytes, double width, double height) {
//   final image = img.decodeImage(bytes);
//   final png = img.encodePng(
//       img.copyResize(image!, width: width.toInt(), height: height.toInt()));
//   return png;
// }

Size calculateFittedSize(
    Uint8List imageBytes, double targetWidth, double targetHeight) {
  final image = img.decodeImage(imageBytes);
  double widthScale = targetWidth / image!.width;
  double heightScale = targetHeight / image.height;

  // Choose the minimum scale factor to fit the image within the target area
  double minScale = math.min(widthScale, heightScale);

  // Calculate the scaled dimensions
  double scaledWidth = image.width * minScale;
  double scaledHeight = image.height * minScale;

  return Size(scaledWidth, scaledHeight);
}
