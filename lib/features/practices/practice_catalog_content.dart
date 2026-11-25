part of 'practice_catalog_screen.dart';

const _practices = <_Practice>[
  _Practice(
    id: 'unhurried-morning',
    scene: PracticeScene.dawn,
    kind: _PracticeKind.meditation,
    minutes: 3,
    title: ("Утро без спешки", "An Unhurried Morning"),
    description: (
      "Почувствуй опору и выбери, с чего хочется начать день.",
      "Feel supported and choose how to begin your day.",
    ),
    setup: ("Сидя · без инвентаря", "Seated · no equipment"),
    steps: [
      (
        0,
        "Устройся поудобнее. Почувствуй, на что опирается тело. Можно смотреть в одну точку или прикрыть глаза.",
        "Get comfortable. Notice what’s supporting your body. You can rest your gaze on one spot or close your eyes.",
      ),
      (
        27,
        "Заметь один звук поблизости. Может быть, он совсем тихий. Дай ему прозвучать до конца.",
        "Notice a sound nearby. It might be very quiet. Listen until it fades.",
      ),
      (
        55,
        "Почувствуй один вдох и один выдох в своём темпе.",
        "Feel one inhale and one exhale at your own pace.",
      ),
      (
        93,
        "Подумай о первом маленьком деле, которое хочется сделать после этой записи. Может быть, выпить воды или открыть окно.",
        "Think of one small thing you’d like to do after this practice. Maybe have some water or open a window.",
      ),
      (
        137,
        "Почувствуй стопы на полу. Пошевели пальцами рук. Открывай глаза, когда захочется.",
        "Feel your feet on the floor. Wiggle your fingers. Open your eyes whenever you’re ready.",
      ),
      (
        161,
        "Можно начать с того маленького дела, которое ты выбрала.",
        "You can begin with the small thing you chose.",
      ),
    ],
  ),
  _Practice(
    id: 'workday-is-over',
    scene: PracticeScene.dusk,
    kind: _PracticeKind.meditation,
    minutes: 4,
    title: ("Рабочий день закончился", "The Workday Is Over"),
    description: (
      "Пауза между работой и вечером. Переведи внимание с дел на то, что вокруг.",
      "A pause between work and the evening. Bring your attention from your tasks to the room around you.",
    ),
    setup: ("Сидя · без инвентаря", "Seated · no equipment"),
    steps: [
      (
        0,
        "Сядь так, чтобы спина могла на что-нибудь опереться. Положи ладони на бёдра.",
        "Sit somewhere your back can rest against a surface. Let your hands settle on your thighs.",
      ),
      (
        33,
        "Заметь, где ладони касаются ткани. Какая она на ощупь? Мягкая, прохладная, совсем обычная?",
        "Notice where your palms touch the fabric. How does it feel? Soft, cool, familiar?",
      ),
      (
        66,
        "Если вспоминается рабочее дело, дай этой мысли пройти. Потом снова почувствуй ладони.",
        "If a task from work comes to mind, let the thought pass. Then notice your hands again.",
      ),
      (
        110,
        "Прислушайся к звукам в комнате. Какой из них ближе всего к тебе? Какой дальше?",
        "Listen to the sounds in the room. Which one is closest? Which one is farther away?",
      ),
      (
        156,
        "Останься так ещё немного. Почувствуй, как спинка стула поддерживает тебя.",
        "Stay here a little longer. Feel the back of the chair supporting you.",
      ),
      (
        210,
        "Когда будешь готова, посмотри вокруг и реши, чем хочется заняться этим вечером.",
        "When you’re ready, look around and decide what you’d like to do this evening.",
      ),
    ],
  ),
  _Practice(
    id: 'time-for-sleep',
    scene: PracticeScene.moon,
    kind: _PracticeKind.meditation,
    minutes: 5,
    title: ("Когда пора спать", "When It’s Time for Sleep"),
    description: (
      "Голос ведёт внимание от звуков в комнате к ощущению подушки и одеяла.",
      "Let the voice guide your attention from sounds in the room to the feel of your pillow and blanket.",
    ),
    setup: ("Лёжа · без инвентаря", "Lying down · no equipment"),
    steps: [
      (
        0,
        "Ложись как удобно. Если положение хочется поменять, дай себе время устроиться.",
        "Lie down in a position that feels comfortable. Take a moment to settle in.",
      ),
      (
        36,
        "Почувствуй подушку под головой и одеяло там, где оно касается тела.",
        "Feel the pillow under your head and the blanket wherever it touches you.",
      ),
      (
        78,
        "Заметь, какие звуки слышны в комнате. Пусть они идут своим чередом.",
        "Notice the sounds in the room. Let them come and go.",
      ),
      (
        124,
        "Почувствуй, как лежат руки. Потом заметь стопы. Если им удобно, оставь их так.",
        "Notice how your hands are resting. Then notice your feet. If they’re comfortable, let them stay where they are.",
      ),
      (
        179,
        "Почувствуй несколько обычных вдохов и выдохов. Оставь дыхание таким, какое оно есть.",
        "Feel a few ordinary breaths. Let your breathing stay at its own pace.",
      ),
      (
        246,
        "Дальше ещё немного будет звучать музыка.",
        "The music will stay with you for a little while.",
      ),
    ],
  ),
  _Practice(
    id: 'easy-breathing-rhythm',
    scene: PracticeScene.bloom,
    kind: _PracticeKind.breathing,
    minutes: 2,
    title: ("Ровное дыхание", "An Easy Breathing Rhythm"),
    description: (
      "Несколько спокойных циклов под счёт. Затем можно вернуться к своему темпу. Дыши без усилия. Если закружится голова, прекрати упражнение.",
      "Follow a few gently counted breaths, then return to your own pace. Keep your breathing easy. Stop if you feel dizzy.",
    ),
    setup: ("Сидя · без инвентаря", "Seated · no equipment"),
    steps: [
      (
        0,
        "Сядь удобно. Заметь, как дышишь сейчас. Оставь вдох таким же лёгким.",
        "Sit comfortably. Notice how you’re breathing now. Let your inhale stay light and easy.",
      ),
      (
        20,
        "Если тебе удобно, попробуй вместе со мной. Вдох. Раз, два, три. Выдох. Раз, два, три.",
        "If it feels comfortable, try it with me. Inhale. One, two, three. Exhale. One, two, three.",
      ),
      (
        31,
        "Ещё раз. Вдох. Раз, два, три. Выдох. Раз, два, три.",
        "Once more. Inhale. One, two, three. Exhale. One, two, three.",
      ),
      (
        45,
        "Дальше дыши так, как тебе удобно. Можно остаться с этим ритмом или вернуться к своему.",
        "Now breathe however feels comfortable. You can stay with that rhythm or return to your own.",
      ),
      (
        101,
        "Заметь один обычный вдох и выдох. На этом закончим.",
        "Notice one ordinary inhale and exhale. We’ll finish there.",
      ),
    ],
  ),
  _Practice(
    id: 'gentle-exhale',
    scene: PracticeScene.moon,
    kind: _PracticeKind.breathing,
    minutes: 2,
    title: ("Мягкий выдох", "A Gentle Exhale"),
    description: (
      "Несколько мягких выдохов чуть длиннее вдоха, с возвращением к обычному дыханию. Не выталкивай воздух. Если закружится голова, прекрати упражнение.",
      "Try a few easy exhales that last a little longer than the inhale, then return to your regular breath. Avoid forcing the exhale. Stop if you feel dizzy.",
    ),
    setup: ("Сидя · без инвентаря", "Seated · no equipment"),
    steps: [
      (
        0,
        "Положи руки на бёдра. Сделай обычный вдох и выдох. Почувствуй, как тело дышит само.",
        "Rest your hands on your thighs. Take one ordinary breath in and out. Notice how your body breathes on its own.",
      ),
      (
        20,
        "Если удобно, сделай следующий выдох чуть длиннее. Заканчивай его, пока тебе всё ещё легко.",
        "If it feels comfortable, let your next exhale last a little longer. Finish it while it still feels easy.",
      ),
      (
        42,
        "Следующий вдох пусть начнётся сам. Если хочется, повтори ещё раз. В любой момент можно дышать как обычно.",
        "Let the next inhale begin on its own. Repeat once more if you like. You can breathe normally at any point.",
      ),
      (
        71,
        "Отпусти подсказку. Почувствуй несколько обычных вдохов и выдохов.",
        "Let go of the cue. Feel a few ordinary breaths.",
      ),
      (
        104,
        "Пошевели пальцами, почувствуй опору под стопами. На этом закончим.",
        "Wiggle your fingers and feel the ground under your feet. We’ll finish there.",
      ),
    ],
  ),
  _Practice(
    id: 'shake-off-the-day',
    scene: PracticeScene.ribbon,
    kind: _PracticeKind.movement,
    minutes: 2,
    title: ("Стряхнуть день", "Shake Off the Day"),
    description: (
      "Легко встряхни кисти и плечи под музыку, будто стряхиваешь капли воды.",
      "Gently shake out your hands and shoulders to the music, as if shaking water from your fingers.",
    ),
    setup: ("Стоя · без инвентаря", "Standing · no equipment"),
    steps: [
      (
        0,
        "Встань поудобнее. Представь, что только что вымыла руки и на кончиках пальцев остались капли. Мягко стряхни их. Ещё раз.",
        "Stand comfortably. Imagine you’ve just washed your hands and there are little drops on your fingertips. Gently shake them off. Once more.",
      ),
      (
        22,
        "Пусть руки висят свободно. Если приятно, добавь лёгкое движение плечами.",
        "Let your arms hang loosely. If it feels good, let your shoulders join in with a small movement.",
      ),
      (
        48,
        "Продолжай в своём ритме. Пусть движение будет таким небольшим, как тебе хочется.",
        "Keep going at your own pace. Let the movement be as small as you like.",
      ),
      (
        81,
        "Постепенно остановись. Опусти руки и постой ещё немного.",
        "Come to a gradual stop. Let your arms rest and stand still for a moment.",
      ),
      (
        103,
        "Заметь, как ощущаются пальцы, когда ты ими уже не двигаешь.",
        "Notice how your fingers feel now that they’re still.",
      ),
    ],
  ),
  _Practice(
    id: 'feel-the-difference',
    scene: PracticeScene.dawn,
    kind: _PracticeKind.massage,
    minutes: 3,
    title: ("Почувствуй разницу", "Feel the Difference"),
    description: (
      "Мягко прокатай стопы небольшим мячом и сравни ощущения после первой стороны. Давление должно быть лёгким. Пропусти упражнение при боли, травме или ране на стопе.",
      "Roll your feet gently over a small ball and compare how they feel after the first side. Keep the pressure light. Skip this exercise if your foot is painful, injured, or has an open wound.",
    ),
    setup: ("Сидя · стул и небольшой мяч", "Seated · chair and a small ball"),
    steps: [
      (
        0,
        "Сядь на стул и поставь обе стопы на пол. Подложи небольшой мяч под одну стопу.",
        "Sit in a chair with both feet on the floor. Place a small ball under one foot.",
      ),
      (
        18,
        "Медленно прокатай мяч вперёд и назад. Оставь давление лёгким.",
        "Slowly roll the ball forward and back. Keep the pressure light.",
      ),
      (
        66,
        "Откати мяч в сторону. Поставь обе стопы на пол. Они сейчас ощущаются одинаково?",
        "Roll the ball aside. Put both feet on the floor. Do they feel the same right now?",
      ),
      (
        93,
        "Если удобно, переложи мяч под другую стопу. Повтори то же лёгкое движение.",
        "If it feels comfortable, place the ball under your other foot and repeat the same easy movement.",
      ),
      (
        146,
        "Снова поставь обе стопы на пол. Побудь так немного и заметь, как каждая касается пола.",
        "Set both feet on the floor again. Stay there for a moment and notice how each foot meets the ground.",
      ),
    ],
  ),
  _Practice(
    id: 'cloud-hands',
    scene: PracticeScene.ribbon,
    kind: _PracticeKind.movement,
    minutes: 3,
    title: ("Облачные руки", "Cloud Hands"),
    description: (
      "Плавный перенос веса и мягкое движение ладоней из стороны в сторону.",
      "Shift your weight gently as your hands drift from side to side.",
    ),
    setup: ("Стоя · без инвентаря", "Standing · no equipment"),
    steps: [
      (
        0,
        "Встань устойчиво. Руки оставь свободными. Медленно перенеси немного веса на правую ногу. Обе стопы остаются на полу.",
        "Stand on steady feet and let your arms relax. Slowly shift a little weight to your right foot. Keep both feet on the floor.",
      ),
      (
        24,
        "Вернись к середине, потом чуть смести вес влево. Повтори ещё раз без спешки.",
        "Return to the middle, then shift gently to the left. Repeat slowly.",
      ),
      (
        49,
        "Если удобно, подними ладони перед собой. Когда вес уходит вправо, пусть ладони немного поплывут вправо. Когда вес уходит влево, веди их влево.",
        "If comfortable, raise your hands in front of you. As your weight moves right, let your hands drift a little to the right. As your weight moves left, let them drift left.",
      ),
      (
        88,
        "Найди свой темп. Можно оставить только перенос веса, если так приятнее.",
        "Find your own pace. You can keep just the weight shift if that feels better.",
      ),
      (
        142,
        "Верни вес к середине. Опусти руки. Заметь, как сейчас обе стопы стоят на полу.",
        "Come back to the middle and lower your hands. Notice how both feet meet the floor now.",
      ),
    ],
  ),
  _Practice(
    id: 'sadhu-board',
    scene: PracticeScene.dusk,
    kind: _PracticeKind.sadhu,
    minutes: 3,
    title: ("Гвоздестояние", "Sadhu Board Practice"),
    description: (
      "Тихая музыка и редкие голосовые подсказки для тех, кто уже умеет пользоваться доской садху. Для первого знакомства послушай запись сидя, без доски. Пропусти доску, если на стопах есть раны или снижена чувствительность.",
      "Quiet music and occasional cues for people already familiar with their Sadhu board. For your first session, listen seated without the board. Skip the board if you have open wounds or reduced feeling in your feet.",
    ),
    setup: (
      "Нужна доска садху и опыт практики",
      "Sadhu board and prior experience required",
    ),
    steps: [
      (
        0,
        "Это сопровождение для знакомой практики. Начни, когда будешь готова. Остановиться можно в любой момент, даже если музыка ещё играет.",
        "This track accompanies a practice you already know. Begin when you’re ready. You can finish at any point, even while the music is playing.",
      ),
      (
        44,
        "Заметь один обычный вдох и выдох. Дыши в своём темпе.",
        "Notice one ordinary breath in and out. Breathe at your own pace.",
      ),
      (
        86,
        "На несколько мгновений переведи внимание на музыку. Какой звук слышно яснее всего?",
        "For a few moments, listen to the music. Which sound comes through most clearly?",
      ),
      (
        131,
        "Проверь, хочется ли закончить. Ориентируйся на свои ощущения.",
        "Check whether you’d like to finish. Let your own sensations guide you.",
      ),
      (
        157,
        "Запись подходит к концу. Когда завершишь практику, оставь себе немного времени побыть в тишине.",
        "The recording is coming to an end. After you finish your practice, give yourself a little time to be still.",
      ),
    ],
  ),
];
