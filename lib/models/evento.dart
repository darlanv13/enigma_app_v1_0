// lib/models/evento.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id;
  final String titulo;
  final String tipoDesafio;
  final double valorPremio;
  final int quantDesafios;
  final int quantFases;
  final String local;
  final String descricao;
  final String imgCapaEvento;
  final String status;
  final double valorInscricao;
  final DateTime dataCriacao;
  final List<Fase> fases;

  Evento({
    required this.id,
    required this.titulo,
    required this.tipoDesafio,
    required this.valorPremio,
    required this.quantDesafios,
    required this.quantFases,
    required this.local,
    required this.descricao,
    required this.imgCapaEvento,
    required this.status,
    required this.valorInscricao,
    required this.dataCriacao,
    required this.fases,
  });

  factory Evento.fromMap(Map<String, dynamic> data, String documentId) {
    return Evento(
      id: documentId,
      titulo: data['titulo'] ?? '',
      tipoDesafio: data['tipo_desafio'] ?? '',
      valorPremio: (data['valor_premio'] ?? 0.0).toDouble(),
      quantDesafios: data['quant_desafios'] ?? 0,
      quantFases: data['quant_fases'] ?? 0,
      local: data['local'] ?? '',
      descricao: data['descricao'] ?? '',
      imgCapaEvento: data['img_capa_evento'] ?? '',
      status: data['status'] ?? '',
      valorInscricao: (data['valor_inscrição'] ?? 0.0).toDouble(),
      dataCriacao: (data['data_criacao'] as Timestamp).toDate(),
      fases: data['fases'] != null
          ? (data['fases'] as List)
              .map((faseData) => Fase.fromMap(faseData))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'tipo_desafio': tipoDesafio,
      'valor_premio': valorPremio,
      'quant_desafios': quantDesafios,
      'quant_fases': quantFases,
      'local': local,
      'descricao': descricao,
      'img_capa_evento': imgCapaEvento,
      'status': status,
      'valor_inscrição': valorInscricao,
      'data_criacao': Timestamp.fromDate(dataCriacao),
      'fases': fases.map((fase) => fase.toMap()).toList(),
    };
  }
}

class Fase {
  final int numeroFase;
  final String imgCapaFase;
  final List<Pergunta> perguntas;

  Fase({
    required this.numeroFase,
    required this.imgCapaFase,
    required this.perguntas,
  });

  factory Fase.fromMap(Map<String, dynamic> data) {
    return Fase(
      numeroFase: data['fase'] ?? 0,
      imgCapaFase: data['img_capa_fase'] ?? '',
      perguntas: data['perguntas'] != null
          ? (data['perguntas'] as List)
              .map((perguntaData) => Pergunta.fromMap(perguntaData))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fase': numeroFase,
      'img_capa_fase': imgCapaFase,
      'perguntas': perguntas.map((pergunta) => pergunta.toMap()).toList(),
    };
  }
}

class Pergunta {
  final String pergunta;
  final String resposta;
  final String? imgCapaFase;
  final String? videoInstrucao;
  final String? dica;
  final String? tempoEstimado;

  Pergunta({
    required this.pergunta,
    required this.resposta,
    this.imgCapaFase,
    this.videoInstrucao,
    this.dica,
    this.tempoEstimado,
  });

  factory Pergunta.fromMap(Map<String, dynamic> data) {
    return Pergunta(
      pergunta: data['pergunta'] ?? '',
      resposta: data['resposta'] ?? '',
      imgCapaFase: data['img_capa_fase'],
      videoInstrucao: data['video_instrucao'],
      dica: data['dica'],
      tempoEstimado: data['tempo_estimado'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pergunta': pergunta,
      'resposta': resposta,
      'img_capa_fase': imgCapaFase,
      'video_instrucao': videoInstrucao,
      'dica': dica,
      'tempo_estimado': tempoEstimado,
    };
  }
}
