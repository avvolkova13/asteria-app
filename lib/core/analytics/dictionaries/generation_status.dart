/// Controlled vocabulary for the `generation_status` analytics parameter.
///
/// Tracks the outcome of an AI / content generation call.
enum GenerationStatus {
  success('success'),
  failed('failed'),
  timeout('timeout'),
  cancelled('cancelled');

  const GenerationStatus(this.value);

  final String value;
}
