import 'package:flutter/material.dart';
import 'package:lista_tarefas/models/tarefas.dart';
import 'package:lista_tarefas/servicos/auth_service.dart';
import 'package:lista_tarefas/servicos/db_service.dart';

class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key});

  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  final DbService _dbService = DbService();
  final AuthService _authService = AuthService();

  void _mostrarModalNovaTarefa() {
    final controller = TextEditingController();

    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: const Text(
          'Nova Tarefa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),

          decoration: InputDecoration(
            hintText: 'O que você precisa fazer?',
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.task_alt, color: Colors.deepPurple),

            filled: true,
            fillColor: const Color(0xFF2a2a2a),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _dbService.criarTarefa(controller.text.trim());

                Navigator.pop(context);
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54),
        ),

        centerTitle: true,

        backgroundColor: Colors.transparent,

        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white70),
            onPressed: () async {
              await _authService.logout();

              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Tarefa>>(
        stream: _dbService.lerTarefas(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          final tarefas = snapshot.data ?? [];

          if (tarefas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.playlist_add_check_circle_outlined,
                    size: 90,
                    color: Colors.deepPurple.withOpacity(0.8),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Nenhuma Tarefa ainda',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Clique no botão + para criar sua primeira tarefa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 15),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: tarefas.length,

            itemBuilder: (context, index) {
              final tarefa = tarefas[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),

                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(18),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  leading: Checkbox(
                    value: tarefa.concluida,
                    activeColor: Colors.deepPurple,
                    onChanged: (valor) {
                      _dbService.atualizarStatus(tarefa.id, valor!);
                    },
                  ),

                  title: Text(
                    tarefa.titulo,
                    style: TextStyle(
                      decoration: tarefa.concluida
                          ? TextDecoration.lineThrough
                          : null,

                      color: tarefa.concluida ? Colors.white38 : Colors.white,

                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),

                    onPressed: () => _dbService.deletarTarefa(tarefa.id),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalNovaTarefa,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        foregroundColor: Colors.white,

        label: const Text('Nova Tarefa'),
      ),
    );
  }
}
