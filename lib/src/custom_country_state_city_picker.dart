import 'dart:convert';
import 'package:custom_country_state_city/src/model/dialog_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import './model/city_model.dart';
import './model/country_model.dart';
import './model/state_model.dart';
import 'model/field_hint_text.dart';

/// A stacked picker to select a country, then its state/region, then its city
/// from strict dropdowns backed by local JSON data (246 countries, 48k+ cities).
///
/// Each field opens a themed dialog with a search bar and emits the selected
/// item through the matching callback. The resolved labels are written to the
/// three [TextEditingController]s so the caller can read, pre-fill or clear
/// them at any time.
///
/// Example:
/// ```dart
/// CustomCountryStateCityPicker(
///   country: countryCtrl,
///   state: stateCtrl,
///   city: cityCtrl,
///   locale: 'en',
///   onCountryChanged: (c) => print(c.sortName),
/// )
/// ```
class CustomCountryStateCityPicker extends StatefulWidget {
  /// Called when the user picks a country in the dialog.
  final ValueChanged<CountryModel>? onCountryChanged;

  /// Called when the user picks a state/region in the dialog.
  final ValueChanged<StateModel>? onStateChanged;

  /// Called when the user picks a city in the dialog.
  final ValueChanged<CityModel>? onCityChanged;

  /// Controller for the country field. Also used to pre-fill the country.
  final TextEditingController country;

  /// Controller for the state/region field. Also used to pre-fill the state.
  final TextEditingController state;

  /// Controller for the city field. Also used to pre-fill the city.
  final TextEditingController city;

  /// Language of the country labels loaded from the bundled JSON assets.
  /// Supported values: `'en'`, `'fr'`. Defaults to `'en'` when `null`.
  final String? locale;

  /// Custom [InputDecoration] applied to the three text fields.
  final InputDecoration? textFieldDecoration;

  /// Background color of the selection dialog. When `null`, the dialog uses
  /// `Theme.of(context).dialogTheme.backgroundColor`.
  final Color? dialogColor;

  /// Vertical spacing between the country, state and city fields.
  final double? spacing;

  /// Text style applied to the three text fields.
  final TextStyle? inputStyle;

  /// Hint texts displayed in the country/state/city fields.
  final FieldHintText? fieldHintText;

  /// Titles displayed at the top of the country/state/city dialogs.
  final DialogTitle? dialogTitle;

  /// Snackbar message shown when the user taps the state field without first
  /// picking a country.
  final String? validateCountrySnackBarMessage;

  /// Snackbar message shown when the user taps the city field without first
  /// picking a state.
  final String? validateStateSnackBarMessage;

  /// Label of the dialog close button. Defaults to `"Close"`.
  final String? closeTextButton;

  /// Custom [ButtonStyle] for the dialog close button.
  final ButtonStyle? closeButtonStyle;

  /// Hint text of the in-dialog search field. Defaults to `"Search"`.
  final String? inputSearchHintText;

  /// Text style of the in-dialog search field.
  final TextStyle? inputSearchTextStyle;

  /// Custom [InputDecoration] for the in-dialog search field.
  final InputDecoration? inputSearchDecoration;

  /// Padding around the in-dialog search field.
  final EdgeInsetsGeometry? inputSearchPadding;


  const CustomCountryStateCityPicker(
      {super.key,
        required this.country,
        required this.state,
        required this.city,
        this.textFieldDecoration,
        this.dialogColor,
        this.spacing,
        this.fieldHintText,
        this.dialogTitle,
        this.validateCountrySnackBarMessage,
        this.validateStateSnackBarMessage,
        this.closeTextButton,
        this.closeButtonStyle, this.inputSearchHintText,
        this.inputSearchDecoration, this.inputSearchPadding,
        this.inputStyle, this.inputSearchTextStyle,
        this.locale, this.onCountryChanged,
        this.onStateChanged, this.onCityChanged
      });

  @override
  State<CustomCountryStateCityPicker> createState() => _CustomCountryStateCityPickerState();
}

