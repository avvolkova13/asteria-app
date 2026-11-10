import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class AdvicesWidget extends StatefulWidget {
  final List<String> advices;
  const AdvicesWidget({Key? key, required this.advices}) : super(key: key);

  @override
  _AdvicesWidgetState createState() => _AdvicesWidgetState();
}

class _AdvicesWidgetState extends State<AdvicesWidget> {
  int selectedAdviceIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.l10n.horoscopeAdvice,
            style: context.textTheme.playfairSemiBold24,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.advices.asMap().entries.map((entry) {
            final advice = entry.value;
            return _AdviceChip(text: advice);
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _AdviceChip extends StatelessWidget {
  final String text;

  const _AdviceChip({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: context.textTheme.inverseUrbanistSemiBold16),
    );
  }
}
