import 'package:flutter/material.dart';
import '../app_colors/app_colors.dart';
import '../app_typography.dart';
import 'card_lens_decoration.dart';
import 'lotus_feedback.dart';

class SegmentedPicker<T> extends StatelessWidget {
  const SegmentedPicker({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.labelBuilder,
    this.surfaceBrightness,
  });

  final List<T> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final String Function(T) labelBuilder;
  final Brightness? surfaceBrightness;

  static SegmentedPicker<int> indexed({
    required List<String> titles,
    required int selectedIndex,
    required ValueChanged<int> onTabSelected,
    Brightness? surfaceBrightness,
  }) => SegmentedPicker<int>(
    options: List<int>.generate(titles.length, (i) => i),
    selectedValue: selectedIndex,
    labelBuilder: (i) => titles[i],
    onChanged: onTabSelected,
    surfaceBrightness: surfaceBrightness,
  );

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final dark =
        (surfaceBrightness ?? Theme.of(context).brightness) == Brightness.dark;
    final active = options.indexOf(selectedValue);
    final fill = dark ? const Color(0xC92C2338) : const Color(0xE6EEE8F3);
    final lens = dark ? const Color(0xFF55435E) : const Color(0xFFF7F0FA);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: dark ? .33 : .45),
          width: .75,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Stack(
          children: [
            if (active >= 0)
              Positioned.fill(
                child: AnimatedAlign(
                  alignment: AlignmentDirectional(
                    options.length == 1
                        ? 0
                        : 2 * active / (options.length - 1) - 1,
                    0,
                  ),
                  curve: Curves.easeOutCubic,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 210),
                  child: FractionallySizedBox(
                    widthFactor: 1 / options.length,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: CardLensDecoration.button(
                        borderRadius: BorderRadius.circular(19),
                        color: lens,
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                for (final option in options)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: option == selectedValue,
                      inMutuallyExclusiveGroup: true,
                      child: LotusTap(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(option),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 5,
                          ),
                          child: Text(
                            labelBuilder(option),
                            textAlign: TextAlign.center,
                            style:
                                (option == selectedValue
                                        ? AppTypography.text2SemiBold
                                        : AppTypography.text2)
                                    .copyWith(
                                      fontSize: 13,
                                      height: 1.2,
                                      color: dark
                                          ? (option == selectedValue
                                                ? AppColors.textInverse
                                                : const Color(0xFFE0D2E5))
                                          : AppColors.textPrimary,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