class _CustomCountryStateCityPickerState extends State<CustomCountryStateCityPicker> {
  List<CountryModel> _countryList = [];
  final List<StateModel> _stateList = [];
  final List<CityModel> _cityList = [];

  List<CountryModel> _countrySubList = [];
  List<StateModel> _stateSubList = [];
  List<CityModel> _citySubList = [];
  String _title = '';
  String searchKey = '';
  FieldHintText defaultHintText = const FieldHintText();
  DialogTitle defaultDialogTitle = const DialogTitle();

  @override
  void initState() {
    _getCountry();
    super.initState();
  }

  Future<void> _getCountry() async {

    _countryList.clear();
    var jsonString = await rootBundle
        .loadString('packages/custom_country_state_city/assets/${widget.locale ?? 'en' }/country.json');
    List<dynamic> body = json.decode(jsonString);
    setState(() {
      _countryList =
          body.map((dynamic item) => CountryModel.fromJson(item)).toList();
      _countrySubList = _countryList;
    });
    // Fix 2026-11-14 : si le picker est monté avec country.text déjà pré-rempli
    // (mode édition), on hydrate la liste des régions tout de suite — sinon le
    // user doit re-cliquer le dropdown Pays pour que la cascade se déclenche.
    final prefilledCountryName = widget.country.text.trim();
    if (prefilledCountryName.isNotEmpty) {
      final match = _countryList.firstWhere(
        (c) => c.name.toLowerCase() == prefilledCountryName.toLowerCase(),
        orElse: () => CountryModel(id: '', sortName: '', name: '', phoneCode: ''),
      );
      if (match.id.isNotEmpty) {
        await _getState(match.id);
        // Si on a aussi state.text pré-rempli, hydrate la liste des villes.
        final prefilledStateName = widget.state.text.trim();
        if (prefilledStateName.isNotEmpty) {
          final stateMatch = _stateList.firstWhere(
            (s) => s.name.toLowerCase() == prefilledStateName.toLowerCase(),
            orElse: () => StateModel(id: '', countryId: '', name: ''),
          );
          if (stateMatch.id.isNotEmpty) {
            await _getCity(stateMatch.id);
          }
        }
      }
    }
  }

  Future<void> _getState(String countryId) async {
    _stateList.clear();
    _cityList.clear();
    List<StateModel> subStateList = [];
    var jsonString = await rootBundle
        .loadString('packages/custom_country_state_city/assets/en/state.json');
    List<dynamic> body = json.decode(jsonString);

    subStateList =
        body.map((dynamic item) => StateModel.fromJson(item)).toList();
    for (var element in subStateList) {
      if (element.countryId == countryId) {
        setState(() {
          _stateList.add(element);
        });
      }
    }
    _stateSubList = _stateList;
  }

