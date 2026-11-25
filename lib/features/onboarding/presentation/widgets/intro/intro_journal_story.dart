import 'package:flutter/material.dart';

import 'intro_dream_journal_scene.dart';
import 'intro_practice_shelf.dart';
import 'intro_story.dart';

class IntroJournalStory extends StatelessWidget {
  const IntroJournalStory.dream({super.key, required this.active})
    : dream = true;
  const IntroJournalStory.practice({super.key, required this.active})
    : dream = false;

  final bool active;
  final bool dream;

  @override
  Widget build(BuildContext context) => IntroStory(
    active: active,
    duration: Duration(seconds: dream ? 15 : 16),
    builder: (context, time, still, _) => dream
        ? IntroDreamJournalScene(time: time, still: still)
        : IntroPracticeShelf(time: time, still: still),
  );
}
