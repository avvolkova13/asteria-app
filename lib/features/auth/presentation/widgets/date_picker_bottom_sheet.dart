import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DateTimePickerBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final String title;
  final CupertinoDatePickerMode mode;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final bool use24hFormat;

  const DateTimePickerBottomSheet({
    super.key,
    this.initialDate,
    this.minimumDate,
    this.maximumDate,
    required this.title,
    required this.mode,
    required this.onDateChanged,
    this.onTimeChanged,
    this.use24hFormat = false,
  });

  @override
  State<DateTimePickerBottomSheet> createState() =>
      _DateTimePickerBottomSheetState();
}

class _DateTimePickerBottomSheetState extends State<DateTimePickerBottomSheet> {
  late DateTime selectedDate;

  bool get _isTimeMode => widget.mode == CupertinoDatePickerMode.time;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ModalGlassSurface(
        color: ModalGlassTokens.surface,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            primary: false,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: AsteriaEntrance.sections([
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ModalGlassTokens.grabber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Semantics(
                  namesRoute: true,
                  header: true,
                  child: Text(
                    widget.title,
                    style: AppTypography.h3.copyWith(
                      color: ModalGlassTokens.text,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(builder: _buildWheel),
                const SizedBox(height: 16),
                LayoutBuilder(builder: _buildActions),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWheel(BuildContext context, BoxConstraints constraints) {
    final scaler = MediaQuery.textScalerOf(context);
    // Cupertino's wheel does not scale its text. Allow larger
    // values while reserving width for long localized months.
    final maxSize = (constraints.maxWidth / 12).clamp(20.0, 32.0);
    final fontSize = scaler.scale(21).clamp(20.0, maxSize);
    final rowHeight = fontSize * 1.8;
    return SizedBox(
      height: rowHeight * 5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Container(
              height: rowHeight,
              decoration: CardLensDecoration(
                color: AppColors.primary.withValues(alpha: .23),
                borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
                intensity: .36,
              ),
            ),
          ),
          CupertinoTheme(
            data: CupertinoThemeData(
              brightness: Brightness.dark,
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: AppTypography.text1.copyWith(
                  color: ModalGlassTokens.text,
                  fontSize: fontSize,
                  letterSpacing: 0,
                ),
              ),
            ),
            child: CupertinoDatePicker(
              mode: widget.mode,
              initialDateTime: selectedDate,
              minimumDate: widget.minimumDate,
              maximumDate: widget.maximumDate,
              use24hFormat: widget.use24hFormat,
              itemExtent: rowHeight,
              backgroundColor: Colors.transparent,
              // Draw one continuous cushion behind all columns.
              selectionOverlayBuilder:
                  (_, {required selectedIndex, required columnCount}) => null,
              onDateTimeChanged: (date) => selectedDate = date,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, BoxConstraints constraints) {
    final scaler = MediaQuery.textScalerOf(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
    );
    final style = TextButton.styleFrom(
      foregroundColor: ModalGlassTokens.text,
      textStyle: AppTypography.text1SemiBold,
      minimumSize: const Size(44, 48),
      visualDensity: VisualDensity.standard,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: shape,
    );
    final cancel = LotusButtons.outlined(
      onPressed: () => Navigator.pop(context),
      style: style.copyWith(
        side: WidgetStatePropertyAll(
          BorderSide(color: AppColors.uiDisabled.withValues(alpha: .4)),
        ),
      ),
      child: Text(context.l10n.commonCancel),
    );
    final select = LotusButtons.elevated(
      onPressed: _handleConfirm,
      style: style.copyWith(
        backgroundColor: const WidgetStatePropertyAll(AppColors.uiPressed),
        elevation: const WidgetStatePropertyAll(0),
      ),
      child: Text(context.l10n.commonSelect),
    );
    if (constraints.maxWidth < scaler.scale(190)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [cancel, const SizedBox(height: 8), select],
      );
    }
    return Row(
      children: [
        Expanded(child: cancel),
        const SizedBox(width: 12),
        Expanded(child: select),
      ],
    );
  }

  void _handleConfirm() {
    if (_isTimeMode && widget.onTimeChanged != null) {
      widget.onTimeChanged!(
        TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute),
      );
    } else {
      widget.onDateChanged(selectedDate);
    }
    Navigator.pop(context);
  }
}
