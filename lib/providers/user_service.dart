// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enigma_app_v1_0/models/user_progress.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtém os dados do usuário a partir do Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final userDoc = await _firestore.collection('usuarios').doc(uid).get();
    if (userDoc.exists) {
      return userDoc.data();
    }
    return null;
  }

  /// Cria um novo documento de usuário no Firestore
  Future<void> createUserDocument(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('usuarios').doc(uid).set(data);
  }

  /// Obtém o progresso do usuário a partir do Firestore
  Future<UserProgress?> getUserProgress(String uid) async {
    final progressDoc =
        await _firestore.collection('user_progress').doc(uid).get();
    if (progressDoc.exists) {
      return UserProgress.fromMap(progressDoc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Cria um novo documento de progresso para o usuário
  Future<void> createUserProgress(String uid) async {
    UserProgress userProgress = UserProgress(
        userId: uid, eventosFasesCompletadas: {}, eventosFasesProgresso: {});
    await _firestore
        .collection('user_progress')
        .doc(uid)
        .set(userProgress.toMap());
  }

  /// Atualiza o progresso do usuário
  Future<void> updateUserProgress(
      String uid, Map<String, dynamic> eventosFasesCompletadas) async {
    await _firestore.collection('user_progress').doc(uid).update({
      'eventos_fases_completadas': eventosFasesCompletadas,
    });
  }

  /// Define o progresso do usuário
  Future<void> setUserProgress(
      String uid, Map<String, dynamic> eventosFasesCompletadas) async {
    await _firestore.collection('user_progress').doc(uid).set({
      'eventos_fases_completadas': eventosFasesCompletadas,
    });
  }
}
