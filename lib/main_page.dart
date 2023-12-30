import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'pages/text_main_page.dart';
import 'pages/image_main_page.dart';

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;
  const MyHomePage({super.key, required this.camera});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  late ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const TextMainPage();
        break;
      case 1:
        page = ImageMainPage(
          camera: widget.camera,
        );
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex!');
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return _buildMobileLayout(mainArea);
          } else {
            return _buildWideLayout(mainArea, constraints);
          }
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      // backgroundColor: colorScheme.surfaceVariant,
      leading: const Icon(Icons.translate),
      title: const Text(
        'Translatify',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMobileLayout(Widget mainArea) {
    return Column(
      children: [
        Expanded(child: mainArea),
        SafeArea(
          child: BottomNavigationBar(
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.description),
                label: 'Text',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_enhance),
                label: 'Image',
              ),
            ],
            // backgroundColor: colorScheme.secondary,
            currentIndex: selectedIndex,
            onTap: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(Widget mainArea, BoxConstraints constraints) {
    return Row(
      children: [
        SafeArea(
          child: NavigationRail(
            extended: constraints.maxWidth >= 600,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.description),
                label: Text('Text'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.camera_enhance),
                label: Text('Image'),
              ),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
        ),
        Expanded(child: mainArea),
      ],
    );
  }
}
