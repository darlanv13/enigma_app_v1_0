// lib/pages/fase_page.dart

// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/evento.dart';
import 'fase_concluida_page.dart';
import '../providers/fase_provider.dart';
import 'settings_page.dart';
import '../widgets/user_info_header.dart';

class FasePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldBody();
  }
}

class ScaffoldBody extends StatefulWidget {
  @override
  _ScaffoldBodyState createState() => _ScaffoldBodyState();
}

class _ScaffoldBodyState extends State<ScaffoldBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    final logic = Provider.of<FaseProvider>(context, listen: false);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<FaseProvider>(context);
    Color primaryColor = Theme.of(context).primaryColor;
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final Pergunta perguntaAtual =
        logic.faseAtual.perguntas[logic.perguntaIndex];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: logic.isLoadingUserData
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : FadeTransition(
              opacity: fadeAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cabeçalho com informações do usuário e configurações
                        UserInfoHeader(
                          valorPremio: logic.evento.valorPremio,
                          nomeCompleto: logic.nomeCompleto ?? 'Usuário',
                          photoURL: logic.photoURL,
                          tipoDesafio: logic.evento.tipoDesafio,
                          quantDesafios: logic.evento.quantDesafios,
                          local: logic.evento.local,
                          onBack: () {
                            Navigator.pop(context);
                          },
                          onSettings: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsPage()),
                            );
                          },
                        ),
                        SizedBox(height: 20.0),

                        // Informações do Evento
                        _buildEventoInfo(logic.evento),
                        SizedBox(height: 20.0),

                        // Informações da Fase
                        _buildFaseInfo(logic.faseAtual),
                        SizedBox(height: 20.0),

                        // Pergunta Atual
                        _buildPergunta(perguntaAtual),
                        SizedBox(height: 20.0),

                        // Campo de Resposta
                        _buildCampoResposta(logic),
                        SizedBox(height: 16.0),

                        // Botão de Verificação ou Indicador de Carregamento
                        logic.verificandoResposta
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: primaryColor))
                            : _buildBotaoVerificar(
                                context, logic, primaryColor),
                        SizedBox(height: 16.0),

                        // Feedback de Resposta
                        if (logic.mostrandoFeedback)
                          _buildFeedback(context, logic),

                        // Temporizador para nova tentativa
                        if (!logic.podeTentarNovamente)
                          _buildTemporizador(logic),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEventoInfo(Evento evento) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título do Evento
        Text(
          evento.titulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildFaseInfo(Fase fase) {
    return Column(
      children: [
        // Nome da Fase
        Text(
          'FASE ${fase.numeroFase}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildPergunta(Pergunta perguntaAtual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Texto da Pergunta
        Text(
          perguntaAtual.pergunta,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        // Imagem da Pergunta, se existir
        if (perguntaAtual.imgCapaFase != null &&
            perguntaAtual.imgCapaFase!.isNotEmpty)
          Container(
            width: double.infinity,
            height: 170,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                perguntaAtual.imgCapaFase!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        SizedBox(height: 16),
        // Dica, se existir
        if (perguntaAtual.dica != null && perguntaAtual.dica!.isNotEmpty)
          Text(
            'Dica: ${perguntaAtual.dica}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCampoResposta(FaseProvider logic) {
    return TextField(
      onChanged: (value) {
        logic.respostaUsuario = value;
      },
      enabled: logic.podeTentarNovamente,
      decoration: InputDecoration(
        labelText: 'Sua resposta',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF03E8DA)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildBotaoVerificar(
      BuildContext context, FaseProvider logic, Color primaryColor) {
    return ElevatedButton(
      onPressed: logic.podeTentarNovamente
          ? () async {
              FocusScope.of(context).unfocus(); // Fecha o teclado
              bool acertou =
                  await logic.verificarResposta(logic.respostaUsuario);
              if (!acertou && logic.respostaUsuario.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Por favor, insira uma resposta.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (!acertou) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Resposta incorreta. Tente novamente mais tarde.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          : null,
      child: Text(
        'Verificar',
        style: TextStyle(color: const Color.fromARGB(255, 35, 238, 42)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        textStyle: TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildFeedback(BuildContext context, FaseProvider logic) {
    return Column(
      children: [
        SizedBox(height: 16),
        Text(
          logic.acertou ? 'Resposta correta!' : 'Resposta incorreta.',
          style: TextStyle(
            color: logic.acertou ? Colors.green : Colors.red,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 16),
        if (logic.acertou &&
            logic.perguntaIndex == logic.faseAtual.perguntas.length - 1)
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FaseConcluidaPage(
                    tituloFase: 'Fase ${logic.faseAtual.numeroFase}',
                    evento: logic.evento,
                    faseIndex: 0,
                  ),
                ),
              );
            },
            child: Text('Concluir Fase'),
          ),
      ],
    );
  }

  Widget _buildTemporizador(FaseProvider logic) {
    return Text(
      'Você pode tentar novamente em ${logic.segundosRestantes} segundos.',
      style: TextStyle(color: Colors.yellowAccent, fontSize: 16),
      textAlign: TextAlign.center,
    );
  }
}