  Future<void> _getCity(String stateId) async {
    _cityList.clear();
    List<CityModel> subCityList = [];
    var jsonString = await rootBundle
        .loadString('packages/custom_country_state_city/assets/en/city.json');
    List<dynamic> body = json.decode(jsonString);

    subCityList = body.map((dynamic item) => CityModel.fromJson(item)).toList();
    for (var element in subCityList) {
      if (element.stateId == stateId) {
        setState(() {
          _cityList.add(element);
        });
      }
    }
    _citySubList = _cityList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ///Country TextField
        TextField(
          controller: widget.country,
          style: widget.inputStyle,
          onTap: () {
            setState(() {
              searchKey = 'Country';
              _title = widget.dialogTitle != null
                  ? widget.dialogTitle!.countryDialogTitle
                  : defaultDialogTitle.countryDialogTitle;
            });
            _showDialog(context);
          },
          decoration: widget.textFieldDecoration == null
              ? defaultDecoration.copyWith(hintText: widget.fieldHintText != null
              ? widget.fieldHintText!.countryHintText
              : defaultHintText.countryHintText)
              : widget.textFieldDecoration
              ?.copyWith(hintText: widget.fieldHintText != null
              ? widget.fieldHintText!.countryHintText
              : defaultHintText.countryHintText),
          readOnly: true,
        ),
        SizedBox(height: widget.spacing?? 10.0),

        ///State TextField
        TextField(
          controller: widget.state,
          style: widget.inputStyle,
          onTap: () {
            setState(() {
              searchKey = 'State';
              _title = widget.dialogTitle != null
                  ? widget.dialogTitle!.stateDialogTitle
                  : defaultDialogTitle.stateDialogTitle;
            });
            if (widget.country.text.isNotEmpty) {
              _showDialog(context);
            } else {
              _showSnackBar(widget.validateCountrySnackBarMessage ?? 'Select Country');
            }
          },
          decoration: widget.textFieldDecoration == null
              ? defaultDecoration.copyWith(hintText: widget.fieldHintText != null
              ? widget.fieldHintText!.stateHintText
              : defaultHintText.stateHintText)
              : widget.textFieldDecoration?.copyWith(hintText: widget.fieldHintText != null
              ? widget.fieldHintText!.stateHintText
              : defaultHintText.stateHintText),
          readOnly: true,
        ),
        SizedBox(height: widget.spacing?? 10.0),

        ///City TextField
        TextField(
          controller: widget.city,
          style: widget.inputStyle,
          onTap: () {
            setState(() {
              searchKey = 'City';
              _title = widget.dialogTitle != null
                  ? widget.dialogTitle!.cityDialogTitle
                  : defaultDialogTitle.cityDialogTitle;
            });
            if (widget.state.text.isNotEmpty) {
              _showDialog(context);
            } else {
              _showSnackBar(widget.validateStateSnackBarMessage ?? 'Select State');
            }
          },
          decoration: widget.textFieldDecoration == null
              ? defaultDecoration.copyWith(hintText: widget.fieldHintText != null
              ? widget.fieldHintText!.cityHintText
              : defaultHintText.cityHintText)
              : widget.textFieldDecoration?.copyWith(hintText: widget.fieldHintText != null
              ? widget.fieldHintText!.cityHintText
              : defaultHintText.cityHintText),
          readOnly: true,
        ),
      ],
    );
  }

  // Convert ISO-3166 alpha-2 country code to emoji flag (CM → 🇨🇲).
  // Works everywhere Unicode region indicator pairs are rendered.
  String _flagEmoji(String? isoCode) {
    if (isoCode == null || isoCode.length != 2) return '';
    final up = isoCode.toUpperCase();
    final a = up.codeUnitAt(0);
    final b = up.codeUnitAt(1);
    if (a < 0x41 || a > 0x5A || b < 0x41 || b > 0x5A) return '';
    return String.fromCharCodes([0x1F1E6 + a - 0x41, 0x1F1E6 + b - 0x41]);
  }

  void _showDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final TextEditingController controller2 = TextEditingController();
    final TextEditingController controller3 = TextEditingController();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showGeneralDialog(
      barrierLabel: _title,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 350),
      context: context,
      pageBuilder: (context, __, ___) {
        return Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Get currently selected value for this picker (highlight row).
              final String currentValue = searchKey == 'Country'
                  ? widget.country.text
                  : searchKey == 'State'
                      ? widget.state.text
                      : widget.city.text;

              return Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * .7,
                  margin: const EdgeInsets.only(top: 60, left: 12, right: 12),
                  decoration: BoxDecoration(
                    // Respect app theme: use dialogColor override if provided,
                    // else the theme's dialog surface (dark-mode aware).
                    color: widget.dialogColor ?? theme.dialogTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Drag handle for bottom-sheet feel
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: scheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(_title,
                          style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),

                      ///Text Field
                      Padding(
                        padding: widget.inputSearchPadding ??
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: searchKey == 'Country'
                              ? controller
                              : searchKey == 'State'
                                  ? controller2
                                  : controller3,
                          onChanged: (val) {
                            setState(() {
                              if (searchKey == 'Country') {
                                _countrySubList = _countryList
                                    .where((element) => element.name
                                        .toLowerCase()
                                        .contains(controller.text.toLowerCase()))
                                    .toList();
                              } else if (searchKey == 'State') {
                                _stateSubList = _stateList
                                    .where((element) => element.name
                                        .toLowerCase()
                                        .contains(controller2.text.toLowerCase()))
                                    .toList();
                              } else if (searchKey == 'City') {
                                _citySubList = _cityList
                                    .where((element) => element.name
                                        .toLowerCase()
                                        .contains(controller3.text.toLowerCase()))
                                    .toList();
                              }
                            });
                          },
                          style: widget.inputSearchTextStyle ??
                              TextStyle(color: scheme.onSurface, fontSize: 15.0),
                          decoration: widget.inputSearchDecoration ??
                              InputDecoration(
                                filled: true,
                                fillColor: scheme.onSurface.withValues(alpha: 0.04),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: scheme.primary, width: 1.2),
                                ),
                                hintText: widget.inputSearchHintText ?? 'Search here...',
                                hintStyle: TextStyle(
                                  color: scheme.onSurface.withValues(alpha: 0.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                isDense: true,
                                prefixIcon: Icon(Icons.search,
                                    color: scheme.onSurface.withValues(alpha: 0.6)),
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      ///Dropdown Items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemCount: searchKey == 'Country'
                              ? _countrySubList.length
                              : searchKey == 'State'
                                  ? _stateSubList.length
                                  : _citySubList.length,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final String itemName = searchKey == 'Country'
                                ? _countrySubList[index].name
                                : searchKey == 'State'
                                    ? _stateSubList[index].name
                                    : _citySubList[index].name;
                            final String? isoCode = searchKey == 'Country'
                                ? _countrySubList[index].sortName
                                : null;
                            final bool isSelected = itemName == currentValue &&
                                currentValue.isNotEmpty;

                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () async {
                                setState(() {
                                  if (searchKey == 'Country') {
                                    widget.country.text = _countrySubList[index].name;
                                    if (widget.onCountryChanged != null) {
                                      widget.onCountryChanged!(_countrySubList[index]);
                                    }
                                    _getState(_countrySubList[index].id);
                                    _countrySubList = _countryList;
                                    widget.state.clear();
                                    widget.city.clear();
                                  } else if (searchKey == 'State') {
                                    widget.state.text = _stateSubList[index].name;
                                    if (widget.onStateChanged != null) {
                                      widget.onStateChanged!(_stateSubList[index]);
                                    }
                                    _getCity(_stateSubList[index].id);
                                    _stateSubList = _stateList;
                                    widget.city.clear();
                                  } else if (searchKey == 'City') {
                                    widget.city.text = _citySubList[index].name;
                                    if (widget.onCityChanged != null) {
                                      widget.onCityChanged!(_citySubList[index]);
                                    }
                                    _citySubList = _cityList;
                                  }
                                });
                                controller.clear();
                                controller2.clear();
                                controller3.clear();
                                Navigator.pop(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? scheme.primary.withValues(alpha: 0.10)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    if (isoCode != null) ...[
                                      Text(_flagEmoji(isoCode),
                                          style: const TextStyle(fontSize: 20)),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Text(itemName,
                                          style: TextStyle(
                                              color: isSelected
                                                  ? scheme.primary
                                                  : scheme.onSurface,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              fontSize: 16.0)),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_rounded,
                                          color: scheme.primary, size: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: widget.closeButtonStyle ??
                                OutlinedButton.styleFrom(
                                  foregroundColor: scheme.primary,
                                  side: BorderSide(color: scheme.primary.withValues(alpha: 0.6)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                            onPressed: () {
                              if (searchKey == 'City' && _citySubList.isEmpty) {
                                widget.city.text = controller3.text;
                              }
                              _countrySubList = _countryList;
                              _stateSubList = _stateList;
                              _citySubList = _cityList;

                              controller.clear();
                              controller2.clear();
                              controller3.clear();
                              Navigator.pop(context);
                            },
                            child: Text(widget.closeTextButton ?? 'Close'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
              .animate(anim),
          child: child,
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16.0))));
  }

  InputDecoration defaultDecoration = const InputDecoration(
      isDense: true,
      hintText: 'Select',
      suffixIcon: Icon(Icons.arrow_drop_down),
      border: OutlineInputBorder());
}
