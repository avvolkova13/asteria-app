import 'package:asteria_app/app/data/models/moon_phase/moon_phase_model.dart';
import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_day_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_week_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_month_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_year_model.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/data/models/kelt_deck/kelt_deck_model.dart';
import 'package:asteria_app/app/data/models/love_deck/love_deck_model.dart';
import 'package:asteria_app/app/data/models/anakra_chat/anakra_chat_message_model.dart';
import 'package:asteria_app/app/data/models/user/rune_deck_model.dart';
import 'package:asteria_app/app/data/models/user/rune_of_day_item_model.dart';
import 'package:asteria_app/app/data/models/user/tarot_card_of_day_item_model.dart';
import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';

part 'user_enums.dart';
part 'birth_place_model.dart';
part 'current_location_model.dart';
part 'user_statistics_model.dart';
part 'birth_date_model.dart';
part 'personal_info_model.dart';
part 'balance_history_model.dart';
part 'solar_data_model.dart';
part 'planets_houses_data_model.dart';

class UserModel {
  final String id;
  final String? phoneNumber;
  final String? email;
  final AuthMethod authMethod;
  final String? name;
  final int balance;
  final List<ShopItemModel>? shopItems;
  final PersonalInfoModel? personalInfo;
  final CurrentLocationModel? currentLocation;
  final UserGroup userGroup;
  final SubscriptionType subscriptionType;
  final SubscriptionProvider? subscriptionProvider;
  final SubscriptionStatus? subscriptionStatus;
  final DateTime? subscriptionExpiresAt;
  final bool cancelAtPeriodEnd;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextPaymentDate;
  final List<SavedCompatibilityModel> compatibilityHistory;
  final List<String> viewedContentIds;
  final KeltDeckModel? keltDeck;
  final LoveDeckModel? loveDeck;
  final List<String> keltDeckImpact;
  final List<SonnikModel> sonnikHistory;
  final HoroscopeDayModel? horoscopeDay;
  final HoroscopeWeekModel? horoscopeWeek;
  final HoroscopeMonthModel? horoscopeMonth;
  final HoroscopeYearModel? horoscopeYear;
  final NatalCardModel? natalCard;
  final MoonPhaseModel? moonPhase;
  final List<BalanceHistoryModel> balanceHistory;
  final SolarDataModel solarData;
  final PlanetsHousesDataModel planetsHousesData;
  final List<AnakraChatMessageModel> anakraMessages;
  final TarotDeckModel? tarotDeck;
  final DateTime? tarotDeckLayoutLastResetDate;
  final RuneDeckModel? runeDeck;
  final DateTime? runeDeckLayoutLastResetDate;
  final RuneOfDayItemModel? runeOfDayItem;
  final TarotCardOfDayItemModel? tarotCardOfDayItem;
  final UserStatisticsModel statistics;
  final Map<String, dynamic>? attribution;

  const UserModel({
    required this.id,
    this.phoneNumber,
    this.email,
    this.authMethod = AuthMethod.email,
    this.name,
    required this.balance,
    this.shopItems,
    this.personalInfo,
    this.currentLocation,
    required this.userGroup,
    required this.subscriptionType,
    this.subscriptionProvider,
    this.subscriptionStatus,
    this.subscriptionExpiresAt,
    this.cancelAtPeriodEnd = false,
    required this.createdAt,
    required this.updatedAt,
    required this.solarData,
    required this.planetsHousesData,
    this.compatibilityHistory = const [],
    this.viewedContentIds = const [],
    this.keltDeck,
    this.loveDeck,
    this.keltDeckImpact = const [],
    this.horoscopeDay,
    this.horoscopeWeek,
    this.horoscopeMonth,
    this.horoscopeYear,
    this.natalCard,
    this.moonPhase,
    required this.sonnikHistory,
    this.balanceHistory = const [],
    this.anakraMessages = const [],
    this.nextPaymentDate,
    this.tarotDeck,
    this.tarotDeckLayoutLastResetDate,
    this.runeDeck,
    this.runeDeckLayoutLastResetDate,
    this.runeOfDayItem,
    this.tarotCardOfDayItem,
    this.statistics = const UserStatisticsModel(),
    this.attribution,
  });

