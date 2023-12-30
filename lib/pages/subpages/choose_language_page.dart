import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/data/models.dart';
import '/data/constants.dart';
import '../../app_state.dart';

enum ChooseLanguagePageType { translateFrom, translateTo }

class ChooseLanguagePage extends StatefulWidget {
  final ChooseLanguagePageType pageType;

  const ChooseLanguagePage({Key? key, required this.pageType})
      : super(key: key);

  @override
  ChooseLanguagePageState createState() => ChooseLanguagePageState();
}

class ChooseLanguagePageState extends State<ChooseLanguagePage> {
  late List<SupportedLanguage> filteredLanguages;
  List<SupportedLanguage> allLanguages = List.from(supportedLanguages);

  final ScrollController _firstController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.pageType == ChooseLanguagePageType.translateFrom) {
      allLanguages.insert(0, detectLanguage);
    }
    filteredLanguages = allLanguages;
  }

  @override
  void dispose() {
    _firstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var languageFrom = appState.languageFrom;
    var languageTo = appState.languageTo;

    String pageTitle;
    SupportedLanguage selectedLanguage;
    switch (widget.pageType) {
      case ChooseLanguagePageType.translateFrom:
        pageTitle = 'Translate From';
        selectedLanguage = languageFrom;
        break;
      case ChooseLanguagePageType.translateTo:
        pageTitle = 'Translate To';
        selectedLanguage = languageTo;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    // Update filteredLanguages based on the search query
                    filteredLanguages = allLanguages
                        .where((language) => language.name
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Search language',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: Text(
                'Selected: ${widget.pageType == ChooseLanguagePageType.translateFrom ? appState.languageFrom.name : appState.languageTo.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _firstController,
                child: ListView.builder(
                  itemCount: filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final language = filteredLanguages[index];
                    final isSelected = language == selectedLanguage;

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : null,
                        borderRadius: BorderRadius.circular(
                          isSelected ? 10.0 : 0.0,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          language.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                        onTap: () {
                          switch (widget.pageType) {
                            case ChooseLanguagePageType.translateFrom:
                              appState.changeLanguageFrom(language);
                              appState.triggerTranslation();
                              break;
                            case ChooseLanguagePageType.translateTo:
                              appState.changeLanguageTo(language);
                              appState.triggerTranslation();
                              break;
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
