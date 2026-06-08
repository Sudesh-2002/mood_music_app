/// Temporary in-memory holder for registration data
/// between the Register page and Source Selection page.
///
/// Uses a singleton so both pages share the exact same instance —
/// fixing the silent bug where two separate private `_TempRegistration`
/// classes were defined in each file, meaning data written in
/// `register_page.dart` could never be read by `source_selection_page.dart`.
class RegistrationTemp {
  static final RegistrationTemp _instance = RegistrationTemp._();
  factory RegistrationTemp() => _instance;
  RegistrationTemp._();

  String name = '';
  String pin = '';

  void clear() {
    name = '';
    pin = '';
  }
}
