import 'package:flutter/material.dart';
import 'package:custom_country_state_city/custom_country_state_city.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country State City Picker',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final _countryCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  @override
  void dispose() {
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Country / State / City')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomCountryStateCityPicker(
          country: _countryCtrl,
          state: _stateCtrl,
          city: _cityCtrl,
          locale: 'en',
          spacing: 10,
          dialogTitle: const DialogTitle(
            countryDialogTitle: 'Country',
            stateDialogTitle: 'State',
            cityDialogTitle: 'City',
          ),
          fieldHintText: const FieldHintText(
            countryHintText: 'Country',
            stateHintText: 'State',
            cityHintText: 'City',
          ),
          inputSearchHintText: 'Search…',
          closeTextButton: 'Close',
        ),
      ),
    );
  }
}
