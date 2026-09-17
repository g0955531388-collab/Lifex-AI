/// =============================================================
/// Lifex-AI — وحدة الصوت
/// الملف: conversation_manager.dart
/// حوار قصير: سؤال توضيحي وتذكّر السياق، من سيناريو وحدة الصوت.
/// =============================================================
library lifex_ai.features.voice.conversation_manager;

enum ConversationPrompt { none, healthAspect }

class ConversationManager {
  ConversationPrompt pending = ConversationPrompt.none;
  String lastLanguageCode = 'ar';

  void rememberLanguage(String code) {
    lastLanguageCode = code;
  }

  bool get waitingForClarification => pending != ConversationPrompt.none;

  void askHealthAspect() {
    pending = ConversationPrompt.healthAspect;
  }

  void clear() {
    pending = ConversationPrompt.none;
  }

  String clarificationQuestion() {
    if (lastLanguageCode.startsWith('ar')) {
      return 'أي جانب تقصد؟ الأدوية، التحاليل، أم الملف الصحي؟';
    }
    return 'Which part: medications, lab results, or your health profile?';
  }
}
