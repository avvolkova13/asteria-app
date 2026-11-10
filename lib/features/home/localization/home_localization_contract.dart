import 'package:flutter/material.dart';
import '../../../core/localization/localization.dart';

abstract class HomeLocalizationContract {
  String homeTitle(BuildContext context);
  String helloText(BuildContext context);
  String logoutButton(BuildContext context);
  String logoutError(BuildContext context);
  String userNotFoundError(BuildContext context);
  String loadingDataError(BuildContext context);
}

class HomeLocalization implements HomeLocalizationContract {
  @override
  String homeTitle(BuildContext context) =>
      AppLocalizations.of(context).homeTitle;

  @override
  String helloText(BuildContext context) =>
      AppLocalizations.of(context).helloText;

  @override
  String logoutButton(BuildContext context) =>
      AppLocalizations.of(context).logoutButton;

  @override
  String logoutError(BuildContext context) =>
      AppLocalizations.of(context).logoutError;

  @override
  String userNotFoundError(BuildContext context) =>
      AppLocalizations.of(context).userNotFoundError;

  @override
  String loadingDataError(BuildContext context) =>
      AppLocalizations.of(context).loadingDataError;
}
