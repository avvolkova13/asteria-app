/// Controlled vocabulary for the `input_mode` analytics parameter.
///
/// Shows where the input data for a step came from.
enum InputMode {
  manual('manual'),
  savedProfile('saved_profile'),
  quickAction('quick_action');

  const InputMode(this.value);

  final String value;
}
