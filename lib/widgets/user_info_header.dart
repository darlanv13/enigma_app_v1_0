// lib/widgets/user_info_header.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserInfoHeader extends StatelessWidget {
  final String nomeCompleto;
  final String? photoURL;
  final double? valorInscricao;
  final String tipoDesafio;
  final int quantDesafios;
  final String local;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const UserInfoHeader({
    Key? key,
    required this.nomeCompleto,
    this.photoURL,
    this.valorInscricao,
    required this.tipoDesafio,
    required this.quantDesafios,
    required this.local,
    required this.onBack,
    required this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Material(
        color: Colors.transparent,
        elevation: 3.0,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Color(0xFF3E8DA1),
              width: 2.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
            children: [
              // Linha Superior: Botão de Voltar, Avatar do Usuário, Ícone de Configurações
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ícone de voltar
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 29.0,
                    ),
                    onPressed: onBack,
                  ),

                  // Avatar do usuário
                  CircleAvatar(
                    radius: 40.0,
                    backgroundImage: photoURL != null
                        ? NetworkImage(photoURL!)
                        : AssetImage('assets/images/default_user.gif')
                            as ImageProvider,
                  ),

                  // Ícone de configurações
                  IconButton(
                    icon: Icon(
                      Icons.settings_suggest,
                      color: Colors.white,
                      size: 29.0,
                    ),
                    onPressed: onSettings,
                  ),
                ],
              ),

              // Linha Central: Nome do Usuário (Centralizado)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nomeCompleto,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2.0),
                ],
              ),
              SizedBox(height: 2.0),

              // Informações do Evento: Tipo de Desafio, Quantidade de Desafios, Local
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de Desafio
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.map,
                        color: Colors.white70,
                        size: 18.0,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        tipoDesafio,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontSize: 14.0,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  // Quantidade de Desafios
                  Row(
                    children: [
                      Icon(
                        Icons.castle_outlined,
                        color: Colors.white70,
                        size: 18.0,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        'Desafios: $quantDesafios',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontSize: 14.0,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  // Local
                  Row(
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: Colors.white70,
                        size: 19.0,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        local,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontSize: 14.0,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
