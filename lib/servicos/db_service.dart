// Importa o pacote do Firebase Realtime Database
//
// Responsável por:
// - criar dados
// - ler dados
// - atualizar dados
// - remover dados
import 'package:firebase_database/firebase_database.dart';

// Importa o model Tarefa
//
// Esse model representa uma tarefa dentro do aplicativo.
import '../models/tarefas.dart';

// Importa o serviço de autenticação
//
// Precisamos dele para descobrir qual usuário está logado.
import 'auth_service.dart';


// Classe responsável por todas as operações
// relacionadas ao banco de dados.
//
// Aqui centralizamos o CRUD:
//
// C = Create (Criar)
// R = Read (Ler)
// U = Update (Atualizar)
// D = Delete (Excluir)
class DbService {

  // Cria uma referência para a raiz do Firebase
  //
  // Exemplo:
  // Firebase
  // ├── tarefas
  // └── usuarios
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Instância do serviço de autenticação
  //
  // Será utilizada para descobrir
  // qual usuário está logado.
  final AuthService _auth = AuthService();


  // Getter privado responsável por retornar
  // a pasta correta das tarefas do usuário.
  //
  // Exemplo:
  //
  // tarefas/
  //    UID_123/
  //       tarefa1
  //       tarefa2
  //
  // Cada usuário possui sua própria pasta.
  DatabaseReference get _tarefasRef {

    // Obtém o UID do usuário logado
    //
    // Exemplo:
    // "aBc123XyZ"
    final uid = _auth.usuarioAtual?.uid;

    // Verifica se existe usuário autenticado
    if (uid == null) {

      throw Exception('Usuário não logado');
    }

    // Retorna a referência:
    //
    // tarefas/UID_DO_USUARIO
    return _db

        // Entra na pasta "tarefas"
        .child('tarefas')

        // Entra na pasta do usuário atual
        .child(uid);
  }


  // ===================================================
  // CREATE (POST)
  // ===================================================
  //
  // Responsável por criar uma nova tarefa
  Future<void> criarTarefa(

    // Título digitado pelo usuário
    String titulo,
  ) async {

    // push():
    //
    // Cria uma nova referência com ID automático
    //
    // Exemplo:
    //
    // -Oabc123XYZ
    // -Oabc456ABC
    //
    // Isso evita sobrescrever registros existentes.
    final novaTarefaRef = _tarefasRef.push();

    // Salva os dados no Firebase
    await novaTarefaRef.set({

      // Título da tarefa
      'titulo': titulo,

      // Status inicial
      // Toda tarefa nasce como não concluída
      'concluida': false,
    });
  }


  // ===================================================
  // READ (GET)
  // ===================================================
  //
  // Retorna um Stream de tarefas.
  //
  // Stream:
  // permite receber atualizações em tempo real.
  //
  // Sempre que o Firebase muda,
  // a interface atualiza automaticamente.
  Stream<List<Tarefa>> lerTarefas() {

    // onValue:
    //
    // Escuta mudanças em tempo real
    return _tarefasRef.onValue.map((event) {

      // Obtém os dados vindos do Firebase
      //
      // Exemplo:
      //
      // {
      //   "-abc123": {
      //      "titulo":"Estudar",
      //      "concluida":false
      //   }
      // }
      final map = event.snapshot.value as Map<dynamic, dynamic>?;

      // Se não existir nenhuma tarefa
      // retorna uma lista vazia
      if (map == null) return [];

      // Converte cada registro do Firebase
      // para um objeto Tarefa
      return map.entries.map((e) {

        // e.key = ID da tarefa
        //
        // e.value = dados da tarefa
        return Tarefa.fromJson(

          // Dados da tarefa
          e.value,

          // ID da tarefa
          e.key,
        );

      }).toList();
    });
  }


  // ===================================================
  // UPDATE (PUT / PATCH)
  // ===================================================
  //
  // Atualiza o status da tarefa
  //
  // Exemplo:
  // false -> true
  // true -> false
  Future<void> atualizarStatus(

    // ID da tarefa
    String id,

    // Novo status
    bool concluida,
  ) async {

    // Localiza a tarefa pelo ID
    await _tarefasRef

        .child(id)

        .update({

          // Atualiza apenas o campo concluida
          'concluida': concluida,
        });
  }


  // ===================================================
  // DELETE
  // ===================================================
  //
  // Remove uma tarefa do Firebase
  Future<void> deletarTarefa(

    // ID da tarefa a ser removida
    String id,
  ) async {

    // Localiza a tarefa pelo ID
    await _tarefasRef

        .child(id)

        // Remove completamente do banco
        .remove();
  }
}
