// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  UserProvider() {
    _loadUser();
  }

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadUser() async {
    _user = _auth.currentUser;

    if (_user == null) {
      _isLoading = false;
      _errorMessage = 'Usuário não autenticado.';
      notifyListeners();
      return;
    }

    try {
      DocumentSnapshot doc =
          await _firestore.collection('ususarios').doc(_user!.uid).get();

      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>?;
      } else {
        _userData = {
          'nome_completo': _user!.displayName ?? 'Usuário',
          'email': _user!.email,
          'photoURL': _user!.photoURL,
        };
        // Você pode optar por salvar esses dados no Firestore aqui, se desejar.
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao carregar os dados do usuário: $e';
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }
}
