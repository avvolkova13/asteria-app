import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
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
  final bool useAuthStyle;

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
    this.useAuthStyle = false,
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
    if (!widget.useAuthStyle) {
      return _buildLightSheet(context);
    }

    final sheetHeight = _isTimeMode ? 402.0 : 435.0;
    final pickerHeight = _isTimeMode ? 182.0 : 216.0;

    return SizedBox(
      height: sheetHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF31296D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: context.textTheme.inversePlayfairMedium20.copyWith(
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: pickerHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IgnorePointer(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF21183D,
                            ).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      CupertinoTheme(
                        data: const CupertinoThemeData(
                          brightness: Brightness.dark,
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                              color: AppColors.white,
                              fontFamily: AppTypography.bodyFamily,
                              fontSize: 22,
                              height: 1.27,
                              letterSpacing: 0.35,
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: widget.mode,
                          initialDateTime: widget.initialDate ?? DateTime.now(),
                          minimumDate: widget.minimumDate,
                          maximumDate: widget.maximumDate,
                          use24hFormat: widget.use24hFormat,
                          backgroundColor: Colors.transparent,
                          onDateTimeChanged: (DateTime date) {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _SheetOutlineButton(
                        text: context.l10n.commonCancel,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AuthGradientButton(
                        text: context.l10n.commonSelect,
                        onPressed: _handleConfirm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLightSheet(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 4,
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.uiDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              widget.title,
              style: context.textTheme.playfairSemiBold24.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CupertinoDatePicker(
                mode: widget.mode,
                initialDateTime: widget.initialDate ?? DateTime.now(),
                minimumDate: widget.minimumDate,
                maximumDate: widget.maximumDate,
                use24hFormat: widget.use24hFormat,
                onDateTimeChanged: (DateTime date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () => Navigator.pop(context),
                      text: context.l10n.commonCancel,
                      isFullWidth: true,
                      type: CustomButtonType.outline,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      onPressed: _handleConfirm,
                      text: context.l10n.commonSelect,
                      isFullWidth: true,
                      type: CustomButtonType.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

class _SheetOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SheetOutlineButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6E4BFF)),
        ),
        child: Material(
          color: Colors.transparent,
          child: LotusInkTap(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Center(
              child: Text(
                text,
                style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
                  color: const Color(0xFF6E4BFF),
                  height: 1.2,
                  letterSpacing: -0.408,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
