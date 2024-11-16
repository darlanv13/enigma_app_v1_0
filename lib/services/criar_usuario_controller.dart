import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CriarUsuarioController extends GetxController {
  // Controladores de formulário e máscara de entrada
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##');
  final telefoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####');

  // Observáveis para os dados do usuário
  final _nomeUsuario = ''.obs;
  final _nomeCompleto = ''.obs;
  final _telefone = ''.obs;
  final _email = ''.obs;
  final _cpf = ''.obs;
  final _dataNascimento = ''.obs;
  final _senha = ''.obs;
  final _confirmarSenha = ''.obs;

  // Getters
  get nomeUsuario => _nomeUsuario.value;
  get nomeCompleto => _nomeCompleto.value;
  get telefone => _telefone.value;
  get email => _email.value;
  get cpf => _cpf.value;
  get dataNascimento => _dataNascimento.value;
  get senha => _senha.value;
  get confirmarSenha => _confirmarSenha.value;

  // Funções para atualizar os observáveis
  void updateNomeUsuario(String value) => _nomeUsuario.value = value;
  void updateNomeCompleto(String value) => _nomeCompleto.value = value;
  void updateTelefone(String value) => _telefone.value = value;
  void updateEmail(String value) => _email.value = value;
  void updateCpf(String value) => _cpf.value = value;
  void updateDataNascimento(String value) => _dataNascimento.value = value;
  void updateSenha(String value) => _senha.value = value;
  void updateConfirmarSenha(String value) => _confirmarSenha.value = value;

  // Função para validar email
  String? _validarEmail(String? value) {
    if (value == null || !GetUtils.isEmail(value)) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  // Função para validar o telefone
  String? _validarTelefone(String? value) {
    if (value == null || value.length != 15) {
      return 'Por favor, insira um telefone válido com DDD';
    }
    return null;
  }

  // Função para validar CPF
  String? _validarCpf(String? value) {
    if (value == null || value.length != 14) {
      return 'Por favor, insira um CPF válido';
    }
    return null;
  }

  // Função para validar a senha
  String? _validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira a senha';
    }
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número';
    }
    if (!RegExp(r'[@#$&~]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial (!@#&~)';
    }
    return null;
  }

  // Função para validar a confirmação de senha
  String? _validarConfirmacaoSenha(String? value) {
    if (value != _senha.value) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  // Função para criar o usuário
  Future<void> criarUsuario() async {
    if (formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.value,
          password: _senha.value,
        );

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
          'nome_usuario': _nomeUsuario.value,
          'nome_completo': _nomeCompleto.value,
          'telefone': _telefone.value,
          'email': _email.value,
          'cpf': _cpf.value,
          'data_nascimento': _dataNascimento.value,
        });

        Get.snackbar('Sucesso', 'Usuário criado com sucesso!');
        Get.toNamed('/login');
      } catch (e) {
        Get.snackbar('Erro', 'Erro ao criar usuário: $e');
      }
    }
  }

  // Função para selecionar a data de nascimento
  Future<void> selecionarDataNascimento(BuildContext context) async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (dataSelecionada != null) {
      String dataFormatada = DateFormat('dd/MM/yyyy').format(dataSelecionada);
      updateDataNascimento(dataFormatada);
    }
  }
}
