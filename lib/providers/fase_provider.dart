// lib/providers/fase_provider.dart

import 'package:enigma_app_v1_0/models/evento.dart';
import 'package:enigma_app_v1_0/models/user_progress.dart';
import 'package:enigma_app_v1_0/providers/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class FaseProvider extends ChangeNotifier {
  final Evento evento;
  final int faseIndex;
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Fase faseAtual;
  int perguntaIndex = 0;
  String? nomeCompleto;
  String? photoURL;
  bool isLoadingUserData = true;
  UserProgress? userProgress;

  // Adicionando a declaração de userData
  Map<String, dynamic>? userData;

  // Controle de tentativas
  bool _podeTentarNovamente = true;
  int _segundosRestantes = 0;
  Timer? _timer;

  // Resposta do usuário
  String respostaUsuario = '';
  bool acertou = false;
  bool mostrandoFeedback = false;
  bool verificandoResposta = false;

  // Animação
  // ignore: unused_field
  late AnimationController _animationController;
  late Animation<double> fadeAnimation;

  FaseProvider({required this.evento, required this.faseIndex}) {
    faseAtual = evento.fases[faseIndex];
    _fetchUserDataAndProgress();
  }

  Future<void> _fetchUserDataAndProgress() async {
    final user = _auth.currentUser;
    if (user == null) {
      // O tratamento de redirecionamento deve ser feito na UI
      isLoadingUserData = false;
      notifyListeners();
      return;
    }

    try {
      // Buscar dados do usuário
      userData = await _userService.getUserData(user.uid);
      if (userData != null) {
        nomeCompleto =
            userData!['nome_completo'] ?? user.displayName ?? 'Usuário';
        photoURL = userData!['photoURL'] ?? user.photoURL;
      } else {
        nomeCompleto = user.displayName ?? 'Usuário';
        photoURL = user.photoURL;
      }

      // Buscar progresso do usuário
      userProgress = await _userService.getUserProgress(user.uid);
      if (userProgress == null) {
        await _userService.createUserProgress(user.uid);
        userProgress = UserProgress(
            userId: user.uid,
            eventosFasesCompletadas: {},
            eventosFasesProgresso: {});
      }

      isLoadingUserData = false;
      notifyListeners();
    } catch (e) {
      print('Erro ao buscar dados do usuário ou progresso: $e');
      isLoadingUserData = false;
      notifyListeners();
      // O tratamento de erro com SnackBar deve ser feito na UI
    }
  }

  // Métodos para verificar resposta, avançar para próxima pergunta, etc.
  Future<bool> verificarResposta(String resposta) async {
    if (resposta.trim().isEmpty) {
      return false;
    }

    verificandoResposta = true;
    notifyListeners();

    // Simula um tempo de processamento
    await Future.delayed(Duration(seconds: 1));

    String respostaCorreta =
        faseAtual.perguntas[perguntaIndex].resposta.toLowerCase().trim();
    String respostaUsuarioLocal = resposta.toLowerCase().trim();

    acertou = respostaUsuarioLocal == respostaCorreta;
    mostrandoFeedback = true;
    verificandoResposta = false;
    notifyListeners();

    if (acertou) {
      await proximaPergunta();
    } else {
      iniciarTemporizadorTentativa();
    }

    return acertou;
  }

  void iniciarTemporizadorTentativa() {
    _podeTentarNovamente = false;
    _segundosRestantes = 120; // 2 minutos em segundos
    notifyListeners();

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_segundosRestantes < 1) {
        _podeTentarNovamente = true;
        timer.cancel();
      } else {
        _segundosRestantes--;
      }
      notifyListeners();
    });
  }

  Future<void> proximaPergunta() async {
    if (perguntaIndex < faseAtual.perguntas.length - 1) {
      perguntaIndex++;
      mostrandoFeedback = false;
      notifyListeners();
    } else {
      // Atualiza o progresso
      await atualizarProgresso();
      // A navegação deve ser tratada na UI
    }
  }

  Future<void> atualizarProgresso() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return;
      }

      final docRef =
          FirebaseFirestore.instance.collection('user_progress').doc(user.uid);
      final doc = await docRef.get();

      List<dynamic> fasesConcluidas = [];

      String eventoIdStr = evento.id.toString();
      int faseConcluidaIndex = faseIndex;

      if (doc.exists) {
        final data = doc.data()!;
        Map<String, dynamic> eventosFasesCompletadas =
            data['eventos_fases_completadas'] != null
                ? Map<String, dynamic>.from(data['eventos_fases_completadas'])
                : {};

        fasesConcluidas = eventosFasesCompletadas[eventoIdStr] != null
            ? List<dynamic>.from(eventosFasesCompletadas[eventoIdStr])
            : [];

        if (!fasesConcluidas.contains(faseConcluidaIndex)) {
          fasesConcluidas.add(faseConcluidaIndex);
          eventosFasesCompletadas[eventoIdStr] = fasesConcluidas;

          await docRef.update({
            'eventos_fases_completadas': eventosFasesCompletadas,
          });
        }
      } else {
        // Se o documento não existir, criar um novo
        await docRef.set({
          'user_id': user.uid,
          'eventos_fases_completadas': {
            eventoIdStr: [faseConcluidaIndex],
          },
        });
      }
    } catch (e) {
      print('Erro ao atualizar progresso: $e');
      // O tratamento de erro com SnackBar deve ser feito na UI
    }
  }

  // Getters para a UI
  bool get podeTentarNovamente => _podeTentarNovamente;
  int get segundosRestantes => _segundosRestantes;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
