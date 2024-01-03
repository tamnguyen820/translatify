import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'data/constants.dart';
import 'pages/text_main_page.dart';
import 'pages/image_main_page.dart';
import 'pages/subpages/choose_language_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  late ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    var appState = context.watch<AppState>();
    var languageFrom = appState.languageFrom;
    var languageTo = appState.languageTo;
    var translatedText = appState.translatedText;

    var disableSwapButton = languageFrom == detectLanguage;
    IconData swapIcon;
    if (disableSwapButton) {
      swapIcon = Icons.arrow_right_alt;
    } else {
      swapIcon = Icons.swap_horiz;
    }

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const TextMainPage();
        break;
      case 1:
        page = const ImageMainPage();
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
          return _buildBody(mainArea);
        },
      ),
      bottomNavigationBar: _buildBottomNav(appState),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FloatingActionButton(
                heroTag: 'sourceLanguage',
                mini: true,
                onPressed: () {
                  navigateToChooseLanguagePage(
                    context,
                    ChooseLanguagePageType.translateFrom,
                    [ParentPage.text, ParentPage.image][selectedIndex],
                  );
                },
                tooltip: 'Pick source language',
                child: Text(
                  languageFrom.name,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            IconButton(
              onPressed: !disableSwapButton
                  ? () {
                      appState.swapLanguageFromAndTo();
                      if (selectedIndex == 0) {
                        appState.swapVoiceId();
                        appState.swapPrevTTSInfo();
                        appState.updateSourceText(translatedText);
                        appState.triggerTranslation();
                      }
                      if (selectedIndex == 1) {
                        appState.translateImageDetections();
                      }
                    }
                  : null,
              icon: Icon(swapIcon),
              tooltip: 'Swap',
            ),
            Expanded(
              child: FloatingActionButton(
                heroTag: 'targetLanguage',
                mini: true,
                onPressed: () {
                  navigateToChooseLanguagePage(
                    context,
                    ChooseLanguagePageType.translateTo,
                    [ParentPage.text, ParentPage.image][selectedIndex],
                  );
                },
                tooltip: 'Pick target language',
                child: Text(
                  languageTo.name,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildBody(Widget mainArea) {
    return Column(
      children: [
        Expanded(child: mainArea),
      ],
    );
  }

  Widget _buildBottomNav(AppState appState) {
    return SafeArea(
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
          appState.clearStateWhenNavigate();
          if (value == 0) {
            // Text main page
            appState.initializeTtsVoiceIds();
          }
        },
      ),
    );
  }

  void navigateToChooseLanguagePage(
    BuildContext context,
    ChooseLanguagePageType pageType,
    ParentPage parentPage,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseLanguagePage(
          pageType: pageType,
          parentPage: parentPage,
        ),
      ),
    );
  }
}
