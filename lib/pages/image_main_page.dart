import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '/app_state.dart';

class ImageMainPage extends StatefulWidget {
  const ImageMainPage({super.key});

  @override
  State<ImageMainPage> createState() => _ImageMainPageState();
}

class _ImageMainPageState extends State<ImageMainPage> {
  XFile? _mediaFile;
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );
      setState(() {
        if (pickedFile != null) _setImageFileListFromFile(pickedFile);
        _pickImageError = null;
      });
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
  }

  void _setImageFileListFromFile(XFile? value) {
    _mediaFile = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pickImageError != null
            ? Text(
                'Error: $_pickImageError',
                textAlign: TextAlign.center,
              )
            : _mediaFile != null
                ? Image.file(
                    File(_mediaFile!.path),
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return const Center(
                        child: Text('This image type is not supported'),
                      );
                    },
                  )
                : const Text(
                    'You have not picked an image.',
                    textAlign: TextAlign.center,
                  ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery);
            },
            heroTag: 'image0',
            tooltip: 'Pick an image from gallery',
            child: const Icon(Icons.photo),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: () {
              _onImageButtonPressed(ImageSource.camera);
            },
            heroTag: 'image2',
            tooltip: 'Take a photo',
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
