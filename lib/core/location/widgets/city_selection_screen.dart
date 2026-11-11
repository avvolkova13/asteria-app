import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'dart:async';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/location/city_search_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CitySelectionResult {
  const CitySelectionResult({
    required this.location,
    required this.suggestion,
    required this.suggestions,
  });

  final CurrentLocationModel location;
  final CitySuggestion suggestion;
  final List<CitySuggestion> suggestions;
}

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({
    super.key,
    CitySearchService? citySearchService,
    this.initialSuggestions = const [],
    this.initialSelectedPlaceId,
    this.asSheet = false,
  }) : _citySearchService = citySearchService;

  final CitySearchService? _citySearchService;
  final List<CitySuggestion> initialSuggestions;
  final String? initialSelectedPlaceId;
  final bool asSheet;

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  static const _background = Color(0xFF100817);
  static const _fieldFill = Color(0xFF1D1531);
  static const _fieldBorder = Color(0xFF392A58);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  late List<CitySuggestion> _suggestions;
  bool _isLoading = false;
  bool _selecting = false;
  String? _error;
  late String? _selectedPlaceId;
  int _searchRequestId = 0;

  CitySearchService get _citySearchService =>
      widget._citySearchService ?? di.get<CitySearchService>();

  @override
  void initState() {
    super.initState();
    _suggestions = widget.initialSuggestions;
    _selectedPlaceId = widget.initialSelectedPlaceId;
    if (_suggestions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(value);
    });
    setState(() {
      _error = null;
      if (widget.asSheet) _suggestions = _localMatches(value.trim());
    });
  }

  List<CitySuggestion> _localMatches(String query) => widget.asSheet
      ? widget.initialSuggestions
            .where(
              (s) => s.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList()
      : const [];

  Future<void> _search(String query) async {
    final normalizedQuery = query.trim();
    final requestId = ++_searchRequestId;
    if (normalizedQuery.length < 2) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = null;
          _suggestions = normalizedQuery.isEmpty
              ? widget.initialSuggestions
              : _localMatches(normalizedQuery);
        });
      }
      return;
    }

    final local = _localMatches(normalizedQuery);
    setState(() {
      _suggestions = local;
      _isLoading = true;
      _error = null;
    });

    try {
      final suggestions = await _citySearchService.searchCities(
        normalizedQuery,
        language: Localizations.localeOf(context).languageCode,
      );
      if (!mounted ||
          requestId != _searchRequestId ||
          normalizedQuery != _controller.text.trim()) {
        return;
      }
      setState(() {
        final names = local.map((s) => s.description.toLowerCase()).toSet();
        _suggestions = [
          ...local,
          ...suggestions.where((s) => names.add(s.description.toLowerCase())),
        ];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted ||
          requestId != _searchRequestId ||
          normalizedQuery != _controller.text.trim()) {
        return;
      }
      setState(() {
        _suggestions = local;
        _isLoading = false;
        _error = local.isEmpty ? context.l10n.citySearchError : null;
      });
    }
  }

  Future<void> _selectSuggestion(CitySuggestion suggestion) async {
    if (_selecting || (_isLoading && suggestion.knownLocation == null)) return;
    _selecting = true;
    _debounce?.cancel();
    _searchRequestId++;
    setState(() {
      _isLoading = true;
      _selectedPlaceId = suggestion.placeId;
      _error = null;
    });
    try {
      final location =
          suggestion.knownLocation ??
          await _citySearchService.getLocationForSuggestion(
            suggestion,
            language: Localizations.localeOf(context).languageCode,
          );
      if (!mounted) return;
      if (location == null) {
        setState(() {
          _isLoading = false;
          _error = context.l10n.citySearchError;
        });
        return;
      }

      Navigator.of(context).pop(
        CitySelectionResult(
          location: location,
          suggestion: suggestion,
          suggestions: _suggestions,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = context.l10n.citySearchError;
      });
    } finally {
      _selecting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asSheet) {
      return ModalGlassSurface(
        color: const Color(0xFF110823),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: AsteriaEntrance.sections([
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 64,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF241735),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 23),
                  Semantics(
                    header: true,
                    child: Text(
                      context.l10n.citySelectionTitle,
                      style: AppTypography.h2.copyWith(color: AppColors.textInverse),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchField(context),
                  if (_isLoading) const LinearProgressIndicator(minHeight: 2),
                  if (_error != null ||
                      (!_isLoading &&
                          _suggestions.isEmpty &&
                          _controller.text.trim().length >= 2))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AsteriaEntrance(
                        replayKey: _error,
                        child: Text(_error ?? context.l10n.citySearchEmpty),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Expanded(child: _buildSuggestionList(context)),
                ]),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AsteriaEntrance.sections([
              const _CitySelectionHeader(),
              const SizedBox(height: 18),
              Text(
                context.l10n.citySelectionTitle,
                style: AppTypography.h2.copyWith(color: AppColors.textInverse),
              ),
              const SizedBox(height: 10),
              _buildSearchField(context),
              if (_isLoading) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(minHeight: 2),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: context.textTheme.inverseUrbanistRegular14.copyWith(
                    color: const Color(0xFFFF6D6D),
                  ),
                ).withEntrance(),
              ],
              const SizedBox(height: 8),
              Expanded(child: _buildSuggestionList(context)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: widget.asSheet ? 50 : 44,
      decoration: BoxDecoration(
        color: widget.asSheet ? const Color(0x339A7DB8) : _fieldFill,
        borderRadius: BorderRadius.circular(widget.asSheet ? 16 : 10),
        border: Border.all(color: _fieldBorder),
      ),
      child: Row(
        children: [
          SizedBox(width: widget.asSheet ? 16 : 12),
          if (widget.asSheet)
            ClayAssetIcon(
              'assets/icons/city_search.svg',
              width: 22.5,
              height: 22.5,
              tint: AppColors.textInverse,
              excludeFromSemantics: true,
            )
          else
            ClayIcon(
              CupertinoIcons.search,
              size: 17,
              color: AppColors.white.withValues(alpha: 0.74),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              label: widget.asSheet
                  ? context.l10n.locationManualInputHint
                  : null,
              child: TextField(
                onTap: LotusFeedback.selection,
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onQueryChanged,
                cursorColor: AppColors.white,
                keyboardAppearance: Brightness.dark,
                style: context.textTheme.inverseUrbanistRegular16.copyWith(
                  color: AppColors.textInverse,
                ),
                decoration: InputDecoration(
                  hintText: widget.asSheet
                      ? null
                      : context.l10n.locationManualInputHint,
                  hintStyle: AppTypography.placeholder
                      .copyWith(color: AppColors.white.withValues(alpha: 0.45)),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            LotusButtons.icon(
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
              },
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              icon: widget.asSheet
                  ? ClayAssetIcon(
                      'assets/icons/city_clear.svg',
                      width: 20,
                      height: 20,
                      tint: AppColors.white.withValues(alpha: 0.55),
                    )
                  : ClayIcon(
                      CupertinoIcons.xmark_circle,
                      size: 18,
                      color: AppColors.white.withValues(alpha: 0.48),
                    ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildSuggestionList(BuildContext context) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _suggestions.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppColors.white.withValues(alpha: 0.08)),
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _CitySuggestionTile(
          key: ValueKey(suggestion.placeId),
          suggestion: suggestion,
          isSelected: suggestion.placeId == _selectedPlaceId,
          asSheet: widget.asSheet,
          query: _controller.text.trim(),
          isEnabled:
              !_selecting && (!_isLoading || suggestion.knownLocation != null),
          onTap: () => _selectSuggestion(suggestion),
        );
      },
    );
  }
}

class _CitySelectionHeader extends StatelessWidget {
  const _CitySelectionHeader();

  @override
  Widget build(BuildContext context) {
    final user = di.isRegistered<UserProvider>()
        ? di.get<UserProvider>().currentUser
        : null;
    final monetization = di.isRegistered<MonetizationProvider>()
        ? di.get<MonetizationProvider>()
        : null;
    final balance = monetization?.balance ?? 0;
    final proIconPath = user != null && monetization?.effectivePro == true
        ? 'assets/icons/pro_enabled.png'
        : 'assets/icons/pro_disabled.png';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF100817),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF3B2A57)),
          ),
          child: Center(
            child: Text(
              Localizations.localeOf(context).languageCode == 'ru'
                  ? 'EN'
                  : 'RU',
              style: const TextStyle(
                color: Color(0xFFD6A359),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const Spacer(),
        Text(
          '$balance',
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        LotusRasterIcon(
          'assets/icons/star_coin_icon.png',
          width: 14,
          height: 14,
        ),
        const SizedBox(width: 10),
        LotusRasterIcon(proIconPath, height: 30),
      ],
    );
  }
}

class _CitySuggestionTile extends StatelessWidget {
  const _CitySuggestionTile({
    super.key,
    required this.suggestion,
    required this.isSelected,
    required this.isEnabled,
    required this.asSheet,
    required this.query,
    required this.onTap,
  });

  final CitySuggestion suggestion;
  final bool isSelected;
  final bool isEnabled;
  final bool asSheet;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = suggestion.description;
    final match = asSheet && query.isNotEmpty
        ? name.toLowerCase().indexOf(query.toLowerCase())
        : -1;
    final baseStyle = asSheet
        ? (isSelected ? AppTypography.text1SemiBold : AppTypography.text1)
        : AppTypography.body14;
    final style = baseStyle.copyWith(
      color: AppColors.textInverse.withValues(alpha: 0.9),
    );
    return LotusInkTap(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            Expanded(
              child: match < 0
                  ? Text(
                      name,
                      maxLines: asSheet ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: style,
                    )
                  : Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: name.substring(0, match)),
                          TextSpan(
                            text: name.substring(match, match + query.length),
                            style: const TextStyle(
                              color: AppColors.textInverse,
                            ),
                          ),
                          TextSpan(text: name.substring(match + query.length)),
                        ],
                      ),
                      style: style.copyWith(
                        color: AppColors.white.withValues(alpha: 0.55),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            const SizedBox(width: 10),
            Semantics(
              selected: isSelected,
              child: ClayAssetIcon(
                isSelected
                    ? 'assets/icons/city_selected.svg'
                    : 'assets/icons/city_unselected.svg',
                width: asSheet ? 20 : 16,
                height: asSheet ? 20 : 16,
                tint: isSelected
                    ? null
                    : (asSheet ? AppColors.textTertiary : Colors.white54),
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
