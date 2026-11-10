/// Controlled vocabulary shared by `dream_length_band` (sonnik) and
/// `message_length_band` (anakra chat) analytics parameters.
///
/// Client buckets text length BEFORE discarding the text — never send the
/// raw user content.
enum LengthBand {
  short('short'),
  medium('medium'),
  long('long');

  const LengthBand(this.value);

  final String value;

  /// Bucket a raw text length into a controlled band.
  ///
  /// Thresholds (chars):
  ///   - `short`  : < 200
  ///   - `medium` : 200..800
  ///   - `long`   : > 800
  ///
  /// Use this BEFORE discarding the original text so the analytics payload
  /// never carries the raw user content.
  static LengthBand fromText(String text) {
    final length = text.length;
    if (length < 200) return LengthBand.short;
    if (length <= 800) return LengthBand.medium;
    return LengthBand.long;
  }
}
