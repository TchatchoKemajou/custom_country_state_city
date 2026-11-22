# custom_country_state_city

A new Flutter package to get world's all of Country, State, and City.
And items are also searchable, support country locale(fr & en). 
In addition if city can't be found then user manually write city on dialog window.

## Getting Started add

### Platforms:
This widget has been successfully tested on iOS, Android and Chrome.

## Screenshots

| Outlook | Country Dialog |
|---|---|
| ![Outlook](lib/assets/ex_img/sc_1.jpg) | ![Country Dialog](lib/assets/ex_img/sc_2.jpg) |

| Country Searching | State Dialog |
|---|---|
| ![Country Searching](lib/assets/ex_img/sc_3.jpg) | ![State Dialog](lib/assets/ex_img/sc_4.jpg) |

| City Dialog | Final Data |
|---|---|
| ![City Dialog](lib/assets/ex_img/sc_5.jpg) | ![Final Data](lib/assets/ex_img/sc_6.jpg) |

## Usage
```dart
import 'package:custom_country_state_city/custom_country_state_city.dart';

///Define Controller
TextEditingController country=TextEditingController();
TextEditingController state=TextEditingController();
TextEditingController city=TextEditingController();

///Widget initialize
CustomCountryStateCityPicker(
                country: country,
                state: state,
                city: city,
                dialogColor: Colors.grey.shade200,
                textFieldDecoration: InputDecoration(
                  fillColor: Colors.blueGrey.shade100,
                  filled: true,
                  suffixIcon: const Icon(Icons.arrow_downward_rounded),
                  border: const OutlineInputBorder(borderSide: BorderSide.none))
            ),
```

## Example Code
```dart
import 'package:flutter/material.dart';
import 'package:country_state_city/custom_country_state_city_picker.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country->State->City',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  TextEditingController country=TextEditingController();
  TextEditingController state=TextEditingController();
  TextEditingController city=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country->State->City'),
      ),
      body: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              CustomCountryStateCityPicker(
                  country: country,
                  state: state,
                  city: city,
                  locale: "fr",
                  fieldHintText: const FieldHintText(
                      countryHintText: "Selectionner votre pays",
                      stateHintText: "Selectionner votre région",
                      cityHintText: "Selectionner votre ville"
                  ),
                  dialogTitle: const DialogTitle(
                      countryDialogTitle: "Pays",
                      stateDialogTitle: "Région",
                      cityDialogTitle: "Ville"
                  ),
                  closeTextButton: "Fermer",

                  dialogColor: Colors.grey.shade200,
                  textFieldDecoration: const InputDecoration(
                      fillColor: AppColor.backgroundColor2,
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              color: AppColor.primaryColor
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              color: AppColor.backgroundColor2
                          )
                      ),
                      isDense: true,                      // Added this
                      contentPadding: EdgeInsets.all(10),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ))
              ),
              SizedBox(height: 20),

              Text("${country.text}, ${state.text}, ${city.text}")
            ],
          )
      ),
    );
  }
}
```

## Maintainer

**[Franck Donald Tchatcho Kemajou](https://www.linkedin.com/in/franck-donald/)** — Fondateur [Jov's Inc.](https://inc.jovs.ca/blog)

- 💼 LinkedIn — [linkedin.com/in/franck-donald](https://www.linkedin.com/in/franck-donald/)
- 🐙 GitHub — [@TchatchoKemajou](https://github.com/TchatchoKemajou)
- 🏢 Jov's Inc. — [inc.jovs.ca/blog](https://inc.jovs.ca/blog)
- ✉️ Contact — [empereurfranck95@gmail.com](mailto:empereurfranck95@gmail.com)

Issues et PR bienvenus sur le [repo GitHub](https://github.com/TchatchoKemajou/custom_country_state_city).
