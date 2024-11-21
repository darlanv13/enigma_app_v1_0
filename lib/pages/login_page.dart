// lib/pages/login_page.dart
import 'package:enigma_app_v1_0/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importar as páginas necessárias
import 'recuperar_acesso_page.dart';
import 'criar_usuario_page.dart';
// Remova a importação direta de 'eventos_page.dart' se não for necessária

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configurando a animação
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    // Usando Tween para a animação de fade
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Iniciando a animação
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      bool success = await authProvider.login(
        _emailController.text.trim(),
        _senhaController.text,
      );

      if (success) {
        // Navegar para a página de eventos após o login bem-sucedido
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // Exibir mensagem de erro fornecida pelo AuthProvider
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erro ao fazer login.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _navegarParaRecuperarSenha() {
    Navigator.pushNamed(context, '/recuperarSenha');
  }

  void _navegarParaCriarUsuario() {
    Navigator.pushNamed(context, '/criarUsuario');
  }

  @override
  Widget build(BuildContext context) {
    // Definindo as cores personalizadas
    Color primaryColor = Theme.of(context).primaryColor;
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Logo ou título do aplicativo
                      Text(
                        'Bem-vindo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 32),
                      // Campo de e-mail
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.email, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null ||
                                !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
                            ? 'E-mail inválido'
                            : null,
                      ),
                      SizedBox(height: 16),
                      // Campo de senha
                      TextFormField(
                        controller: _senhaController,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Digite sua senha'
                            : null,
                      ),
                      SizedBox(height: 16),
                      // Botão de login
                      authProvider.isLoading
                          ? CircularProgressIndicator(color: primaryColor)
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _login(context),
                                child: Text('Entrar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  elevation: 5,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  textStyle: TextStyle(fontSize: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: 16),
                      // Link "Esqueceu a senha?"
                      TextButton(
                        onPressed: _navegarParaRecuperarSenha,
                        child: Text(
                          'Esqueceu a senha?',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      // Link para criar conta
                      TextButton(
                        onPressed: _navegarParaCriarUsuario,
                        child: Text(
                          'Não tem uma conta? Cadastre-se',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
