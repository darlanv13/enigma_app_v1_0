// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class SettingsProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? user;
  String? photoURL;
  File? imageFile;
  bool isLoading = false;
  String? errorMessage;

  // Controla a seleção de imagem
  final ImagePicker _picker = ImagePicker();

  SettingsProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    user = _auth.currentUser;
    if (user != null) {
      await _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        photoURL = userData['photoURL'] ?? user!.photoURL;
      } else {
        // Se não existir no Firestore, usar dados do FirebaseAuth
        photoURL = user!.photoURL;
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Erro ao carregar dados do usuário.';
      print(e);
      notifyListeners();
    }
  }

  /// Método para escolher uma nova foto
  Future<void> chooseNewPhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  /// Método para atualizar os dados do usuário
  Future<bool> updateUserData({
    required String telefone,
  }) async {
    if (user == null) {
      errorMessage = 'Usuário não autenticado.';
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      // Atualizar foto de perfil se uma nova imagem foi selecionada
      if (imageFile != null) {
        String fileName = 'profile_images/${user!.uid}.jpg';
        Reference storageRef = _storage.ref().child(fileName);

        UploadTask uploadTask = storageRef.putFile(imageFile!);
        TaskSnapshot snapshot = await uploadTask;

        photoURL = await snapshot.ref.getDownloadURL();
      }

      // Atualizar dados no Firestore
      await _firestore.collection('usuarios').doc(user!.uid).set({
        'telefone': telefone.trim(),
        'photoURL': photoURL ?? '',
      }, SetOptions(merge: true));

      // Atualizar dados no FirebaseAuth, se necessário
      await user!.updatePhotoURL(photoURL);

      errorMessage = null; // Limpar mensagem de erro
      return true;
    } catch (e) {
      errorMessage = 'Erro ao atualizar os dados. Tente novamente.';
      print(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Método para realizar logout
  Future<void> signOut() async {
    await _auth.signOut();
    // Não esqueça de notificar listeners se necessário
    notifyListeners();
  }
}
