// lib/pages/fase_concluida_page.dart

import 'package:flutter/material.dart';
import '../models/evento.dart';
import 'settings_page.dart';
import '../widgets/user_info_header.dart';

class FaseConcluidaPage extends StatelessWidget {
  final String tituloFase;
  final Evento evento;
  final int faseIndex;

  const FaseConcluidaPage({
    Key? key,
    required this.tituloFase,
    required this.evento,
    required this.faseIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pode consumir um provedor se necessário
    return Scaffold(
      appBar: AppBar(
        title: Text(tituloFase),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Parabéns! Você concluiu a fase.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
