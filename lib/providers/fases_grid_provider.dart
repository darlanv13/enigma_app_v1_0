// lib/providers/fases_grid_provider.dart

import 'package:enigma_app_v1_0/models/evento.dart';
import 'package:enigma_app_v1_0/models/user_progress.dart';
import 'package:enigma_app_v1_0/providers/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FasesGridProvider extends ChangeNotifier {
  final Evento evento;
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProgress? userProgress;
  bool isLoading = true;
  String? nomeCompleto;
  String? photoURL;
  String? errorMessage;
  Map<String, dynamic>? userData;

  FasesGridProvider({required this.evento}) {
    _fetchUserDataAndProgress();
  }

  Future<void> _fetchUserDataAndProgress() async {
    final user = _auth.currentUser;
    if (user == null) {
      errorMessage = 'Usuário não autenticado';
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Buscar dados do usuário
      Map<String, dynamic>? userData = await _userService.getUserData(user.uid);
      if (userData != null) {
        nomeCompleto =
            userData['nome_completo'] ?? user.displayName ?? 'Usuário';
        photoURL = userData['photoURL'] ?? user.photoURL;
      } else {
        nomeCompleto = user.displayName ?? 'Usuário';
        photoURL = user.photoURL;
      }

      // Buscar progresso do usuário
      userProgress = await _userService.getUserProgress(user.uid);
      if (userProgress == null) {
        await _userService.createUserProgress(user.uid);
        userProgress =
            UserProgress(userId: user.uid, eventosFasesCompletadas: {});
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Erro ao carregar dados';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica se a fase está desbloqueada com base no progresso do usuário
  bool isFaseDesbloqueada(int faseIndex) {
    if (faseIndex == 0) return true; // A primeira fase está sempre disponível

    if (userProgress == null) return false;

    String eventoIdStr = evento.id.toString();

    // Acessa a lista de fases concluídas
    List<dynamic>? fasesConcluidas =
        userProgress!.eventosFasesCompletadas[eventoIdStr];
    if (fasesConcluidas == null) return false;

    // Verifica se a fase anterior foi concluída
    return fasesConcluidas.contains(faseIndex - 1);
  }

  /// Verifica se a fase já foi concluída
  bool isFaseConcluida(int faseIndex) {
    if (userProgress == null) return false;

    String eventoIdStr = evento.id.toString();
    List<dynamic>? fasesConcluidas =
        userProgress!.eventosFasesCompletadas[eventoIdStr];
    if (fasesConcluidas == null) return false;

    return fasesConcluidas.contains(faseIndex);
  }

  /// Método para recarregar os dados (por exemplo, após retornar de outra página)
  Future<void> reloadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    await _fetchUserDataAndProgress();
  }
}
