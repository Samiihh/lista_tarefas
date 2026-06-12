import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lista_tarefas/servicos/auth_service.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final _authService = AuthService();

  bool _carregando = false;

  Future<void> _cadastrar() async {
    if (_emailController.text.trim().isEmpty ||
        _senhaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o e-mail e senha.'),

          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      await _authService.cadastrar(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
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

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Método responsavel pela contrução da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Criar Conta'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),

        centerTitle: true,
        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      // Body é o conteudo principal da tela
      // SafeArea evita que o conteudo fica atras de aereas do sistema
      body: SafeArea(
        // child:center - centraliza o seu filho na tela
        child: Center(
          // permitir rolagem na tela
          child: SingleChildScrollView(
            // dar o espaçamento interno
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              //Coluna para organizar os widgets em uma coluna vertical
              child: Column(
                // Deixar o eixo principal da coluna alinhado verticalmente
                mainAxisAlignment: MainAxisAlignment.center,

                //Children recebe a lista de widgets que serão exibidos
                children: [
                  //aqui usamos o container para criar um bloco roxo com icone
                  Container(
                    width: 100,
                    height: 100,

                    // decoration para permitir pesonalizar o visual do container
                    decoration: BoxDecoration(
                      //define a cor de fundo
                      color: Colors.deepPurple,

                      borderRadius: BorderRadius.circular(30),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.4),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.person_add_alt_1,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Cadastre-se para salvar suas tarefas 🔥',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Digite seu email',
                      hintStyle: const TextStyle(color: Colors.white54),

                      labelText: 'E-mail',

                      labelStyle: const TextStyle(color: Colors.deepPurple),

                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.deepPurple,
                      ),

                      filled: true,
                      fillColor: const Color(0xFF1e1e1e),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _senhaController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Digite ssua senha',
                      hintStyle: const TextStyle(color: Colors.white54),

                      labelText: 'Senha',

                      labelStyle: const TextStyle(color: Colors.deepPurple),

                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.deepPurple,
                      ),

                      filled: true,
                      fillColor: const Color(0xFF1e1e1e),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _carregando
                      ? const CircularProgressIndicator(
                          color: Colors.deepPurple,
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            onPressed: _cadastrar,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            child: const Text(
                              'Cadastrar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
