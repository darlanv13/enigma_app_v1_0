// lib/pages/fase_page_wrapper.dart

import 'package:enigma_app_v1_0/providers/fase_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fase_page.dart';
import '../models/evento.dart'; // Certifique-se de que o modelo Evento está definido corretamente

class FasePageWrapper extends StatelessWidget {
  final Evento evento;
  final int faseIndex;

  const FasePageWrapper({
    Key? key,
    required this.evento,
    required this.faseIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FaseProvider>(
      create: (_) => FaseProvider(evento: evento, faseIndex: faseIndex),
      child: FasePage(),
    );
  }
}
