// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  TextEditingController nomeController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  String? _photoURL;
  File? _imageFile;
  bool _isLoading = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SettingsProvider() {
    _loadUserData();
  }

  // Getters para acessar propriedades privadas
  User? get user => _user;
  String? get photoURL => _photoURL;
  File? get imageFile => _imageFile;
  bool get isLoading => _isLoading;

  /// Carrega os dados do usuário a partir do FirebaseAuth e Firestore
  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    _user = _auth.currentUser;
    print('Usuário atual: ${_user?.uid}');

    if (_user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('usuarios').doc(_user!.uid).get();
        print('Documento encontrado: ${userDoc.exists}');

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          print('Dados do usuário: $userData');

          nomeController.text = userData['nome_completo'] ?? '';
          cpfController.text = userData['cpf'] ?? '';
          telefoneController.text = userData['telefone'] ?? '';
          _photoURL = userData['photoURL'] ?? _user!.photoURL;
        } else {
          print(
              'Documento não existe no Firestore. Usando dados do FirebaseAuth.');
          nomeController.text = _user!.displayName ?? '';
          cpfController.text = '';
          telefoneController.text = '';
          _photoURL = _user!.photoURL;
        }
        emailController.text = _user!.email ?? '';
        print('Nome Completo carregado: ${nomeController.text}');
      } catch (e) {
        print('Erro ao carregar dados do usuário: $e');
      }
    } else {
      print('Nenhum usuário está logado.');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Atualiza os dados do usuário no Firestore e Firebase Storage
  Future<void> updateUserData(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (_user != null) {
        try {
          _isLoading = true;
          notifyListeners();

          // Atualizar foto de perfil se uma nova imagem foi selecionada
          if (_imageFile != null) {
            String fileName = 'profile_images/${_user!.uid}.jpg';
            Reference storageRef = _storage.ref().child(fileName);

            UploadTask uploadTask = storageRef.putFile(_imageFile!);
            TaskSnapshot snapshot = await uploadTask;
            _photoURL = await snapshot.ref.getDownloadURL();
            print('Foto de perfil atualizada: $_photoURL');
          }

          // Atualizar dados no Firestore
          await _firestore.collection('usuarios').doc(_user!.uid).set({
            'nome_completo': nomeController.text.trim(),
            'telefone': telefoneController.text.trim(),
            'photoURL': _photoURL ?? '',
          }, SetOptions(merge: true));

          // Atualizar o displayName no FirebaseAuth
          await _user!.updateDisplayName(nomeController.text.trim());
          _user = _auth.currentUser;
          print('DisplayName atualizado para: ${_user!.displayName}');

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Dados atualizados com sucesso!'),
            backgroundColor: Colors.green,
          ));

          // Limpar o arquivo de imagem selecionado
          _imageFile = null;
        } catch (e) {
          print('Erro ao atualizar dados do usuário: $e');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao atualizar os dados. Tente novamente.'),
            backgroundColor: Colors.red,
          ));
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      }
    }
  }

  /// Realiza o logout do usuário e redireciona para a página de login
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Permite ao usuário escolher uma nova foto de perfil
  Future<void> chooseNewPhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      _photoURL = null; // Limpar a URL para usar a nova imagem local
      print('Nova foto selecionada: ${_imageFile!.path}');
      notifyListeners();
    }
  }

  /// Obtém o nome completo do usuário
  Future<String> getFullName() async {
    if (_isLoading) {
      await _loadUserData();
    }

    if (nomeController.text.isNotEmpty) {
      return nomeController.text;
    } else if (_user != null) {
      return _user!.displayName ?? 'Nome não disponível';
    } else {
      return 'Usuário não encontrado';
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    super.dispose();
  }
}
