import 'package:asteria_app/app/data/models/prompt_response.dart';

/// Editorial prompts are kept separate from the server's pair interpretation.
enum RelationshipQuestion {
  closeness,
  support,
  deescalate,
  beHeard;

  String title(bool ru) => switch (this) {
    closeness => ru ? 'Как стать ближе?' : 'How can we feel closer?',
    support =>
      ru ? 'Как поддерживать друг друга?' : 'How can we support each other?',
    deescalate =>
      ru ? 'Как снизить напряжение?' : 'How can we ease the tension?',
    beHeard => ru ? 'Как услышать друг друга?' : 'How can we hear each other?',
  };

  String reading(CompatibilityData data) => switch (this) {
    closeness => data.loveCompatibility.trim(),
    support => data.familyCompatibility.trim(),
    deescalate || beHeard => data.conflicts.trim(),
  };

  String suggestion(bool ru) => switch (this) {
    closeness =>
      ru
          ? 'Начните с небольшого совместного момента: прогулки, ужина или десяти минут без телефонов. Спросите, в какие моменты партнёр чувствует вашу близость, и расскажите о своих.'
          : 'Choose a small shared moment: a walk, dinner or ten minutes without phones. Ask when your partner feels close to you, then share your own answer.',
    support =>
      ru
          ? 'Уточните, какая поддержка нужна сейчас: выслушать, помочь с делом или дать побыть одному. Договоритесь об одном посильном действии для каждого.'
          : 'Ask what support would help now: listening, practical help or some time alone. Agree on one manageable action for each of you.',
    deescalate =>
      ru
          ? 'Если разговор накаляется, предложите паузу и договоритесь, когда вернётесь к нему. После паузы выберите один конкретный эпизод и обсудите, что каждый почувствовал.'
          : 'If the conversation gets heated, suggest a pause and agree when to return. Then discuss one specific moment and how each of you felt.',
    beHeard =>
      ru
          ? 'Говорите по очереди об одном конкретном моменте. Прежде чем отвечать, коротко перескажите услышанное и уточните, правильно ли вы поняли друг друга.'
          : 'Take turns describing one specific moment. Before replying, briefly repeat what you heard and check that you understood each other.',
  };

  String opener(bool ru) => switch (this) {
    closeness =>
      ru
          ? 'В какой момент на этой неделе ты чувствовал или чувствовала, что мы близки?'
          : 'When this week did you feel close to me?',
    support =>
      ru
          ? 'Тебе сейчас важнее, чтобы я выслушала, помогла с делом или дала немного пространства?'
          : 'Would you like me to listen, help with something or give you some space?',
    deescalate =>
      ru
          ? 'Хочу вернуться к нашему разговору. Тебе удобнее сейчас или немного позже?'
          : 'I’d like to come back to our conversation. Is now a good time, or would later be better?',
    beHeard =>
      ru
          ? 'Давай я сначала расскажу, как тебя поняла, а ты поправишь, если я что-то упустила?'
          : 'Could I first tell you what I understood, and you can correct anything I missed?',
  };
}
