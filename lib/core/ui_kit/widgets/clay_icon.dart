import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _artDirectory = 'assets/icons/clay/';

/// A familiar platform glyph with the rounded lighting of the practice player.
/// Keeping the Icon contract preserves theme sizing, direction and semantics.
class ClayIcon extends Icon {
  const ClayIcon(
    super.icon, {
    super.key,
    super.size,
    super.color,
    super.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final name = _glyphNames[icon];
    if (name == null) return super.build(context);
    final theme = IconTheme.of(context);
    final baseSize = size ?? theme.size ?? 24;
    final dimension = theme.applyTextScaling == true
        ? MediaQuery.textScalerOf(context).scale(baseSize)
        : baseSize;
    final ink = color ?? theme.color ?? Colors.white;
    final opacity = theme.opacity ?? 1;
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        '$_artDirectory$name.webp',
        width: dimension,
        height: dimension,
        color: opacity == 1 ? ink : ink.withValues(alpha: ink.a * opacity),
        colorBlendMode: BlendMode.modulate,
        matchTextDirection: icon?.matchTextDirection ?? false,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// Retains the source vector for new/unmapped assets. Registered pictograms
/// have a high-density clay rendering, with their original SVG layout bounds.
class ClayAssetIcon extends SvgPicture {
  ClayAssetIcon(
    this.assetName, {
    super.key,
    super.width,
    super.height,
    super.fit,
    super.alignment,
    super.excludeFromSemantics,
    super.semanticsLabel,
    this.tint,
  }) : super.asset(
         assetName,
         colorFilter: tint == null
             ? null
             : ColorFilter.mode(tint, BlendMode.srcIn),
       );

  final String assetName;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final nativeSize = _vectorSizes[assetName];
    if (nativeSize == null) return super.build(context);
    final name = assetName.substring(
      assetName.lastIndexOf('/') + 1,
      assetName.length - 4,
    );
    final ratio = nativeSize.aspectRatio;
    return Image.asset(
      '$_artDirectory$name.webp',
      width: width ?? (height == null ? nativeSize.width : height! * ratio),
      height: height ?? (width == null ? nativeSize.height : width! / ratio),
      color: tint,
      colorBlendMode: BlendMode.modulate,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Visual feedback for an enabled action. The enclosing button remains the
/// sole gesture recognizer and keeps its original hit and semantics bounds.
class ClayPressFeedback extends StatefulWidget {
  const ClayPressFeedback({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<ClayPressFeedback> createState() => _ClayPressFeedbackState();
}

class _ClayPressFeedbackState extends State<ClayPressFeedback> {
  int? _pointer;
  Offset _origin = Offset.zero;

  void _finish(int pointer) {
    if (_pointer == pointer) setState(() => _pointer = null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _pointer = null;
  }

  @override
  void didUpdateWidget(ClayPressFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _pointer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    final pressed = _pointer != null;
    return Listener(
      onPointerDown: (event) {
        if (_pointer != null) return;
        _origin = event.position;
        setState(() => _pointer = event.pointer);
      },
      onPointerMove: (event) {
        if ((event.position - _origin).distance > kTouchSlop) {
          _finish(event.pointer);
        }
      },
      onPointerCancel: (event) => _finish(event.pointer),
      onPointerUp: (event) => _finish(event.pointer),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: pressed ? 1 : 0),
        duration: Duration(milliseconds: pressed ? 70 : 200),
        curve: pressed ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
        builder: (context, value, child) => Transform.scale(
          scaleX: 1 - .03 * value,
          scaleY: 1 - .08 * value,
          transformHitTests: false,
          child: child,
        ),
      ),
    );
  }
}

final _glyphNames = <IconData, String>{
  CupertinoIcons.chevron_left: 'ios_chevron_left',
  CupertinoIcons.clear_circled_solid: 'ios_clear_circled_solid',
  CupertinoIcons.location_fill: 'ios_location_fill',
  CupertinoIcons.search: 'ios_search',
  CupertinoIcons.xmark_circle: 'ios_xmark_circle',
  Icons.arrow_back: 'md_arrow_back',
  Icons.arrow_back_ios_new_rounded: 'md_arrow_back_ios_new_rounded',
  Icons.arrow_forward_ios_rounded: 'md_arrow_forward_ios_rounded',
  Icons.arrow_forward_rounded: 'md_arrow_forward_rounded',
  Icons.auto_awesome: 'md_auto_awesome',
  Icons.calendar_month_outlined: 'md_calendar_month_outlined',
  Icons.cancel: 'md_cancel',
  Icons.check: 'md_check',
  Icons.check_circle_rounded: 'md_check_circle_rounded',
  Icons.check_rounded: 'md_check_rounded',
  Icons.chevron_left: 'md_chevron_left',
  Icons.chevron_right: 'md_chevron_right',
  Icons.chevron_right_rounded: 'md_chevron_right_rounded',
  Icons.error_outline: 'md_error_outline',
  Icons.image_not_supported: 'md_image_not_supported',
  Icons.ios_share: 'md_ios_share',
  Icons.lock_outline: 'md_lock_outline',
  Icons.menu_book_outlined: 'md_menu_book_outlined',
  Icons.person_outline_rounded: 'md_person_outline_rounded',
  Icons.play_arrow: 'md_play_arrow',
  Icons.refresh: 'md_refresh',
  Icons.shuffle: 'md_shuffle',
  Icons.star_outline: 'md_star_outline',
  Icons.star_rounded: 'md_star_rounded',
  Icons.style_outlined: 'md_style_outlined',
};

const _vectorSizes = <String, Size>{
  'assets/icons/affirmation_arrow_figma.svg': Size.square(19.8446),
  'assets/icons/back_icon.svg': Size(18, 24),
  'assets/icons/checbox_round_selected.svg': Size.square(29),
  'assets/icons/close_icon.svg': Size.square(20),
  'assets/icons/cursor_icon.svg': Size.square(24),
  'assets/icons/daily_symbol_shuffle.svg': Size.square(24),
  'assets/icons/exit_icon.svg': Size.square(24),
  'assets/icons/home_affirmation_link.svg': Size.square(24),
  'assets/icons/home_moon_location.svg': Size(9.37877, 12),
  'assets/icons/minus_circle_icon.svg': Size.square(22),
  'assets/icons/nav_bar/tab_home_icon.svg': Size.square(24),
  'assets/icons/nav_bar/tab_moon_icon.svg': Size(25, 24),
  'assets/icons/nav_bar/tab_practices_icon.svg': Size.square(24),
  'assets/icons/nav_bar/tab_profile_icon.svg': Size.square(24),
  'assets/icons/nav_bar/tab_star_icon.svg': Size.square(24),
  'assets/icons/notifications_icon.svg': Size.square(24),
  'assets/icons/plus_circle_icon.svg': Size.square(24),
  'assets/icons/plus_icon.svg': Size.square(24),
  'assets/icons/profile_about_icon.svg': Size.square(34),
  'assets/icons/profile_achievements_icon.svg': Size.square(34),
  'assets/icons/profile_notifications_icon.svg': Size.square(34),
  'assets/icons/profile_shop_icon.svg': Size.square(34),
  'assets/icons/profile_site_icon.svg': Size.square(34),
  'assets/icons/radio_button_selected.svg': Size.square(20),
  'assets/icons/radio_button_unselected.svg': Size.square(20),
  'assets/icons/repeat_icon.svg': Size.square(24),
  'assets/icons/right_arrow_icon.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_award.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_beauty.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_beauty_locked.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_cup_of_tea.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_education.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_education_locked.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_heart.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_heart_locked.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_map.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_picture.svg': Size.square(24),
  'assets/icons/sphere_icon/ic_picture_locked.svg': Size.square(24),
  'assets/icons/sub/calendar_icon.svg': Size.square(24),
  'assets/icons/sub/key.svg': Size.square(24),
  'assets/icons/sub/lock_icon.svg': Size.square(24),
  'assets/icons/sub/moon_icon.svg': Size.square(24),
  'assets/icons/sub/palette.svg': Size.square(24),
  'assets/icons/sub/people_icon.svg': Size.square(24),
  'assets/icons/sub/shield.svg': Size.square(24),
  'assets/icons/sub/star_icon.svg': Size.square(24),
  'assets/icons/sub/voice.svg': Size.square(24),
  'assets/icons/success_square_icon.svg': Size.square(21),
  'assets/icons/swipe_hand.svg': Size.square(32),
  'assets/icons/wallet_icon.svg': Size.square(22),
  'assets/icons/white_lock_icon.svg': Size(20, 22),
};
