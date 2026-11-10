import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:equatable/equatable.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  final int currentTabIndex;
  final RuneOfDayModel? runeOfDay;
  final TarotCardModel? tarotCard;
  final bool isTarotCardOpened;
  final bool isRuneOpened;

  const HomeLoaded({
    this.currentTabIndex = 0,
    this.runeOfDay,
    this.tarotCard,
    this.isTarotCardOpened = false,
    this.isRuneOpened = false,
  });

  HomeLoaded copyWith({
    int? currentTabIndex,
    RuneOfDayModel? runeOfDay,
    TarotCardModel? tarotCard,
    bool? isTarotCardOpened,
    bool? isRuneOpened,
  }) {
    return HomeLoaded(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      runeOfDay: runeOfDay ?? this.runeOfDay,
      tarotCard: tarotCard ?? this.tarotCard,
      isTarotCardOpened: isTarotCardOpened ?? this.isTarotCardOpened,
      isRuneOpened: isRuneOpened ?? this.isRuneOpened,
    );
  }

  @override
  List<Object?> get props => [currentTabIndex, runeOfDay, tarotCard, isTarotCardOpened, isRuneOpened];
}

final class HomeLoggedOut extends HomeState {
  const HomeLoggedOut();
}

final class HomeError extends HomeState {
  final HomeFailure failure;

  const HomeError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

enum HomeFailure { load, logout }
