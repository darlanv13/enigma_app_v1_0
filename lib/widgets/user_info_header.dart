// lib/widgets/user_info_header.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class UserInfoHeader extends StatelessWidget {
  final String nomeCompleto;
  final String? photoURL;
  final double? valorPremio;
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
    this.valorPremio,
    required this.tipoDesafio,
    required this.quantDesafios,
    required this.local,
    required this.onBack,
    required this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final formatCurrency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Material(
        color: Colors.transparent,
        elevation: 3.0,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: primaryColor,
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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 29.0,
                    ),
                    onPressed: onBack,
                  ),

                  // Avatar do usuário
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: photoURL != null
                        ? NetworkImage(photoURL!)
                        : const AssetImage('assets/images/default_user.gif')
                            as ImageProvider,
                  ),

                  // Ícone de configurações
                  IconButton(
                    icon: const Icon(
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2.0),
                ],
              ),
              const SizedBox(height: 2.0),

              // Informações do Evento: Tipo de Desafio, Quantidade de Desafios, Local
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de Desafio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /*const FaIcon(
                        FontAwesomeIcons.map,
                        color: Colors.brown,
                        size: 18.0,
                      ),*/
                      const SizedBox(width: 5.0),
                      Text(
                        tipoDesafio,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  // Quantidade de Desafios e Local

                  const SizedBox(height: 8.0),
                  // Local
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.greenAccent,
                        size: 18.0,
                      ),
                      const SizedBox(width: 5.0),
                      Text(
                        'Prêmio:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${formatCurrency.format(valorPremio)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.greenAccent,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: Colors.blueAccent,
                                size: 22.0,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                local,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 12.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.radar,
                                color: Colors.blueAccent,
                                size: 22.0,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                ' $quantDesafios Nivel',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 12.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
