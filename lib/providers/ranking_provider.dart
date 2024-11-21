// lib/providers/ranking_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/rank_entry.dart';
import '../models/evento.dart';

class RankingProvider extends ChangeNotifier {
  final Evento evento;
  List<RankEntry> _ranking = [];
  bool _isLoading = true;
  String? _error;

  List<RankEntry> get ranking => _ranking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RankingProvider({required this.evento}) {
    fetchRanking();
  }

  Future<void> fetchRanking() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Referência à coleção 'user_progress'
      CollectionReference userProgressRef =
          FirebaseFirestore.instance.collection('user_progress');

      // Buscar todos os documentos de progresso dos usuários
      QuerySnapshot userProgressSnapshot = await userProgressRef.get();

      List<RankEntry> tempRanking = [];

      // Número total de fases no evento
      int totalFases = evento.fases.length;

      // Coletar dados de progresso dos usuários
      List<Map<String, dynamic>> userFaseData = [];

      for (var doc in userProgressSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String userId = data['user_id'];

        Map<String, dynamic> eventosFasesCompletadas =
            data['eventos_fases_completadas'] != null
                ? Map<String, dynamic>.from(data['eventos_fases_completadas'])
                : {};

        // Obter a lista de fases concluídas para este evento
        List<dynamic> fasesConcluidas =
            eventosFasesCompletadas[evento.id] != null
                ? List<dynamic>.from(eventosFasesCompletadas[evento.id])
                : [];

        int fasesConcluidasCount = fasesConcluidas.length;

        userFaseData.add({
          'userId': userId,
          'fasesConcluidas': fasesConcluidasCount,
        });
      }

      // Extrair todos os userIds
      List<String> userIds =
          userFaseData.map((e) => e['userId'] as String).toList();

      // Firestore 'whereIn' suporta até 10 itens. Buscar em lotes.
      List<RankEntry> fetchedRanking = [];

      const int batchSize = 10;
      for (int i = 0; i < userIds.length; i += batchSize) {
        List<String> batch = userIds.skip(i).take(batchSize).toList();

        QuerySnapshot userDocs = await FirebaseFirestore.instance
            .collection('usuarios') // Alterado aqui
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        Map<String, dynamic> usersData = {
          for (var doc in userDocs.docs)
            doc.id: doc.data() as Map<String, dynamic>
        };

        for (var userFase in userFaseData) {
          String userId = userFase['userId'];
          int fasesConcluidas = userFase['fasesConcluidas'];

          if (usersData.containsKey(userId)) {
            Map<String, dynamic> userData = usersData[userId];
            String nomeCompleto = userData['nome_completo'] ?? 'Usuário';
            String? photoURL = userData['photoURL'];

            RankEntry entry = RankEntry(
              userId: userId,
              nomeCompleto: nomeCompleto,
              photoURL: photoURL,
              fasesConcluidas: fasesConcluidas,
              totalFases: totalFases,
            );

            fetchedRanking.add(entry);
          }
        }
      }

      // Ordenar o ranking por fasesConcluidas descrescente
      fetchedRanking
          .sort((a, b) => b.fasesConcluidas.compareTo(a.fasesConcluidas));

      _ranking = fetchedRanking;
    } catch (e) {
      _error = 'Erro ao carregar ranking: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