  factory UserModel.empty() {
    final now = DateTime.now();
    return UserModel(
      id: '',
      phoneNumber: null,
      balance: 0,
      userGroup: UserGroup.user,
      subscriptionType: SubscriptionType.free,
      subscriptionProvider: null,
      subscriptionStatus: null,
      subscriptionExpiresAt: null,
      cancelAtPeriodEnd: false,
      createdAt: now,
      updatedAt: now,
      sonnikHistory: const [],
      balanceHistory: const [],
      anakraMessages: const [],
      solarData: SolarDataModel(data: ''),
      planetsHousesData: PlanetsHousesDataModel(
        data: '',
        elements: Elements(fire: '', earth: '', air: '', water: ''),
      ),
      nextPaymentDate: null,
      tarotDeck: null,
      tarotDeckLayoutLastResetDate: null,
      runeDeck: null,
      runeDeckLayoutLastResetDate: null,
      runeOfDayItem: null,
      tarotCardOfDayItem: null,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      authMethod: AuthMethod.values.firstWhere(
        (value) => value.name == json['auth_method'],
        orElse: () => AuthMethod.email,
      ),
      name: json['name'] as String?,
      balance: json['balance'] as int,
      shopItems: json['shop_items'] != null
          ? (json['shop_items'] as List)
                .map((e) => ShopItemModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      personalInfo: json['personal_info'] != null
          ? PersonalInfoModel.fromJson(
              json['personal_info'] as Map<String, dynamic>,
            )
          : null,
      currentLocation: json['current_location'] != null
          ? CurrentLocationModel.fromJson(
              json['current_location'] as Map<String, dynamic>,
            )
          : null,
      userGroup: UserGroup.values.firstWhere(
        (e) => e.name == json['user_group'],
        orElse: () => UserGroup.user,
      ),
      subscriptionType: SubscriptionType.values.firstWhere(
        (e) => e.name == json['subscription_type'],
        orElse: () => SubscriptionType.free,
      ),
      subscriptionProvider: subscriptionProviderFromJson(
        json['subscription_provider'],
      ),
      subscriptionStatus: subscriptionStatusFromJson(
        json['subscription_status'],
      ),
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
      cancelAtPeriodEnd: (json['cancel_at_period_end'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      compatibilityHistory: json['compatibility_history'] != null
          ? (json['compatibility_history'] as List)
                .map(
                  (e) => SavedCompatibilityModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
      viewedContentIds: json['viewed_content_ids'] != null
          ? (json['viewed_content_ids'] as List)
                .map((e) => e as String)
                .toList()
          : [],
      keltDeck: json['kelt_deck'] != null
          ? KeltDeckModel.fromJson(json['kelt_deck'] as Map<String, dynamic>)
          : null,
      loveDeck: json['love_deck'] != null
          ? LoveDeckModel.fromJson(json['love_deck'] as Map<String, dynamic>)
          : null,
      keltDeckImpact: json['kelt_deck_impact'] != null
          ? (json['kelt_deck_impact'] as List).map((e) => e as String).toList()
          : [],
      horoscopeDay: json['horoscope_day'] != null
          ? HoroscopeDayModel.fromJson(
              json['horoscope_day'] as Map<String, dynamic>,
            )
          : null,
      horoscopeWeek: json['horoscope_week'] != null
          ? HoroscopeWeekModel.fromJson(
              json['horoscope_week'] as Map<String, dynamic>,
            )
          : null,
      horoscopeMonth: json['horoscope_month'] != null
          ? HoroscopeMonthModel.fromJson(
              json['horoscope_month'] as Map<String, dynamic>,
            )
          : null,
      horoscopeYear: json['horoscope_year'] != null
          ? HoroscopeYearModel.fromJson(
              json['horoscope_year'] as Map<String, dynamic>,
            )
          : null,
      natalCard: json['natal_card'] != null
          ? NatalCardModel.fromJson(json['natal_card'] as Map<String, dynamic>)
          : null,
      moonPhase: json['moon_phase'] != null
          ? MoonPhaseModel.fromJson(json['moon_phase'] as Map<String, dynamic>)
          : null,
      sonnikHistory: json['sonnik_history'] != null
          ? (json['sonnik_history'] as List)
                .map((e) => SonnikModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      balanceHistory: json['balance_history'] != null
          ? (json['balance_history'] as List)
                .map(
                  (e) =>
                      BalanceHistoryModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
      solarData: json['solar_data'] != null
          ? SolarDataModel.fromJson(json['solar_data'] as Map<String, dynamic>)
          : SolarDataModel(data: ''),
      planetsHousesData: json['planets_houses_data'] != null
          ? PlanetsHousesDataModel.fromJson(
              json['planets_houses_data'] as Map<String, dynamic>,
            )
          : PlanetsHousesDataModel(
              data: '',
              elements: Elements(fire: '', earth: '', air: '', water: ''),
            ),
      anakraMessages: json['anakra_messages'] != null
          ? (json['anakra_messages'] as List)
                .map(
                  (e) => AnakraChatMessageModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
      nextPaymentDate: json['next_payment_date'] != null
          ? DateTime.parse(json['next_payment_date'] as String)
          : null,
      tarotDeck: json['tarot_deck'] != null
          ? TarotDeckModel.fromJson(json['tarot_deck'] as Map<String, dynamic>)
          : null,
      tarotDeckLayoutLastResetDate:
          json['tarot_deck_layout_last_reset_date'] != null
          ? DateTime.parse(json['tarot_deck_layout_last_reset_date'] as String)
          : null,
      runeDeck: json['rune_deck'] != null
          ? RuneDeckModel.fromJson(json['rune_deck'] as Map<String, dynamic>)
          : null,
      runeDeckLayoutLastResetDate:
          json['rune_deck_layout_last_reset_date'] != null
          ? DateTime.parse(json['rune_deck_layout_last_reset_date'] as String)
          : null,
      runeOfDayItem: json['rune_of_day_item'] != null
          ? RuneOfDayItemModel.fromJson(
              json['rune_of_day_item'] as Map<String, dynamic>,
            )
          : null,
      tarotCardOfDayItem: json['tarot_card_of_day_item'] != null
          ? TarotCardOfDayItemModel.fromJson(
              json['tarot_card_of_day_item'] as Map<String, dynamic>,
            )
          : null,
      statistics: UserStatisticsModel.fromJson(
        json['statistics'] as Map<String, dynamic>? ?? const {},
      ),
      attribution: json['attribution'] != null
          ? Map<String, dynamic>.from(json['attribution'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'email': email,
      'auth_method': authMethod.name,
      'name': name,
      'balance': balance,
      'shop_items': shopItems?.map((e) => e.toJson()).toList(),
      'personal_info': personalInfo?.toJson(),
      'current_location': currentLocation?.toJson(),
      'user_group': userGroup.name,
      'subscription_type': subscriptionType.name,
      'subscription_provider': subscriptionProviderToJson(subscriptionProvider),
      'subscription_status': subscriptionStatusToJson(subscriptionStatus),
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'cancel_at_period_end': cancelAtPeriodEnd,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'compatibility_history': compatibilityHistory
          .map((e) => e.toJson())
          .toList(),
      'viewed_content_ids': viewedContentIds,
      'kelt_deck': keltDeck?.toJson(),
      'love_deck': loveDeck?.toJson(),
      'kelt_deck_impact': keltDeckImpact,
      'horoscope_day': horoscopeDay?.toJson(),
      'horoscope_week': horoscopeWeek?.toJson(),
      'horoscope_month': horoscopeMonth?.toJson(),
      'horoscope_year': horoscopeYear?.toJson(),
      'natal_card': natalCard?.toJson(),
      'moon_phase': moonPhase?.toJson(),
      'sonnik_history': sonnikHistory.map((e) => e.toJson()).toList(),
      'balance_history': balanceHistory.map((e) => e.toJson()).toList(),
      'solar_data': solarData.toJson(),
      'planets_houses_data': planetsHousesData.toJson(),
      'anakra_messages': anakraMessages.map((e) => e.toJson()).toList(),
      'next_payment_date': nextPaymentDate?.toIso8601String(),
      'tarot_deck': tarotDeck?.toJson(),
      'tarot_deck_layout_last_reset_date': tarotDeckLayoutLastResetDate
          ?.toIso8601String(),
      'rune_deck': runeDeck?.toJson(),
      'rune_deck_layout_last_reset_date': runeDeckLayoutLastResetDate
          ?.toIso8601String(),
      'rune_of_day_item': runeOfDayItem?.toJson(),
      'tarot_card_of_day_item': tarotCardOfDayItem?.toJson(),
      'statistics': statistics.toJson(),
      'attribution': attribution,
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    bool clearPhoneNumber = false,
    String? email,
    AuthMethod? authMethod,
    String? name,
    int? balance,
    List<ShopItemModel>? shopItems,
    PersonalInfoModel? personalInfo,
    CurrentLocationModel? currentLocation,
    bool clearCurrentLocation = false,
    UserGroup? userGroup,
    SubscriptionType? subscriptionType,
    SubscriptionProvider? subscriptionProvider,
    SubscriptionStatus? subscriptionStatus,
    DateTime? subscriptionExpiresAt,
    bool? cancelAtPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SavedCompatibilityModel>? compatibilityHistory,
    List<String>? viewedContentIds,
    KeltDeckModel? keltDeck,
    LoveDeckModel? loveDeck,
    List<String>? keltDeckImpact,
    HoroscopeDayModel? horoscopeDay,
    HoroscopeWeekModel? horoscopeWeek,
    HoroscopeMonthModel? horoscopeMonth,
    HoroscopeYearModel? horoscopeYear,
    NatalCardModel? natalCard,
    MoonPhaseModel? moonPhase,
    bool clearMoonPhase = false,
    List<SonnikModel>? sonnikHistory,
    List<BalanceHistoryModel>? balanceHistory,
    SolarDataModel? solarData,
    PlanetsHousesDataModel? planetsHousesData,
    List<AnakraChatMessageModel>? anakraMessages,
    DateTime? nextPaymentDate,
    TarotDeckModel? tarotDeck,
    DateTime? tarotDeckLayoutLastResetDate,
    bool clearTarotDeck = false,
    RuneDeckModel? runeDeck,
    DateTime? runeDeckLayoutLastResetDate,
    bool clearRuneDeck = false,
    RuneOfDayItemModel? runeOfDayItem,
    TarotCardOfDayItemModel? tarotCardOfDayItem,
    UserStatisticsModel? statistics,
    Map<String, dynamic>? attribution,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      email: email ?? this.email,
      authMethod: authMethod ?? this.authMethod,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      shopItems: shopItems ?? this.shopItems,
      personalInfo: personalInfo ?? this.personalInfo,
      currentLocation: clearCurrentLocation
          ? null
          : (currentLocation ?? this.currentLocation),
      userGroup: userGroup ?? this.userGroup,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionProvider: subscriptionProvider ?? this.subscriptionProvider,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      cancelAtPeriodEnd: cancelAtPeriodEnd ?? this.cancelAtPeriodEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      compatibilityHistory: compatibilityHistory ?? this.compatibilityHistory,
      viewedContentIds: viewedContentIds ?? this.viewedContentIds,
      keltDeck: keltDeck ?? this.keltDeck,
      loveDeck: loveDeck ?? this.loveDeck,
      keltDeckImpact: keltDeckImpact ?? this.keltDeckImpact,
      horoscopeDay: horoscopeDay ?? this.horoscopeDay,
      horoscopeWeek: horoscopeWeek ?? this.horoscopeWeek,
      horoscopeMonth: horoscopeMonth ?? this.horoscopeMonth,
      horoscopeYear: horoscopeYear ?? this.horoscopeYear,
      natalCard: natalCard ?? this.natalCard,
      moonPhase: clearMoonPhase ? null : (moonPhase ?? this.moonPhase),
      sonnikHistory: sonnikHistory ?? this.sonnikHistory,
      balanceHistory: balanceHistory ?? this.balanceHistory,
      solarData: solarData ?? this.solarData,
      planetsHousesData: planetsHousesData ?? this.planetsHousesData,
      anakraMessages: anakraMessages ?? this.anakraMessages,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      tarotDeck: clearTarotDeck ? null : (tarotDeck ?? this.tarotDeck),
      tarotDeckLayoutLastResetDate:
          tarotDeckLayoutLastResetDate ?? this.tarotDeckLayoutLastResetDate,
      runeDeck: clearRuneDeck ? null : (runeDeck ?? this.runeDeck),
      runeDeckLayoutLastResetDate:
          runeDeckLayoutLastResetDate ?? this.runeDeckLayoutLastResetDate,
      runeOfDayItem: runeOfDayItem ?? this.runeOfDayItem,
      tarotCardOfDayItem: tarotCardOfDayItem ?? this.tarotCardOfDayItem,
      statistics: statistics ?? this.statistics,
      attribution: attribution ?? this.attribution,
    );
  }

  bool hasProSubscription() {
    return subscriptionType == SubscriptionType.pro;
  }
}
