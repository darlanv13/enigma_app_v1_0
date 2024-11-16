import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecuperarAcessoPage extends StatefulWidget {
  final String? email;

  RecuperarAcessoPage({this.email});

  @override
  _RecuperarAcessoPageState createState() => _RecuperarAcessoPageState();
}

class _RecuperarAcessoPageState extends State<RecuperarAcessoPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializa o controlador de e-mail com o e-mail fornecido (se houver)
    _emailController = TextEditingController(text: widget.email ?? '');

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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _recuperarSenha() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _auth.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('E-mail de recuperação enviado com sucesso!'),
          backgroundColor: Colors.green,
        ));

        // Redireciona para a página de login
        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Erro ao enviar e-mail de recuperação.';

        if (e.code == 'user-not-found') {
          errorMessage = 'E-mail não encontrado.';
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definindo as cores personalizadas
    final Color primaryColor = Color(0xFF03E8DA);
    final Color backgroundColor = Color(0xFF0A5C69);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Recuperar Acesso'),
        backgroundColor: primaryColor,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            // Centralizar o conteúdo
            child: SingleChildScrollView(
              // Permitir scroll se necessário
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Título
                    Text(
                      'Recupere sua senha',
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
                    SizedBox(height: 24),
                    _isLoading
                        ? CircularProgressIndicator(color: primaryColor)
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _recuperarSenha,
                              child: Text('Enviar E-mail de Recuperação'),
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
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Voltar ao Login',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
