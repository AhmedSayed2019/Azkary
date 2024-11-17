class SettingsModel {
  int _counter, _diacritics, _sanad, _fontFamily;
  double _fontSize;

  factory SettingsModel.fromMap(Map<String, dynamic> map) =>
      SettingsModel(counter:  map['counter']??0,
          diacritics: map['diacritics']??0,
          sanad: map['sanad']??0,
          fontFamily: map['font_family']??0,
          fontSize: map['font_size']??0);
    //
    //   _counter = map['counter'];
    // _diacritics = map['diacritics'];
    // _sanad = map['sanad'];
    // _fontFamily = map['font_family'];
    // _fontSize = map['font_size'];

  SettingsModel({
    required int counter,
    required int diacritics,
    required int sanad,
    required int fontFamily,
    required double fontSize,
  })
      : _counter = counter,
        _diacritics = diacritics,
        _sanad = sanad,
        _fontFamily = fontFamily,
        _fontSize = fontSize;



  void setCounter(int value) {
    _counter = value;
  }

  void setDiacritics(int value) {
    _diacritics = value;
  }

  void setSanad(int value) {
    _sanad = value;
  }

  void setFontFamily(int value) {
    _fontFamily = value;
  }

  void setFontSize(double value) {
    _fontSize = value;
  }

  int get counter => _counter;

  int get diacritics => _diacritics;

  int get sanad => _sanad;

  int get fontFamily => _fontFamily;

  double get fontSize => _fontSize;
}
