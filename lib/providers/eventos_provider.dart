// lib/providers/eventos_provider.dart

import 'package:enigma_app_v1_0/providers/user_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventosProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  CollectionReference? _eventosCollection;

  // Dados do usuário
  String? cpf;
  String? nomeCompleto;
  String? photoURL;
  int progresso = 0; // Progresso do usuário (exemplo)
  bool isLoadingUserData = true;
  String? errorMessage;
  Map<String, dynamic>? userData;

  EventosProvider() {
    _eventosCollection = _firestore.collection('Canaa_Dos_Carajas');
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage = 'Usuário não autenticado';
        isLoadingUserData = false;
        notifyListeners();
        return;
      }

      // Obter dados do usuário do Firestore
      Map<String, dynamic>? userData = await _userService.getUserData(user.uid);
      if (userData != null) {
        cpf = userData['cpf'] ?? 'CPF não disponível';
        nomeCompleto =
            userData['nome_completo'] ?? user.displayName ?? 'Usuário';
        photoURL = userData['photoURL'] ?? user.photoURL;
        progresso = userData['peventos_fases_completadas'] ?? 0;
      } else {
        // Usuário não tem documento no Firestore
        nomeCompleto = user.displayName ?? 'Usuário';
        photoURL = user.photoURL;
        progresso = 0;
      }

      isLoadingUserData = false;
      notifyListeners();
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      errorMessage = 'Erro ao carregar os dados do usuário.';
      isLoadingUserData = false;
      notifyListeners();
    }
  }

  /// Método para obter o stream de eventos
  Stream<QuerySnapshot> get eventosStream {
    return _eventosCollection!.snapshots();
  }
}
