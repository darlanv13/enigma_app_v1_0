// lib/providers/auth_provider.dart

import 'package:enigma_app_v1_0/providers/user_service.dart';
import 'package:enigma_app_v1_0/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? user;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    user = _authService.currentUser;
    if (user != null) {
      await _fetchUserData();
    }
    isLoading = false;
    notifyListeners();

    // Escutar mudanças de autenticação
    _authService.authStateChanges.listen((User? newUser) async {
      user = newUser;
      if (user != null) {
        await _fetchUserData();
      } else {
        userData = null;
      }
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchUserData() async {
    try {
      userData = await _userService.getUserData(user!.uid);
      if (userData == null) {
        // Criar dados de usuário padrão se não existir
        await _userService.createUserDocument(user!.uid, {
          'nome_completo': user!.displayName ?? 'Usuário',
          'photoURL': user!.photoURL,
          // Adicione outros campos padrão conforme necessário
        });
        userData = await _userService.getUserData(user!.uid);
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar dados do usuário.';
      print(e);
    }
  }

  /// Método para realizar login
  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();
      User? loggedInUser = await _authService.login(email, password);
      if (loggedInUser != null) {
        user = loggedInUser;
        await _fetchUserData();
        return true;
      } else {
        errorMessage = 'Falha ao fazer login.';
        return false;
      }
    } on FirebaseAuthException catch (e) {
      errorMessage =
          e.message; // A mensagem já está personalizada no AuthService
      return false;
    } catch (e) {
      errorMessage = 'Erro ao fazer login.';
      print(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Método para realizar logout
  Future<void> logout() async {
    await _authService.logout();
    user = null;
    userData = null;
    notifyListeners();
  }

  /// Método para registrar um novo usuário (opcional)
  Future<bool> register(
      String email, String password, String nomeCompleto) async {
    try {
      isLoading = true;
      notifyListeners();
      User? registeredUser = await _authService.register(email, password);
      if (registeredUser != null) {
        user = registeredUser;
        // Criar documento do usuário no Firestore
        await _userService.createUserDocument(user!.uid, {
          'nome_completo': nomeCompleto,
          'photoURL': user!.photoURL,
          // Adicione outros campos conforme necessário
        });
        userData = await _userService.getUserData(user!.uid);
        return true;
      } else {
        errorMessage = 'Falha ao registrar.';
        return false;
      }
    } on FirebaseAuthException catch (e) {
      errorMessage =
          e.message; // A mensagem já está personalizada no AuthService
      return false;
    } catch (e) {
      errorMessage = 'Erro ao registrar.';
      print(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
