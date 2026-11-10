import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/localization.dart';

abstract class AuthLocalizationContract {
  String personalInfoTitle(BuildContext context);
  String personalInfoSubtitle(BuildContext context);
  String personalInfoDescription(BuildContext context);
  String maleGender(BuildContext context);
  String femaleGender(BuildContext context);
  String birthPlaceLabel(BuildContext context);
  String birthDateLabel(BuildContext context);
  String birthTimeLabel(BuildContext context);
  String exactTimeUnknown(BuildContext context);
  String dayTimeOptionLabel(BuildContext context);
  String nightTimeOptionLabel(BuildContext context);
  String unknownTimeOptionLabel(BuildContext context);
  String birthDatePickerTitle(BuildContext context);
  String birthTimePickerTitle(BuildContext context);
  String nameLabel(BuildContext context);
  String placeLabel(BuildContext context);
  String exactTimeUnknownDescription(BuildContext context);
  String saveButtonText(BuildContext context);
  String saveButtonLoadingText(BuildContext context);
  String genderLabel(BuildContext context, Gender gender);
}

class AuthLocalization implements AuthLocalizationContract {
  @override
  String genderLabel(BuildContext context, Gender gender) =>
      gender == Gender.male
      ? AppLocalizations.of(context).maleGender
      : AppLocalizations.of(context).femaleGender;

  @override
  String saveButtonText(BuildContext context) =>
      AppLocalizations.of(context).next;

  @override
  String saveButtonLoadingText(BuildContext context) =>
      AppLocalizations.of(context).saveButtonLoadingText;

  @override
  String nameLabel(BuildContext context) =>
      AppLocalizations.of(context).nameLabel;

  @override
  String placeLabel(BuildContext context) =>
      AppLocalizations.of(context).placeLabel;

  @override
  String exactTimeUnknownDescription(BuildContext context) =>
      AppLocalizations.of(context).exactTimeUnknownDescription;

  @override
  String birthTimePickerTitle(BuildContext context) =>
      AppLocalizations.of(context).birthTimePickerTitle;

  @override
  String birthDatePickerTitle(BuildContext context) =>
      AppLocalizations.of(context).birthDatePickerTitle;

  @override
  String personalInfoTitle(BuildContext context) =>
      AppLocalizations.of(context).personalInfoTitle;

  @override
  String personalInfoSubtitle(BuildContext context) =>
      AppLocalizations.of(context).personalInfoSubtitle;

  @override
  String personalInfoDescription(BuildContext context) =>
      AppLocalizations.of(context).personalInfoDescription;

  @override
  String maleGender(BuildContext context) =>
      AppLocalizations.of(context).maleGender;

  @override
  String femaleGender(BuildContext context) =>
      AppLocalizations.of(context).femaleGender;

  @override
  String birthPlaceLabel(BuildContext context) =>
      AppLocalizations.of(context).birthPlaceLabel;

  @override
  String birthDateLabel(BuildContext context) =>
      AppLocalizations.of(context).birthDateLabel;

  @override
  String birthTimeLabel(BuildContext context) =>
      AppLocalizations.of(context).birthTimeLabel;

  @override
  String exactTimeUnknown(BuildContext context) =>
      AppLocalizations.of(context).exactTimeUnknown;

  @override
  String dayTimeOptionLabel(BuildContext context) =>
      AppLocalizations.of(context).dayTimeOptionLabel;

  @override
  String nightTimeOptionLabel(BuildContext context) =>
      AppLocalizations.of(context).nightTimeOptionLabel;

  @override
  String unknownTimeOptionLabel(BuildContext context) =>
      AppLocalizations.of(context).unknownTimeOptionLabel;
}
