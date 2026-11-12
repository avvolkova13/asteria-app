import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/home/presentation/widgets/profile_avatar.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/material.dart';

import 'avatar_catalog.dart';
import 'avatar_preferences.dart';

String avatarLabel(AppLocalizations strings, String id) => switch (id) {
  'sorceress' => strings.avatarSorceress,
  'sorcerer' => strings.avatarSorcerer,
  'unicorn' => strings.avatarUnicorn,
  'elf_woman' => strings.avatarElfWoman,
  'elf_man' => strings.avatarElfMan,
  'dragon' => strings.avatarDragon,
  'astrologer' => strings.avatarAstrologer,
  'astrologer_woman' => strings.avatarAstrologerWoman,
  _ => strings.avatarPhoenix,
};

class AvatarPickerScreen extends StatefulWidget {
  const AvatarPickerScreen({
    super.key,
    required this.userId,
    this.gender,
    this.preferences,
  });

  final String userId;
  final Gender? gender;
  final AvatarPreferences? preferences;

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> {
  late final AvatarPreferences _preferences;
  late String _draftId;
  bool _saving = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences ?? AvatarPreferences.instance;
    _draftId = _preferences.selectedFor(widget.userId, widget.gender).id;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await _preferences.select(widget.userId, _draftId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: ProfileFlowColors.background,
      body: ProfileFlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: ProfileFlowHeader(
                  title: strings.avatarScreenTitle,
                  canPop: true,
                ),
              ).withEntrance(order: 0),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        children: [
                          Text(
                            strings.avatarChooseTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.h2.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ).withEntrance(order: 1),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, bounds) {
                              final columns = bounds.maxWidth >= 300 ? 3 : 2;
                              final extent =
                                  (bounds.maxWidth - (columns - 1) * 12) /
                                  columns;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 18,
                                children: [
                                  for (
                                    var i = 0;
                                    i < AvatarPreset.values.length;
                                    i++
                                  )
                                    SizedBox(
                                      width: extent,
                                      child: _option(
                                        AvatarPreset.values[i],
                                        extent,
                                        reduceMotion,
                                      ),
                                    ).withEntrance(order: i + 2),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_failed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            strings.avatarSaveError,
                            textAlign: TextAlign.center,
                            style: AppTypography.text1.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: LotusButtons.elevated(
                        onPressed: _saving || widget.userId.isEmpty
                            ? null
                            : _save,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(44, 50),
                        ),
                        child: _saving
                            ? SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  semanticsLabel: strings.avatarSave,
                                ),
                              )
                            : Text(strings.avatarSave),
                      ),
                    ),
                  ],
                ),
              ).withEntrance(order: AvatarPreset.values.length + 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(AvatarPreset preset, double extent, bool reduceMotion) {
    final selected = preset.id == _draftId;
    final label = avatarLabel(context.l10n, preset.id);
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      enabled: !_saving,
      onTap: _saving
          ? null
          : LotusFeedback.action(() => setState(() => _draftId = preset.id)),
      child: ExcludeSemantics(
        child: LotusButtons.text(
          onPressed: _saving
              ? null
              : () => setState(() => _draftId = preset.id),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(3),
            minimumSize: const Size(44, 44),
            foregroundColor: AppColors.textInverse,
          ),
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? ProfileFlowColors.accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ProfileAvatar(
              size: extent - 15,
              presetId: preset.id,
              preferences: _preferences,
            ),
          ),
        ),
      ),
    );
  }
}
