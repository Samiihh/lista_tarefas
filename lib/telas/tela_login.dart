import 'package:flutter/material.dart';
import 'package:lista_tarefas/servicos/auth_service.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Serve para controlar e  capturar o texto digitado no TextFild
  final _emailController = TextEditingController();
  final _senhaContrroler = TextEditingController();

  // Responsavel por concersar com o firebase Authentication
  final _authService = AuthService();

  // Variavel de controle de carregamento
  // false = não esta carregando, então mostra o botão "Entrar"
  // true = esta carregando,  então mostra o spinner
  bool _carregando = false;

  //Função de login
  //Future<void> significa que essa função é assíncrona:
  //Ela executa algo que pode demora, como uma chamada ao Firebase pela internet
  //void significa que ela não retorna nenhum valor para quem chamou
  Future<void> _fazerLogin() async {
    //Validadmos os campos
    if (_emailController.text.trim().isEmpty ||
        _senhaContrroler.text.trim().isEmpty) {
      // ScaffoldMessenger = Mensagem temporaria na tela
      // shoeSnacBar = mostrar na barra de aviso inferior
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o e-mail e senha.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    //Avisar ao Fluuter que algo mudou natela
    setState(() => _carregando = true);

    try {
      await _authService.login(
        _emailController.text.trim(),
        _senhaContrroler.text.trim(),
      );

      //mounted verifica se a tela ainda existe
      if (mounted) {
        //pushReplacementNamed substitui a tela atual pela nova tella
        Navigator.pushReplacementNamed(context, '/tarefas');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  // Dispose é executado quando a tela e removida da memoria
  // Como criamos controllers, precisamos descartalos manualmente.
  // Isso evita vazamento de memoria
  @override
  void dispose() {
    _emailController.dispose();
    _senhaContrroler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,

                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'App tarefas',

                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'organize sua rotina com Firebase 🔥',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  // Espaçamento  antes do formulario
                  const SizedBox(height: 40),

                  // Campo de texto para o email
                  TextField(
                    // Liga o campo ao controller de email
                    // assim conseguimos recuperar o valor digitado
                    controller: _emailController,

                    //Define  a cor do texto digitado
                    style: const TextStyle(color: Colors.white),

                    // decoration define a aparência do campo
                    decoration: InputDecoration(
                      // Texto exibido dentro do campo antes do usario digitar
                      hintText: 'Digite seu email',

                      // Estilo do hintText
                      hintStyle: const TextStyle(color: Colors.white54),

                      // Label do campo
                      labelText: 'Email',

                      // estilo da label
                      labelStyle: const TextStyle(color: Colors.deepPurple),

                      // icone no começo do campo
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.deepPurple,
                      ),

                      // ativa o prrenchimento de fundo
                      filled: true,

                      // cor de fundo do campo
                      fillColor: const Color(0xFF1E1E1E),

                      //borda do campo
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        // remove a linha da borda
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    // Liga o campo ao controller de email
                    // assim conseguimos recuperar o valor digitado
                    controller: _senhaContrroler,

                    //Define  a cor do texto digitado
                    style: const TextStyle(color: Colors.white),

                    // decoration define a aparência do campo
                    decoration: InputDecoration(
                      // Texto exibido dentro do campo antes do usario digitar
                      hintText: 'Digite sua senha',

                      // Estilo do hintText
                      hintStyle: const TextStyle(color: Colors.white54),

                      // Label do campo
                      labelText: 'Senha',

                      // estilo da label
                      labelStyle: const TextStyle(color: Colors.deepPurple),

                      // icone no começo do campo
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.deepPurple,
                      ),

                      // ativa o prrenchimento de fundo
                      filled: true,

                      // cor de fundo do campo
                      fillColor: const Color(0xFF1E1E1E),

                      //borda do campo
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        // remove a linha da borda
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // condição ternaria, para a troca do botão,
                  // se for verdadeiro aparece o spinner, se não aparece o botão entrar
                  _carregando
                      ? const CircularProgressIndicator(
                          // cor do spinner
                          color: Colors.deepPurple,
                        )
                      : SizedBox(
                          // fazendo o botão ocupar o espaço todo disponivel
                          width: double.infinity,
                          // altura fixa do botão
                          height: 55,

                          // botão principal
                          child: ElevatedButton(
                            // função chamada quando o botão é pressionado
                            onPressed: _fazerLogin,
                            // Estilo visual do botão
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,

                              // Formato do botão
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            // texto do botão
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadastro');
                    },

                    child: const Text(
                      'Não tem conta? Cadastre-se',

                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
