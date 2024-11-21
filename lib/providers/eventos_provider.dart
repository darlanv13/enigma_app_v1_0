// lib/providers/eventos_provider.dart

import 'package:enigma_app_v1_0/models/evento.dart';
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

  // Lista de Eventos
  List<Evento> _eventos = [];
  bool isLoadingEventos = true;
  String? eventosErrorMessage;

  // Evento selecionado
  Evento? _selectedEvento;

  // Getters
  List<Evento> get eventos => _eventos;
  bool get loadingEventos => isLoadingEventos;
  String? get eventosError => eventosErrorMessage;
  Evento? get selectedEvento => _selectedEvento;

  EventosProvider() {
    _eventosCollection = _firestore.collection('Canaa_Dos_Carajas');
    _fetchUserData();
    fetchEventos();
  }

  // Método para buscar dados do usuário
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
      Map<String, dynamic>? fetchedUserData =
          await _userService.getUserData(user.uid);
      if (fetchedUserData != null) {
        cpf = fetchedUserData['cpf'] ?? 'CPF não disponível';
        nomeCompleto =
            fetchedUserData['nome_completo'] ?? user.displayName ?? 'Usuário';
        photoURL = fetchedUserData['photoURL'] ?? user.photoURL;
        progresso = fetchedUserData['peventos_fases_completadas'] ?? 0;
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

  // Método para buscar eventos
  Future<void> fetchEventos() async {
    try {
      isLoadingEventos = true;
      eventosErrorMessage = null;
      notifyListeners();

      QuerySnapshot snapshot = await _eventosCollection!.get();
      _eventos = snapshot.docs
          .map((doc) => Evento.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      isLoadingEventos = false;
      notifyListeners();
    } catch (e) {
      print('Erro ao buscar eventos: $e');
      eventosErrorMessage = 'Erro ao carregar eventos.';
      isLoadingEventos = false;
      notifyListeners();
    }
  }

  // Método para selecionar um evento
  void selectEvento(Evento evento) {
    _selectedEvento = evento;
    notifyListeners();
  }

  /// Método opcional para obter o stream de eventos
  Stream<QuerySnapshot> get eventosStream {
    return _eventosCollection!.snapshots();
  }
}
