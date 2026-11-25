part of 'practice_catalog_screen.dart';

// Narration timings mirror the Russian recordings used to produce the English mixes.
const _longEnglishPracticeRecordings =
    <String, ({Duration duration, List<(double, String)> transcript})>{
      'unhurried-morning': (
        duration: Duration(seconds: 300),
        transcript: [
          (
            5.000,
            'Before you look at the clock, take a moment. If it feels right, turn your phone face down. Find a position where your back can rest. Let your hands settle.',
          ),
          (
            36.939,
            'Look at something still. A fold in the curtain, maybe. Or the light on the wall. If your eyes are closed, you can just sit.',
          ),
          (
            75.308,
            'What can you hear from where you are? Stay with the nearest sound for a while. When it fades, see what you can hear in the quiet.',
          ),
          (
            113.182,
            'Feel what’s under your feet. Shift a little to the right, then come back. Is there a way to sit that takes a little less effort? Lean back if you like.',
          ),
          (
            148.262,
            'What happens as you breathe out? Your shoulders might settle a little. Let the next few breaths come on their own, at whatever pace feels easy.',
          ),
          (
            189.901,
            'Maybe the day’s already lining itself up in your head. Look back at that patch of light. Has it moved since you last looked?',
          ),
          (
            221.743,
            'When this ends, what would you like to do first? Pour some water, perhaps. Open the window. Picture the first small movement. You have time for the rest of the morning.',
          ),
          (
            263.799,
            'Run your thumb across the tips of your fingers. What do you notice first? Sit up when you feel ready, or stay a little longer. Whenever you’re ready, begin with that one small thing.',
          ),
        ],
      ),
      'workday-is-over': (
        duration: Duration(seconds: 600),
        transcript: [
          (
            5.000,
            'If you work at the same table you eat at, try sitting somewhere else for a few minutes. You could turn your chair toward the window. Find something to rest your back against, and let your hands lie on your legs.',
          ),
          (
            56.051,
            'Sometimes work is over before it goes quiet in your head. Stay here while the music plays. If a deadline comes to mind, you can write it down later. For now, you have a few minutes in this room.',
          ),
          (
            118.049,
            'Feel the fabric under your hands. If your palm is resting on a seam, run a finger along it. The fabric under your other hand might feel smoother. Take a moment to notice.',
          ),
          (
            164.723,
            'Listen past the wall or out the window. If it’s quieter out there, stay with the sound closest to you. You might hear something farther away after a while.',
          ),
          (
            218.935,
            'Find the floor with both feet. Let your heels get a little heavier for a moment, then ease off. Keep your shoes on if you’re comfortable in them.',
          ),
          (
            270.504,
            'At work it’s easy to lean toward the screen out of habit. Look a little farther than you could reach. Find something your eyes can linger on. Let your gaze wander around its edges.',
          ),
          (
            327.066,
            'If bits of a conversation keep coming back, pick just one. What part of it is already over? If there’s anything left to sort out, it can wait here for another time.',
          ),
          (
            378.249,
            'How does your back feel now? A folded sweater might help, or you might want to move the chair. Take your time with it. Here’s one thing you can finish right where you are.',
          ),
          (
            423.553,
            'You can close your eyes while the music plays. See how your fingers settle when there’s nothing in them to hold. Give your hands a little time there.',
          ),
          (
            472.164,
            'Look around again. Is there something here that belongs just to your evening? A cup, a book on the sofa, your shoes by the door. Leave it where it is. Just notice it.',
          ),
          (
            526.233,
            'What would you like to do first this evening? Maybe you’d like a little time alone. Maybe you’d rather hear a familiar voice. See what you feel like now. You can decide about the rest later.',
          ),
          (
            577.625,
            'Wiggle your toes. If you’re getting up, give yourself another moment. The music is nearly over. Your evening has already begun.',
          ),
        ],
      ),
      'time-for-sleep': (
        duration: Duration(seconds: 720),
        transcript: [
          (
            5.021,
            'Lie down the way you usually fall asleep. If the pillow needs to come up a little, or you’d rather turn onto your other side, go ahead. Take your time getting comfortable.',
          ),
          (
            53.631,
            'Feel where the pillow meets your cheek or the back of your head. It’s slowly taking the shape of your head. Let yourself sink a little farther if that feels good.',
          ),
          (
            117.767,
            'Listen for the sound you can hear most clearly. It might be outside, or it might be the sheets moving, or someone breathing nearby. If the sound stays, you have time to get used to it.',
          ),
          (
            178.357,
            'Can you hear where that sound begins, or where it fades? There might be a short gap before the next one. All of it is part of the room you’re in.',
          ),
          (
            232.499,
            'How are your hands lying? Leave your fingers a little curled if that’s comfortable. One hand may be warmer than the other. Feel the difference for a moment and let them lie.',
          ),
          (
            283.733,
            'Let your attention drift down to your feet. You might feel air around them under the covers. Maybe the sheet touches one heel and misses the other. Let each foot rest the way it wants to.',
          ),
          (
            336.407,
            'If something you need to do tomorrow comes to mind, give it a name in a couple of words. You can leave it there until morning. Come back to the feel of the fabric against your legs.',
          ),
          (
            388.917,
            'Feel the blanket on your belly or chest. It may rise a little when you breathe in and settle again when you breathe out. Stay for a few breaths, each in its own time.',
          ),
          (
            455.114,
            'Find the pillow again. Your head may have shifted already. If you feel like moving a little more, go ahead. You’re still finding the way you want to lie.',
          ),
          (
            505.309,
            'There may be one familiar sound left in the room. You can listen for it now and then, like a sound outside the door. If your attention wanders, let it go.',
          ),
          (
            555.106,
            'If you’re still awake, you can just lie here. Is there somewhere you’d like a little more support? Tuck in the blanket or leave one foot out, whichever feels familiar.',
          ),
          (
            608.379,
            'I’ll leave the music playing a little longer. It may stay in the foreground or fade from your attention. You can rest just as you are.',
          ),
        ],
      ),
      'easy-breathing-rhythm': (
        duration: Duration(seconds: 180),
        transcript: [
          (
            3.188,
            'Sit somewhere you can rest your back. Let your hands lie on your thighs or the arms of the chair. Stay for a few breaths.',
          ),
          (
            25.026,
            'Notice a breath as it comes in by itself. Is the air cooler near your nose? Do you feel your ribs move? Stay with whichever is easier to feel.',
          ),
          (
            48.027,
            'We’ll count through two breaths. Keep them easy and use your usual rhythm if the count feels uncomfortable. If you feel dizzy, stop.',
          ),
          (66.022, 'Join me if it feels comfortable.'),
          (76.000, 'In. One, two, three. Out. One, two, three.'),
          (85.007, 'Once more, if that still feels easy.'),
          (94.000, 'In. One, two, three. Out. One, two, three.'),
          (
            107.028,
            'Let your breath find a pace that suits you. Notice how the next breath comes in without a cue.',
          ),
          (
            130.037,
            'What can you hear in the room? Listen for a few moments while your breathing carries on. Let your attention go wherever it goes.',
          ),
          (
            153.079,
            'Before you get up, feel your hands where you left them. Take an ordinary breath. You can sit here until the music ends.',
          ),
        ],
      ),
      'gentle-exhale': (
        duration: Duration(seconds: 180),
        transcript: [
          (
            3.052,
            'Sit comfortably and rest your palms on your thighs. Feel their weight. If you want to adjust your clothes or sit farther back, take a moment to get settled.',
          ),
          (
            26.331,
            'Breathe in and out as usual. Can you feel where the out-breath ends? Sometimes it’s clear. Sometimes the next breath is already there. Stay here for a few moments.',
          ),
          (
            51.029,
            'If it feels easy, let the next breath out last a little longer. Let the air go gently and stop while it’s still comfortable. If you feel dizzy, stop the exercise.',
          ),
          (
            77.572,
            'Let the next breath come in on its own. Take an ordinary breath before you decide whether you’d like to try again. You can go back to breathing normally at any point.',
          ),
          (
            102.064,
            'If you try again, let the air go for as long as it flows freely. Breathe in as soon as you want to. Then let your breathing settle back into its usual rhythm.',
          ),
          (
            128.045,
            'Stay for a few ordinary breaths. Maybe the fabric under your hands has warmed up. You can move your hands if you’d like. Listen to the music for a while.',
          ),
          (
            153.054,
            'Move your fingers and feel the floor under your feet again. Look around when you’re ready. You can stay seated and listen a little longer.',
          ),
        ],
      ),
      'shake-off-the-day': (
        duration: Duration(seconds: 210),
        transcript: [
          (
            3.027,
            'Stand somewhere your arms can hang freely. Feel the floor under both feet. Leave your hands at your sides for a while. Let the music play as you get used to standing here.',
          ),
          (
            25.075,
            'Imagine you’ve just washed your hands. There are still drops on your fingertips. Shake them off gently, then let your wrists rest. Try that once more, as lightly as you like.',
          ),
          (
            50.063,
            'Stand with your arms down. Do both hands feel like moving the same amount? If one barely moves, let it be. You can shake one hand at a time.',
          ),
          (
            78.057,
            'Let your wrists move again. Keep your elbows loose. Your shoulders can join in a little, if that feels good. Between movements, let your arms hang by their own weight.',
          ),
          (
            110.054,
            'Find a rhythm you like. Try two small shakes, then pause. You can repeat that in a moment. Listen while you decide whether you want to move again.',
          ),
          (
            151.061,
            'Make the movements smaller and let your hands come down. Stand quietly for as long as you like. Pick a place for your eyes to rest. Let your fingers come to a stop.',
          ),
          (
            180.030,
            'What can you feel in your fingertips now? Maybe a little warmth. Maybe just the air. Wait a moment before you decide where to go next.',
          ),
        ],
      ),
      'feel-the-difference': (
        duration: Duration(seconds: 240),
        transcript: [
          (
            3.054,
            'Sit on a chair with both feet on the floor. Set a small ball within reach. Skip this exercise if you have pain, an injury, or a wound on your foot.',
          ),
          (
            26.028,
            'Leave the ball where it is for now. Where do you feel the floor most clearly, under your heels or closer to your toes? Notice how each foot meets it.',
          ),
          (
            53.051,
            'Put the ball under one foot. Roll it slowly forward and back with light pressure. Keep the movement small if that feels better. You can stop and start again while the music plays.',
          ),
          (
            104.045,
            'Roll the ball away and put both feet down. Wait a moment before you compare them. Does anything feel different under your heels or toes? What feels the same as before?',
          ),
          (
            132.042,
            'If you like, put the ball under the other foot. Roll it lightly forward and back. This side may prefer a smaller movement. You can set the ball aside and rest at any point.',
          ),
          (
            184.024,
            'Bring both feet back to the floor. How does the floor feel now? You can notice one foot, then the other, and then both at once.',
          ),
          (
            216.178,
            'Leave the ball beside you. Take another moment to sit and feel the floor under your feet before you finish.',
          ),
        ],
      ),
      'cloud-hands': (
        duration: Duration(seconds: 210),
        transcript: [
          (
            3.059,
            'Find a steady place to stand. Let your arms hang and put your feet wherever it feels easy to stand. Give yourself a moment to feel the floor. Let your eyes rest somewhere in front of you.',
          ),
          (
            27.051,
            'Move a little of your weight onto your right leg. Keep both feet on the floor. Come back to the middle, pause, then shift a little to the left. Find the middle again.',
          ),
          (
            53.046,
            'Repeat at your own pace. Feel how the pressure changes under each foot. A small shift is enough. When you come to the middle, notice the moment both feet share the weight again.',
          ),
          (
            80.030,
            'If it feels comfortable, bring your hands up in front of you. Let them drift right as your weight shifts right, and left as you shift left. Keep your hands low and close if you like.',
          ),
          (
            119.059,
            'Find a pace that makes it easy to come back to the middle. You can move just your weight and let your hands rest. Stay with whichever feels good for a while.',
          ),
          (
            153.027,
            'Finish the movement you’ve already begun. Come back to the middle and lower your hands. Let them grow still. Your eyes can stay where they are a little longer.',
          ),
          (
            183.044,
            'Feel the floor beneath both feet again. You can finish the music standing, or find somewhere to sit and listen.',
          ),
        ],
      ),
      'sadhu-board': (
        duration: Duration(seconds: 180),
        transcript: [
          (
            3.064,
            'Start seated and listen to the music. This recording is for people who already know how to use a Sadhu board. If you’re new to it, stay seated without the board. Skip the board if you have wounds or reduced sensation in your feet.',
          ),
          (
            26.029,
            'Feel the chair beneath you. Rest your hands on your thighs if you like. Listen for the sound nearest to you. You can stay seated for the whole practice.',
          ),
          (
            50.059,
            'If you’ve chosen to use the board as you normally would, begin when you’re ready. You can stop whenever you like. The music continues either way.',
          ),
          (
            71.035,
            'Notice one ordinary breath in and out. Keep your own pace. If you feel ready to stop, stop now. You can listen to the rest of the music sitting down.',
          ),
          (
            88.052,
            'Come back to your seat if you haven’t already. Feel how the chair holds your weight. Let your hands rest. Find one sound in the music you can hear more clearly than the others.',
          ),
          (
            122.655,
            'Listen as that sound changes or fades. You can get more comfortable and stay seated for a little longer. If another sound catches your ear, follow it for a while.',
          ),
          (
            159.015,
            'When the music fades, stay with the quiet for a moment. Get up when you’re ready.',
          ),
        ],
      ),
    };
