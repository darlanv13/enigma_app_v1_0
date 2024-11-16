// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream para escutar mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Método para login com e-mail e senha
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Aqui você pode personalizar as mensagens de erro conforme necessário
      print('Erro de login: ${e.message}');
      throw e; // Re-throw para que o AuthProvider possa lidar com isso
    } catch (e) {
      print('Erro de login: $e');
      throw e;
    }
  }

  /// Método para logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Método para registrar um novo usuário com e-mail e senha
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Erro de registro: ${e.message}');
      throw e;
    } catch (e) {
      print('Erro de registro: $e');
      throw e;
    }
  }

  /// Obter usuário autenticado atual
  User? get currentUser => _auth.currentUser;
}
