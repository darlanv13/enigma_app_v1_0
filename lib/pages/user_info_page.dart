// lib/pages/user_info_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Perfil do Usuário'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userProvider.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Perfil do Usuário'),
            ),
            body: Center(child: Text(userProvider.errorMessage!)),
          );
        }

        final userData = userProvider.userData;
        final user = userProvider.user;

        return Scaffold(
          appBar: AppBar(
            title: Text('Perfil do Usuário'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await userProvider.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Foto do Usuário
                CircleAvatar(
                  radius: 60,
                  backgroundImage: userData?['photoURL'] != null
                      ? NetworkImage(userData!['photoURL'])
                      : AssetImage('assets/images/default_user.png')
                          as ImageProvider,
                ),
                SizedBox(height: 20),
                // Nome Completo
                Text(
                  userData?['nome_completo'] ?? 'Usuário',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Email
                Text(
                  userData?['email'] ?? user?.email ?? '',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                // Informações Adicionais
                ListTile(
                  leading: Icon(Icons.badge),
                  title: Text('CPF'),
                  subtitle: Text(userData?['cpf'] ?? 'Não informado'),
                ),
                ListTile(
                  leading: Icon(Icons.timeline),
                  title: Text('Progresso'),
                  subtitle: Text('${userData?['progresso'] ?? 0}%'),
                ),
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Nível'),
                  subtitle: Text('${userData?['nivel'] ?? 1}'),
                ),
                // Botão de Editar Perfil (Opcional)
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navegar para a página de edição de perfil (implementar se necessário)
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Editar Perfil'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
