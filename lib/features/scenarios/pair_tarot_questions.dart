/// A conversation starter for each illustration in the standard daily deck.
const pairTarotQuestions = <String, ({String ru, String en})>{
  'the_fool': (
    ru: 'Что тебе хотелось бы впервые попробовать вместе, даже если мы оба будем новичками?',
    en: 'What would you like us to try together for the first time, even if we’re both beginners?',
  ),
  'the_magician': (
    ru: 'Что у нас здорово получается именно вдвоём? Какой талант каждый из нас туда привносит?',
    en: 'What are we especially good at doing together? What talent does each of us bring to it?',
  ),
  'the_high_priestess': (
    ru: 'В какой момент мы поняли друг друга без слов? Что это был за взгляд или жест?',
    en: 'When did we understand each other without speaking? What look or gesture gave it away?',
  ),
  'the_empress': (
    ru: 'Какая мелочь дома помогает тебе почувствовать, что о тебе позаботились?',
    en: 'What little thing at home makes you feel cared for?',
  ),
  'the_emperor': (
    ru: 'Какая наша договорённость даёт тебе чувство надёжности? Почему она для тебя важна?',
    en: 'Which promise or arrangement between us gives you a sense of security? Why does it matter to you?',
  ),
  'the_hierophant': (
    ru: 'Какую традицию из твоей семьи тебе хочется продолжить вдвоём, а какую придумать с нуля?',
    en: 'Which family tradition would you like us to carry on, and what tradition could we start from scratch?',
  ),
  'the_lovers': (
    ru: 'Когда нам пришлось сделать выбор вдвоём, что оказалось важным для нас обоих?',
    en: 'Think of a choice we made together. What mattered to both of us?',
  ),
  'the_chariot': (
    ru: 'К какой цели ты хотел бы двигаться вместе? Как мы поймём, что держим удобный для обоих темп?',
    en: 'What goal would you like us to work toward together? How will we know the pace feels right for both of us?',
  ),
  'the_strength': (
    ru: 'Когда я помог тебе собраться просто тем, как вёл себя рядом? Что именно помогло?',
    en: 'When did the way I was with you help you find your courage? What made the difference?',
  ),
  'the_hermit': (
    ru: 'Когда тебе хочется тишины и времени наедине с собой, как лучше дать мне об этом знать?',
    en: 'When you need quiet time on your own, how would you like to let me know?',
  ),
  'wheel_of_fortune': (
    ru: 'Какой случайный поворот стал важной частью нашей истории?',
    en: 'What unexpected turn became an important part of our story?',
  ),
  'justice': (
    ru: 'Какое наше общее дело сейчас поделено справедливо? Что помогло так договориться?',
    en: 'Which shared responsibility feels fairly divided right now? How did we find that balance?',
  ),
  'the_hanged_man': (
    ru: 'Как выглядел один и тот же день с твоей стороны и с моей? Что каждый из нас тогда упустил?',
    en: 'Pick a day we spent together. How did it look from each side, and what did each of us miss?',
  ),
  'death': (
    ru: 'Какой этап нашей жизни вдвоём уже закончился? Что из него всё-таки хочется взять с собой?',
    en: 'What chapter of our life together has ended? What would you still like us to carry forward from it?',
  ),
  'temperance': (
    ru: 'В чём наши разные привычки хорошо дополняют друг друга?',
    en: 'Where do our different habits complement each other?',
  ),
  'the_devil': (
    ru: 'Какую привычку мы по инерции повторяем вдвоём, хотя давно хотим проводить это время иначе?',
    en: 'What do we keep doing together out of habit when we’d both rather spend that time differently?',
  ),
  'the_tower': (
    ru: 'Вспомни, как сорвался наш общий план. Что помогло нам справиться с первым разочарованием?',
    en: 'Think of a plan of ours that fell apart. What helped us through the first wave of disappointment?',
  ),
  'the_star': (
    ru: 'О чём нам приятно мечтать вместе, даже если пока совсем неясно, как это устроить?',
    en: 'What do you enjoy dreaming about with me, even if we have no idea yet how to make it happen?',
  ),
  'the_moon': (
    ru: 'Что тебе иногда приходится угадывать по моему настроению? Какой вопрос проще было бы задать прямо?',
    en: 'What do you sometimes try to guess from my mood? What could you ask me directly instead?',
  ),
  'the_sun': (
    ru: 'Когда мы в последний раз смеялись до слёз? Какая деталь до сих пор тебя смешит?',
    en: 'When did we last laugh until we cried? Which detail still makes you laugh?',
  ),
  'judgement': (
    ru: 'Что ты теперь по-другому понимаешь о наших первых месяцах вместе?',
    en: 'What do you understand differently now about our first months together?',
  ),
  'the_world': (
    ru: 'Что мы довели до конца вместе и ещё толком не отпраздновали?',
    en: 'What have we finished together that we haven’t properly celebrated yet?',
  ),
  'ace_of_cups': (
    ru: 'Когда у тебя в последнее время неожиданно возникло чувство нежности ко мне?',
    en: 'When have you felt an unexpected rush of affection for me lately?',
  ),
  'two_of_cups': (
    ru: 'В какой момент ты особенно ясно почувствовал взаимность между нами?',
    en: 'When did you feel especially sure that the affection between us went both ways?',
  ),
  'three_of_cups': (
    ru: 'С кем из наших друзей или близких тебе особенно радостно проводить время вдвоём со мной?',
    en: 'Which friends or loved ones do you especially enjoy spending time with as a couple?',
  ),
  'four_of_cups': (
    ru: 'Как можно пригласить тебя побыть вместе в день, когда тебе ничего не хочется?',
    en: 'On a day when nothing appeals, what kind of invitation to spend time together might feel welcome?',
  ),
  'five_of_cups': (
    ru: 'Когда что-то тебя огорчает, как мне дать тебе погрустить рядом со мной?',
    en: 'When something lets you down, how can I make room for you to feel sad with me?',
  ),
  'six_of_cups': (
    ru: 'Какой обычный день из начала наших отношений ты бы с удовольствием прожил ещё раз?',
    en: 'Which ordinary day from early in our relationship would you happily live through again?',
  ),
  'seven_of_cups': (
    ru: 'Мы наверняка много раз говорили «когда-нибудь». Какую из этих идей ты бы выбрал для нас первой?',
    en: 'We’ve probably said “someday” about a lot of things. Which of those ideas would you pick for us first?',
  ),
  'eight_of_cups': (
    ru: 'Какой привычный совместный досуг тебе уже не так интересен? Чем бы ты хотел его заменить?',
    en: 'What do we often do together that you’ve outgrown? What would you like to try in its place?',
  ),
  'nine_of_cups': (
    ru: 'Из каких маленьких удовольствий сложился бы твой идеальный вечер со мной?',
    en: 'Which little pleasures would make up your ideal evening with me?',
  ),
  'ten_of_cups': (
    ru: 'Представь наш обычный счастливый день через несколько лет. Что происходит за завтраком?',
    en: 'Picture an ordinary happy day together a few years from now. What’s happening at breakfast?',
  ),
  'page_of_cups': (
    ru: 'Какая неожиданная записка, шутка или маленькая глупость от меня могла бы тебя сегодня порадовать?',
    en: 'What unexpected note, joke or bit of silliness from me would make you smile today?',
  ),
  'knight_of_cups': (
    ru: 'На какое свидание тебе хочется пригласить меня просто так, без особого повода?',
    en: 'What date would you like to take me on just because?',
  ),
  'queen_of_cups': (
    ru: 'Как ты понимаешь, что я действительно слушаю? Вспомни один наш разговор.',
    en: 'How can you tell I’m really listening? Think back to a conversation we’ve had.',
  ),
  'king_of_cups': (
    ru: 'Что помогает тебе говорить со мной о сильных чувствах, когда трудно подобрать слова?',
    en: 'What helps you talk to me about a strong feeling when it’s hard to find the words?',
  ),
  'ace_of_pentacles': (
    ru: 'Какое небольшое приобретение или улучшение дома принесло бы радость нам обоим?',
    en: 'What small purchase or change at home would bring both of us some joy?',
  ),
  'two_of_pentacles': (
    ru: 'Как нам выкроить время друг для друга в неделю, когда наши расписания совсем не совпадают?',
    en: 'How could we make time for each other in a week when our schedules barely overlap?',
  ),
  'three_of_pentacles': (
    ru: 'Если бы завтра мы взялись за общее дело, какую часть ты бы с радостью взял на себя, а какую доверил мне?',
    en: 'If we took on a project together tomorrow, which part would you enjoy and which would you hand to me?',
  ),
  'four_of_pentacles': (
    ru: 'Какую вещь, привычку или маленький уголок тебе важно оставить только для себя?',
    en: 'What possession, habit or little corner is important for you to keep just for yourself?',
  ),
  'five_of_pentacles': (
    ru: 'Когда не хватает сил или денег, в чём тебе бывает труднее всего попросить меня о помощи?',
    en: 'When energy or money is tight, what kind of help is hardest for you to ask me for?',
  ),
  'six_of_pentacles': (
    ru: 'Вспомни, когда моя помощь пришлась особенно кстати. Как ты понял, что я рядом?',
    en: 'Think of a time my help came just when you needed it. How did you know I was there for you?',
  ),
  'seven_of_pentacles': (
    ru: 'Во что мы давно вкладываем силы? По какой маленькой перемене ты замечаешь, что это даёт плоды?',
    en: 'What have we been putting time into for a while? What small change tells you it’s paying off?',
  ),
  'eight_of_pentacles': (
    ru: 'Чему тебе хотелось бы научиться у меня, и чему ты мог бы научить меня в ответ?',
    en: 'What would you like to learn from me, and what could you teach me in return?',
  ),
  'nine_of_pentacles': (
    ru: 'Какому твоему личному увлечению стоит выделить побольше места в нашей общей жизни?',
    en: 'Which interest of your own would you like to make more room for in our life together?',
  ),
  'ten_of_pentacles': (
    ru: 'Какую историю о нас ты бы хотел однажды рассказывать за большим семейным столом?',
    en: 'What story about us would you like to tell around a family table one day?',
  ),
  'page_of_pentacles': (
    ru: 'Какой первый маленький шаг к нашей общей цели мы могли бы сделать на этой неделе?',
    en: 'What small first step toward a shared goal could we take this week?',
  ),
  'knight_of_pentacles': (
    ru: 'Какое моё повседневное дело ты особенно ценишь, хотя мы редко о нём говорим?',
    en: 'Which of my everyday routines means a lot to you, even though we rarely mention it?',
  ),
  'queen_of_pentacles': (
    ru: 'Какой запах, вкус или звук напоминает тебе, что дома тебя ждут?',
    en: 'What smell, taste or sound makes you feel that there’s a welcome waiting for you at home?',
  ),
  'king_of_pentacles': (
    ru: 'На что общее тебе хотелось бы откладывать понемногу? Что изменится для нас, когда накопим?',
    en: 'What would you like us to save up for little by little? What will it make possible for us?',
  ),
  'ace_of_swords': (
    ru: 'Что важное о себе тебе хочется сказать мне одной простой фразой?',
    en: 'What’s one important thing about yourself that you’d like to tell me in a single sentence?',
  ),
  'two_of_swords': (
    ru: 'Какое решение мы откладываем? Что тебе важно узнать, прежде чем его принять?',
    en: 'What decision have we been putting off? What would you like to know before we make it?',
  ),
  'three_of_swords': (
    ru: 'Если мои слова случайно заденут тебя, как мне лучше начать разговор об этом?',
    en: 'If my words accidentally hurt you, how would you like me to open a conversation about it?',
  ),
  'four_of_swords': (
    ru: 'Как выглядит отдых вдвоём, после которого у тебя действительно прибавляется сил?',
    en: 'What kind of time resting together leaves you feeling genuinely recharged?',
  ),
  'five_of_swords': (
    ru: 'По какому признаку ты замечаешь, что в споре мы уже стараемся победить? Как нам в этот момент остановиться?',
    en: 'How do you know when we’ve started trying to win an argument? How could we call a pause then?',
  ),
  'six_of_swords': (
    ru: 'Что помогло нам вернуться к обычной жизни после трудной недели?',
    en: 'What helped us ease back into everyday life after a tough week?',
  ),
  'seven_of_swords': (
    ru: 'О чём тебе проще написать мне в сообщении, чем сказать вслух? Что делает переписку удобнее?',
    en: 'What feels easier to tell me in a message than out loud? What makes writing it easier?',
  ),
  'eight_of_swords': (
    ru: 'Какое неписаное правило нашей пары тебе хочется пересмотреть вместе?',
    en: 'What unwritten rule in our relationship would you like us to rethink together?',
  ),
  'nine_of_swords': (
    ru: 'Когда одна и та же тревожная мысль возвращается вечером, какая поддержка от меня тебе помогает?',
    en: 'When the same worry comes back at night, what kind of support from me helps?',
  ),
  'ten_of_swords': (
    ru: 'Как мы поймём, что старый спор для обоих закончен и к нему можно больше не возвращаться?',
    en: 'How will we know an old argument feels settled for both of us and we can let it rest?',
  ),
  'page_of_swords': (
    ru: 'Что тебе давно любопытно обо мне, но подходящего случая спросить ещё не было?',
    en: 'What have you been curious about but never found a good moment to ask me?',
  ),
  'knight_of_swords': (
    ru: 'Какую фразу нам стоит взять за сигнал, что разговор идёт слишком быстро и хочется замедлиться?',
    en: 'What phrase could we use when a conversation is moving too fast and one of us wants to slow down?',
  ),
  'queen_of_swords': (
    ru: 'Как мне лучше сказать тебе «нет», чтобы отказ был понятен и между нами осталось тепло?',
    en: 'How would you like me to say no so that my answer is clear and you still feel close to me?',
  ),
  'king_of_swords': (
    ru: 'Как мы могли бы решать вопрос, в котором для нас важны разные вещи и у каждого есть веские доводы?',
    en: 'How could we make a decision when we care about different things and both have a good case?',
  ),
  'ace_of_wands': (
    ru: 'Какая новая идея в последнее время так тебя зажгла, что хочется увлечь ею и меня?',
    en: 'What new idea has excited you so much lately that you’d love to get me involved?',
  ),
  'two_of_wands': (
    ru: 'Если бы у нас освободились выходные и перед нами лежала карта, куда бы ты предложил отправиться?',
    en: 'If we had a free weekend and a map in front of us, where would you suggest going?',
  ),
  'three_of_wands': (
    ru: 'Какого события в нашем ближайшем будущем ты ждёшь с особенным предвкушением?',
    en: 'What coming event in our life together are you especially looking forward to?',
  ),
  'four_of_wands': (
    ru: 'Какую маленькую годовщину или личную дату нам было бы приятно отмечать по-своему?',
    en: 'What small anniversary or date that means something to us would you like to celebrate in our own way?',
  ),
  'five_of_wands': (
    ru: 'В чём нам весело соревноваться друг с другом? Где для тебя заканчивается азарт?',
    en: 'What do we love competing with each other over? When does it stop being fun for you?',
  ),
  'six_of_wands': (
    ru: 'За какую свою недавнюю победу тебе хотелось бы услышать от меня «я тобой горжусь»?',
    en: 'What recent win of yours would you love to hear me say I’m proud of?',
  ),
  'seven_of_wands': (
    ru: 'Когда у других есть своё мнение о нашей паре, в каком вопросе тебе особенно важна моя поддержка?',
    en: 'When other people have opinions about our relationship, where would you most like me to back you up?',
  ),
  'eight_of_wands': (
    ru: 'Какое короткое сообщение от меня посреди занятого дня попадает точно в цель?',
    en: 'What short message from me would hit just the right note in the middle of a busy day?',
  ),
  'nine_of_wands': (
    ru: 'Как ты даёшь понять, что силы на исходе? Что мне стоит замечать чуть раньше?',
    en: 'How do you show you’re running low on energy? What would you like me to notice a little sooner?',
  ),
  'ten_of_wands': (
    ru: 'Что из твоего списка дел я мог бы взять на себя на этой неделе, чтобы тебе стало легче?',
    en: 'What could I take off your to-do list this week to lighten your load?',
  ),
  'page_of_wands': (
    ru: 'Какое спонтанное приглашение от меня заставило бы тебя прямо сейчас отложить дела?',
    en: 'What spur-of-the-moment invitation from me would tempt you to put everything down right now?',
  ),
  'knight_of_wands': (
    ru: 'Какое наше маленькое приключение началось с чьего-то «а давай»? Что тебе в нём запомнилось?',
    en: 'What little adventure of ours started with one of us saying “let’s just go”? What stuck with you?',
  ),
  'queen_of_wands': (
    ru: 'За каким занятием ты чувствуешь себя особенно уверенно? Как мне разделить с тобой эту радость?',
    en: 'What makes you feel especially confident when you’re doing it? How could I share in that joy?',
  ),
  'king_of_wands': (
    ru: 'Какое большое общее дело тебе хотелось бы однажды начать? Чем ты мог бы увлечь меня в этой задумке?',
    en: 'What ambitious project would you love us to start one day? What about it do you think would draw me in?',
  ),
};
