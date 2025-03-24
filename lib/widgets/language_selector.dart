import 'package:flutter/material.dart';

class LanguageSelector extends StatefulWidget {
  final Function(String) onSelect;
  final String defaultLanguage;

  const LanguageSelector({
    super.key,
    required this.onSelect,
    this.defaultLanguage = "tagalog",
  });

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late String selectedLanguage;
  final List<Map<String, String>> languages = [
    {"id": "tagalog", "name": "Tagalog"},
    {"id": "cebuano", "name": "Cebuano"},
    {"id": "ilonggo", "name": "Ilonggo"},
  ];

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.defaultLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedLanguage,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: languages.map((language) {
        return DropdownMenuItem<String>(
            value: language["id"],
            child: Text(
              language["name"]!,
              style: const TextStyle(
                fontSize: 16,
              ),
            ));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedLanguage = value;
          });
          widget.onSelect(value);
        }
      },
    );
  }
}
