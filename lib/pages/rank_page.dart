// lib/pages/rank_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/evento.dart';
import '../providers/ranking_provider.dart';
import '../models/rank_entry.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RankPage extends StatelessWidget {
  final Evento evento;

  const RankPage({Key? key, required this.evento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RankingProvider>(
      create: (_) => RankingProvider(evento: evento),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ranking - ${evento.titulo}'),
        ),
        body: Consumer<RankingProvider>(
          builder: (context, rankingProvider, child) {
            if (rankingProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (rankingProvider.error != null) {
              return Center(child: Text(rankingProvider.error!));
            }

            if (rankingProvider.ranking.isEmpty) {
              return Center(child: Text('Nenhum participante encontrado.'));
            }

            return ListView.builder(
              itemCount: rankingProvider.ranking.length,
              itemBuilder: (context, index) {
                RankEntry entry = rankingProvider.ranking[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: entry.photoURL != null
                        ? CachedNetworkImageProvider(entry.photoURL!)
                        : AssetImage('assets/images/default_user.png')
                            as ImageProvider,
                  ),
                  title: Text(entry.nomeCompleto),
                  subtitle: Text(
                    'Fases Concluídas: ${entry.fasesConcluidas} / ${entry.totalFases}',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    '#${index + 1}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
