// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? user;
  bool isLoading = true;
  String? errorMessage;
  String? recoveryMessage;

  AuthProvider() {
    // Escuta mudanças no estado de autenticação
    _firebaseAuth.authStateChanges().listen((User? user) {
      this.user = user;
      isLoading = false;
      notifyListeners();
    });
  }

  // Método para efetuar login com email e senha
  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true; // Login bem-sucedido
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      return false; // Login falhou
    } catch (e) {
      errorMessage = 'Erro desconhecido durante o login.';
      return false; // Login falhou
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para efetuar logout
  Future<void> logout() async {
    try {
      isLoading = true;
      notifyListeners();

      await _firebaseAuth.signOut();
    } catch (e) {
      errorMessage = 'Erro durante o logout.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para limpar mensagens de erro
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // Método para recuperar senha
  Future<void> recoverPassword(String email) async {
    try {
      isLoading = true;
      recoveryMessage = null;
      errorMessage = null;
      notifyListeners();

      await _firebaseAuth.sendPasswordResetEmail(email: email);
      recoveryMessage = 'E-mail de recuperação enviado com sucesso!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'Nenhum usuário encontrado para esse e-mail.';
      } else {
        errorMessage = 'Erro ao enviar e-mail de recuperação: ${e.message}';
      }
    } catch (e) {
      errorMessage = 'Erro desconhecido durante a recuperação de senha.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para limpar mensagens de recuperação
  void clearRecoveryMessage() {
    recoveryMessage = null;
    notifyListeners();
  }
}
