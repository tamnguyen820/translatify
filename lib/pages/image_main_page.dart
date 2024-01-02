import 'package:aws_rekognition_api/rekognition-2016-06-27.dart' as rek;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '/app_state.dart';
import '/widgets/rectangle_text_painter.dart';

class ImageMainPage extends StatefulWidget {
  const ImageMainPage({super.key});

  @override
  State<ImageMainPage> createState() => _ImageMainPageState();
}

class _ImageMainPageState extends State<ImageMainPage> {
  final ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;
  Uint8List? imageInBytes;
  List<rek.TextDetection>? textDetections;
  List<rek.TextDetection>? translatedDetections;
  String concatSourceText = '';
  final _renderText = ValueNotifier<bool>(true);
  final _translationLoaded = ValueNotifier<bool>(false);

  Future<void> _onImageButtonPressed(
      ImageSource source, AppState appState) async {
    try {
      // Pick image from Gallery/Camera
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );
      setState(() {
        _pickImageError = null;
        imageInBytes = null;
        textDetections = null;
      });
      if (pickedFile == null) return;

      // Converts image to bytes
      var imageBytes = await _convertImageToBytes(pickedFile);
      // Set image file and image bytes
      setState(() {
        imageInBytes = imageBytes;
      });

      final textDetectionList = await appState.detectTextInImage(imageInBytes!);
      setState(() {
        textDetections = textDetectionList;
        _translationLoaded.value = false;
      });

      String concatText = '';
      for (var textDetection in textDetectionList!) {
        concatText += "${textDetection.detectedText}\n";
      }
      setState(() {
        concatSourceText = concatText;
      });
      final translatedTextList = await appState.translateImageDetections(
        textDetectionList,
        concatSourceText,
      );
      setState(() {
        translatedDetections = translatedTextList;
        _translationLoaded.value = true;
      });
      return;
    } on PlatformException catch (e) {
      setState(() {
        _pickImageError = e.code;
        if (e.message != null && e.message!.isNotEmpty) {
          _pickImageError = e.message;
        }
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
    imageInBytes = null;
    textDetections = null;
    translatedDetections = null;
    concatSourceText = '';
    _translationLoaded.value = false;
  }

  Future<Uint8List?> _convertImageToBytes(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      return bytes;
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    // Limit image/canvas size
    Size contextSize = MediaQuery.of(context).size;
    double width = contextSize.width;
    double height = contextSize.height;
    final padding = MediaQuery.of(context).viewPadding;
    height = (height - padding.top - padding.bottom - kToolbarHeight) * 0.65;

    return Scaffold(
      body: Center(
        child: _pickImageError != null
            ? Text(
                'Error: $_pickImageError',
                textAlign: TextAlign.center,
              )
            : imageInBytes == null
                ? const Text(
                    'You have not picked an image.',
                    textAlign: TextAlign.center,
                  )
                : Stack(
                    children: [
                      Image.memory(
                        imageInBytes!,
                        width: width,
                        height: height,
                      ),
                      textDetections == null
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                value: null,
                                semanticsLabel: 'Analyzing image...',
                                strokeWidth: 8,
                              ),
                            )
                          : CustomPaint(
                              painter: RectangleTextPainter(
                                  textDetections:
                                      translatedDetections ?? textDetections,
                                  renderText: _renderText,
                                  translationLoaded: _translationLoaded),
                              size: Size(width, height),
                            ),
                    ],
                  ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Switch(
                  value: _renderText.value,
                  onChanged: (bool val) {
                    setState(() {
                      _renderText.value = val;
                    });
                  },
                ),
                const Text(
                  'Translate text',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Row(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    _onImageButtonPressed(ImageSource.gallery, appState);
                  },
                  heroTag: 'image0',
                  tooltip: 'Pick an image from gallery',
                  child: const Icon(Icons.photo),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: () {
                    _onImageButtonPressed(ImageSource.camera, appState);
                  },
                  heroTag: 'image2',
                  tooltip: 'Take a photo',
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
