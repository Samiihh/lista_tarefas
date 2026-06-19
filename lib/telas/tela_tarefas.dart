// Importa os componentes visuais do Flutter
// Exemplo: Scaffold, AppBar, ListView, Checkbox, FloatingActionButton, etc.
import 'package:flutter/material.dart';

// Importa o model Tarefa
// Esse model representa o formato de uma tarefa no app
import '../models/tarefas.dart';

// Importa o serviço responsável pelo banco de dados
// É nele que ficam as funções de criar, listar, atualizar e deletar tarefas
import '../servicos/db_service.dart';

// Importa o serviço de autenticação
// É usado aqui para fazer logout do usuário
import '../servicos/auth_service.dart';


// StatefulWidget:
// Usamos quando a tela precisa reagir a mudanças.
// Nesse caso, a tela muda sempre que o Firebase envia uma nova lista de tarefas.
class TelaTarefas extends StatefulWidget {

  // Construtor da tela
  const TelaTarefas({super.key});

  // Cria o estado da tela
  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}


// Classe responsável pela lógica e visual da tela de tarefas
class _TelaTarefasState extends State<TelaTarefas> {

  // Instância do serviço do banco de dados
  // Usamos para acessar o Realtime Database
  final DbService _dbService = DbService();

  // Instância do serviço de autenticação
  // Usamos para fazer logout do usuário
  final AuthService _authService = AuthService();


  // Função responsável por abrir o modal de nova tarefa
  void _mostrarModalNovaTarefa() {

    // Controller para capturar o texto digitado no campo do modal
    final controller = TextEditingController();

    // showDialog abre uma janela/modal sobre a tela atual
    showDialog(

      // context identifica onde o modal será exibido
      context: context,

      // builder constrói o conteúdo visual do modal
      builder: (context) => AlertDialog(

        // Cor de fundo do modal
        backgroundColor: const Color(0xFF1E1E1E),

        // Arredondamento das bordas do modal
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        // Título do modal
        title: const Text(
          'Nova Tarefa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Conteúdo principal do modal
        content: TextField(

          // Controller responsável por pegar o texto digitado
          controller: controller,

          // Cor do texto digitado
          style: const TextStyle(color: Colors.white),

          // Decoração do campo
          decoration: InputDecoration(

            // Texto de dica dentro do campo
            hintText: 'O que você precisa fazer?',

            hintStyle: const TextStyle(color: Colors.white54),

            // Ícone no início do campo
            prefixIcon: const Icon(
              Icons.task_alt,
              color: Colors.deepPurple,
            ),

            // Ativa fundo preenchido
            filled: true,

            // Cor do fundo do campo
            fillColor: const Color(0xFF2A2A2A),

            // Borda arredondada
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        // Botões do modal
        actions: [

          // Botão para fechar o modal sem salvar
          TextButton(

            // Fecha o modal
            onPressed: () => Navigator.pop(context),

            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),

          // Botão para salvar a tarefa
          ElevatedButton(

            // Função executada ao clicar em salvar
            onPressed: () {

              // Verifica se o campo não está vazio
              if (controller.text.trim().isNotEmpty) {

                // Cria a tarefa no Firebase
                _dbService.criarTarefa(controller.text.trim());

                // Fecha o modal
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


  // Método responsável por construir a interface da tela
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Cor de fundo da tela
      backgroundColor: const Color(0xFF121212),

      // Barra superior da tela
      appBar: AppBar(

        // Título da tela
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        // Centraliza o título
        centerTitle: true,

        // Fundo transparente para ficar mais moderno
        backgroundColor: Colors.transparent,

        // Remove sombra padrão da AppBar
        elevation: 0,

        // Ações do lado direito da AppBar
        actions: [

          // Botão de logout
          IconButton(

            // Ícone de sair
            icon: const Icon(Icons.exit_to_app),

            // Função executada ao clicar
            onPressed: () async {

              // Faz logout do usuário no Firebase
              await _authService.logout();

              // Verifica se a tela ainda existe antes de navegar
              if (mounted) {

                // Volta para a tela de login
                // pushReplacementNamed remove a tela atual da pilha
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          )
        ],
      ),

      // StreamBuilder:
      // Escuta dados em tempo real.
      // Sempre que o Firebase muda, a tela atualiza sozinha.
      body: StreamBuilder<List<Tarefa>>(

        // stream recebe a lista de tarefas vinda do Firebase
        stream: _dbService.lerTarefas(),

        // builder constrói a tela conforme o estado dos dados
        builder: (context, snapshot) {

          // connectionState.waiting:
          // significa que ainda está carregando os dados
          if (snapshot.connectionState == ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            );
          }

          // Pega a lista de tarefas.
          // Se vier nulo, usa uma lista vazia.
          final tarefas = snapshot.data ?? [];

          // Se não houver tarefas, mostra uma mensagem amigável
          if (tarefas.isEmpty) {

            return Center(

              child: Column(

                // Centraliza no meio da tela
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  // Ícone visual para tela vazia
                  Icon(
                    Icons.playlist_add_check_circle_outlined,
                    size: 90,
                    color: Colors.deepPurple.withOpacity(0.8),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Nenhuma tarefa ainda',
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
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }

          // Se tiver tarefas, exibe uma lista
          return ListView.builder(

            // Espaçamento da lista
            padding: const EdgeInsets.all(16),

            // Quantidade de itens da lista
            itemCount: tarefas.length,

            // itemBuilder cria cada item da lista
            itemBuilder: (context, index) {

              // Pega a tarefa atual pelo índice
              final tarefa = tarefas[index];

              // Card visual para cada tarefa
              return Container(

                margin: const EdgeInsets.only(bottom: 12),

                decoration: BoxDecoration(

                  // Cor do card
                  color: const Color(0xFF1E1E1E),

                  // Bordas arredondadas
                  borderRadius: BorderRadius.circular(18),

                  // Sombra suave
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: ListTile(

                  // Espaçamento interno do ListTile
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  // Checkbox para marcar tarefa como concluída
                  leading: Checkbox(

                    // Valor atual da tarefa
                    value: tarefa.concluida,

                    // Cor quando marcado
                    activeColor: Colors.deepPurple,

                    // Função chamada quando o usuário marca/desmarca
                    onChanged: (valor) {

                      // Atualiza o status no Firebase
                      // valor! significa que garantimos que não será nulo
                      _dbService.atualizarStatus(tarefa.id, valor!);
                    },
                  ),

                  // Título da tarefa
                  title: Text(

                    tarefa.titulo,

                    style: TextStyle(

                      // Se concluída, deixa texto riscado
                      decoration: tarefa.concluida
                          ? TextDecoration.lineThrough
                          : null,

                      // Cor muda se estiver concluída
                      color: tarefa.concluida
                          ? Colors.white38
                          : Colors.white,

                      fontSize: 16,

                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Botão de deletar
                  trailing: IconButton(

                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),

                    // Remove a tarefa do Firebase
                    onPressed: () => _dbService.deletarTarefa(tarefa.id),
                  ),
                ),
              );
            },
          );
        },
      ),

      // Botão flutuante para adicionar tarefa
      floatingActionButton: FloatingActionButton.extended(

        // Função executada ao clicar no botão
        onPressed: _mostrarModalNovaTarefa,

        // Cor do botão
        backgroundColor: Colors.deepPurple,

        // Ícone do botão
        icon: const Icon(Icons.add),

        // Cor do texto do botão
        foregroundColor: Colors.white,

        // Texto do botão
        label: const Text('Nova tarefa'),
      ),
    );
  }
}
