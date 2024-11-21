// lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: SettingsView(),
    );
  }
}

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SettingsProvider>(context, listen: false);
      if (!provider.isLoading) {
        _animationController.forward();
      } else {
        provider.addListener(() {
          if (!provider.isLoading) {
            _animationController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF3e8da1);
    final Color backgroundColor = const Color(0xFF0A5C69);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _animationController,
              child: Form(
                key: provider.formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: provider.chooseNewPhoto,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: provider.imageFile != null
                                ? FileImage(provider.imageFile!)
                                : (provider.photoURL != null
                                    ? NetworkImage(provider.photoURL!)
                                    : const AssetImage(
                                            'assets/images/default_user.gif')
                                        as ImageProvider),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<SettingsProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const CircularProgressIndicator();
                        }
                        return Text(
                          provider.nomeController.text,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    Consumer<SettingsProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const CircularProgressIndicator();
                        }
                        return Text(
                          provider.emailController.text,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'CPF',
                      provider.cpfController,
                      Icons.credit_card,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Telefone', provider.telefoneController, Icons.phone,
                        validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu telefone';
                      }
                      // Adicione validação adicional se necessário
                      return null;
                    }),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'E-mail', provider.emailController, Icons.email,
                        enabled: false),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.updateUserData(context),
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar Alterações'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => provider.signOut(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair da Conta'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 50),
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
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      String labelText, TextEditingController controller, IconData icon,
      {bool enabled = true, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white24,
        errorStyle: const TextStyle(color: Colors.redAccent),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(10.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
