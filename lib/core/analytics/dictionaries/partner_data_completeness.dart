/// Controlled vocabulary for the `partner_data_completeness` analytics
/// parameter (used by compatibility flow).
///
/// Never send partner name / DOB / place themselves.
enum PartnerDataCompleteness {
  partial('partial'),
  complete('complete');

  const PartnerDataCompleteness(this.value);

  final String value;
}
