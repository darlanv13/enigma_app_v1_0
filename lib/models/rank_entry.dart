// lib/models/rank_entry.dart

class RankEntry {
  final String userId;
  final String nomeCompleto;
  final String? photoURL;
  final int fasesConcluidas;
  final int totalFases;

  RankEntry({
    required this.userId,
    required this.nomeCompleto,
    this.photoURL,
    required this.fasesConcluidas,
    required this.totalFases,
  });
}
