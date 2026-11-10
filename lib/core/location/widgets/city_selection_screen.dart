import 'dart:async';

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
  }) : _citySearchService = citySearchService;

  final CitySearchService? _citySearchService;
  final List<CitySuggestion> initialSuggestions;
  final String? initialSelectedPlaceId;

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
    setState(() {});
  }

  Future<void> _search(String query) async {
    final normalizedQuery = query.trim();
    final requestId = ++_searchRequestId;
    if (normalizedQuery.length < 2) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = null;
        });
      }
      return;
    }

    setState(() {
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
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _suggestions = const [];
        _isLoading = false;
        _error = context.l10n.citySearchError;
      });
    }
  }

  Future<void> _selectSuggestion(CitySuggestion suggestion) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _selectedPlaceId = suggestion.placeId;
      _error = null;
    });
    try {
      final location = await _citySearchService.getLocationForSuggestion(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CitySelectionHeader(),
              const SizedBox(height: 18),
              Text(
                context.l10n.citySelectionTitle,
                style: context.textTheme.playfairSemiBold24.copyWith(
                  color: AppColors.textInverse,
                ),
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
                ),
              ],
              const SizedBox(height: 8),
              Expanded(child: _buildSuggestionList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _fieldBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            CupertinoIcons.search,
            size: 17,
            color: AppColors.white.withValues(alpha: 0.74),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onQueryChanged,
              cursorColor: AppColors.white,
              keyboardAppearance: Brightness.dark,
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                color: AppColors.textInverse,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.locationManualInputHint,
                hintStyle: context.textTheme.inverseUrbanistRegular16.copyWith(
                  color: AppColors.white.withValues(alpha: 0.45),
                ),
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
          if (_controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
              },
              icon: Icon(
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
          suggestion: suggestion,
          isSelected: suggestion.placeId == _selectedPlaceId,
          isEnabled: !_isLoading,
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
        Image.asset('assets/icons/star_coin_icon.png', width: 14, height: 14),
        const SizedBox(width: 10),
        Image.asset(proIconPath, height: 30),
      ],
    );
  }
}

class _CitySuggestionTile extends StatelessWidget {
  const _CitySuggestionTile({
    required this.suggestion,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final CitySuggestion suggestion;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            Expanded(
              child: Text(
                suggestion.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.inverseUrbanistRegular14.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              selected: isSelected,
              child: _CityRadio(isSelected: isSelected),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityRadio extends StatelessWidget {
  const _CityRadio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? const Color(0xFFE6994D)
              : AppColors.white.withValues(alpha: 0.24),
          width: 1.2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6994D),
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
