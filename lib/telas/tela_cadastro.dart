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

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
