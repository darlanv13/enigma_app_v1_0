class UserProgress {
  String userId;
  Map<String, List<dynamic>> eventosFasesCompletadas;

  UserProgress({
    required this.userId,
    required this.eventosFasesCompletadas,
    required Map eventosFasesProgresso,
  });

  factory UserProgress.fromMap(Map<String, dynamic> data) {
    Map<String, List<dynamic>> eventosFasesCompletadas = {};
    if (data['eventos_fases_completadas'] != null) {
      data['eventos_fases_completadas'].forEach((key, value) {
        if (value is List<dynamic>) {
          eventosFasesCompletadas[key] = List<dynamic>.from(value);
        }
      });
    }

    return UserProgress(
      userId: data['user_id'] ?? '',
      eventosFasesCompletadas: eventosFasesCompletadas,
      eventosFasesProgresso: {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'eventos_fases_completadas': eventosFasesCompletadas,
    };
  }
}
