// lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Para upload de imagens
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart'; // Para animações

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? user;
  TextEditingController nomeController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  String? photoURL;
  File? _imageFile;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  // Controlador de animação
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Inicializar controlador de animação
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Método para carregar os dados do usuário
  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    user = _auth.currentUser;

    if (user != null) {
      // Obter dados adicionais do Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        nomeController.text = userData['nomeCompleto'] ?? '';
        cpfController.text = userData['cpf'] ?? '';
        telefoneController.text = userData['telefone'] ?? '';
        photoURL = userData['photoURL'] ?? user!.photoURL;
      } else {
        // Se não existir no Firestore, usar dados do FirebaseAuth
        nomeController.text = user!.displayName ?? '';
        cpfController.text = '';
        telefoneController.text = '';
        photoURL = user!.photoURL;
      }
      emailController.text = user!.email ?? '';
    }

    setState(() {
      isLoading = false;
    });

    // Iniciar animação após carregar os dados
    _animationController.forward();
  }

  // Método para atualizar os dados do usuário
  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      // Se o formulário for válido
      if (user != null) {
        try {
          // Mostrar indicador de progresso
          setState(() {
            isLoading = true;
          });

          // Atualizar foto de perfil se uma nova imagem foi selecionada
          if (_imageFile != null) {
            String fileName = 'profile_images/${user!.uid}.jpg';
            Reference storageRef = _storage.ref().child(fileName);

            UploadTask uploadTask = storageRef.putFile(_imageFile!);
            TaskSnapshot snapshot = await uploadTask;

            photoURL = await snapshot.ref.getDownloadURL();
          }

          await _firestore.collection('usuarios').doc(user!.uid).set({
            'telefone': telefoneController.text.trim(),
            'photoURL': photoURL ?? '',
          }, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Dados atualizados com sucesso!'),
            backgroundColor: Colors.green,
          ));

          // Limpar o arquivo de imagem selecionado
          setState(() {
            _imageFile = null;
            isLoading = false;
          });
        } catch (e) {
          print('Erro ao atualizar dados do usuário: $e');
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao atualizar os dados. Tente novamente.'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  // Método para fazer logout
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Método para escolher nova foto usando image_picker
  Future<void> _chooseNewPhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        photoURL = null; // Limpar a URL para usar a nova imagem local
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF3e8da1);
    final Color backgroundColor = Color(0xFF0A5C69);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: FadeTransition(
                opacity: _animationController, // Animação de transição
                child: Form(
                  key: _formKey, // Chave do formulário
                  child: Column(
                    children: [
                      // Foto do usuário
                      GestureDetector(
                        onTap: _chooseNewPhoto,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (photoURL != null
                                      ? NetworkImage(photoURL!)
                                      : AssetImage(
                                              'assets/images/default_user.gif')
                                          as ImageProvider),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      // Formulário de edição
                      _buildTextField(
                          'Nome Completo', nomeController, Icons.person,
                          enabled: false),
                      SizedBox(height: 16),
                      _buildTextField('CPF', cpfController, Icons.credit_card,
                          enabled: false),
                      SizedBox(height: 16),
                      _buildTextField(
                          'Telefone', telefoneController, Icons.phone),
                      SizedBox(height: 16),
                      _buildTextField('E-mail', emailController, Icons.email,
                          enabled: false),
                      SizedBox(height: 24),
                      // Botão para salvar alterações
                      ElevatedButton.icon(
                        onPressed: _updateUserData,
                        icon: Icon(Icons.save),
                        label: Text('Salvar Alterações'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primaryColor,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                      SizedBox(height: 16),
                      // Botão para sair da conta
                      TextButton.icon(
                        onPressed: _signOut,
                        icon: Icon(Icons.logout),
                        label: Text('Sair da Conta'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Método auxiliar para construir campos de texto com validação
  Widget _buildTextField(
      String labelText, TextEditingController controller, IconData icon,
      {bool enabled = true, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white24,
        errorStyle: TextStyle(color: Colors.redAccent),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(10.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
