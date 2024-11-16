import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart'; // Importação do pacote

class CriarUsuarioPage extends StatefulWidget {
  @override
  _CriarUsuarioPageState createState() => _CriarUsuarioPageState();
}

class _CriarUsuarioPageState extends State<CriarUsuarioPage>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final TextEditingController _nomeCompletoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Máscaras para formatação
  final _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final _telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final _dataFormatter = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

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
    // Limpando os controladores de texto
    _nomeCompletoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    // Dispensando o controlador de animação
    _animationController.dispose();
    super.dispose();
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
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial (!@#\$&*~)';
    }
    return null;
  }

  // Função para validar a confirmação de senha
  String? _validarConfirmacaoSenha(String? value) {
    if (value != _senhaController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  Future<void> _criarUsuario() async {
    if (_formKeys.every((key) => key.currentState!.validate())) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Verifica se o CPF já existe
        final querySnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('cpf', isEqualTo: _cpfController.text.trim())
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // CPF já existe
          setState(() {
            _isLoading = false;
          });
          _mostrarDialogoCPFExistente();
          return;
        }

        // Cria a conta no Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );

        // Adiciona os detalhes adicionais do usuário no Firestore
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
          'nome_completo': _nomeCompletoController.text.trim(),
          'telefone': _telefoneController.text.trim(),
          'email': _emailController.text.trim(),
          'cpf': _cpfController.text.trim(),
          'data_nascimento': _dataNascimentoController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Usuário criado com sucesso!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao criar usuário: $e'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Validação falhou em alguma etapa
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor, preencha todos os campos obrigatórios.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _mostrarDialogoCPFExistente() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CPF já cadastrado'),
          content: Text(
              'Já existe uma conta associada a este CPF. Deseja recuperar o acesso?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Recuperar Acesso'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/recuperarSenha');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selecionarDataNascimento(BuildContext context) async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (dataSelecionada != null) {
      String dataFormatada = DateFormat('dd/MM/yyyy').format(dataSelecionada);
      setState(() {
        _dataNascimentoController.text = dataFormatada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definindo as cores personalizadas
    final Color primaryColor = Color(0xFF03E8DA);
    final Color backgroundColor = Color(0xFF0A5C69);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_formKeys[_currentStep].currentState!.validate()) {
                  if (_currentStep < _getSteps().length - 1) {
                    setState(() {
                      _currentStep += 1;
                    });
                  } else {
                    // Última etapa
                    _criarUsuario();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              steps: _getSteps(),
              controlsBuilder: (context, ControlsDetails details) {
                final isLastStep = _currentStep == _getSteps().length - 1;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep != 0)
                      ElevatedButton(
                        onPressed: details.onStepCancel,
                        child: Text('Voltar'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor),
                      ),
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? 'Concluir' : 'Avançar'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                    ),
                  ],
                );
              },
            ),
    );
  }

  List<Step> _getSteps() {
    final Color primaryColor = Color(0xFF03E8DA);

    return [
      // Etapa 1: Informações de Conta
      Step(
        title: Text('Conta', style: TextStyle(color: Colors.white)),
        content: Form(
          key: _formKeys[0],
          child: Column(
            children: [
              // E-mail
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
              SizedBox(height: 16),
              // Senha
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
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
                obscureText: true,
                validator: _validarSenha,
              ),
              SizedBox(height: 16),
              // Confirmar Senha
              TextFormField(
                controller: _confirmarSenhaController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
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
                obscureText: true,
                validator: _validarConfirmacaoSenha,
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.editing,
      ),
      // Etapa 2: Informações Pessoais
      Step(
        title:
            Text('Informações Pessoais', style: TextStyle(color: Colors.white)),
        content: Form(
          key: _formKeys[1],
          child: Column(
            children: [
              // Nome Completo
              TextFormField(
                controller: _nomeCompletoController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.person_outline, color: Colors.white),
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, insira o nome completo'
                    : null,
              ),
              SizedBox(height: 16),
              // CPF
              TextFormField(
                controller: _cpfController,
                decoration: InputDecoration(
                  labelText: 'CPF',
                  hintText: '000.000.000-00',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.badge, color: Colors.white),
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
                keyboardType: TextInputType.number,
                inputFormatters: [_cpfFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CPF';
                  }
                  if (!CPFValidator.isValid(value)) {
                    return 'CPF inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Data de Nascimento
              TextFormField(
                controller: _dataNascimentoController,
                readOnly: true,
                onTap: () => _selecionarDataNascimento(context),
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento',
                  hintText: 'dd/mm/aaaa',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.cake, color: Colors.white),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
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
                keyboardType: TextInputType.datetime,
                inputFormatters: [_dataFormatter],
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, selecione a data de nascimento'
                    : null,
              ),
              SizedBox(height: 16),
              // Telefone
              TextFormField(
                controller: _telefoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(00) 00000-0000',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.phone, color: Colors.white),
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
                keyboardType: TextInputType.phone,
                inputFormatters: [_telefoneFormatter],
                validator: (value) => value == null || value.length != 15
                    ? 'Formato de telefone inválido'
                    : null,
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
        state: StepState.editing,
      ),
    ];
  }
}
