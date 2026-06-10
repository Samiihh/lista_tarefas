// Classe Tarefa:
// Representa o modelo/estrutura de uma tarefa dentro do aplicativo.
//
// Model:
// No Flutter, usamos models para organizar os dados da aplicação.
// Essa classe representa como uma tarefa será armazenada e manipulada.
class Tarefa {
  // ID único da tarefa
  // Esse ID normalmente vem do Firebase automaticamente.
  //
  // Exemplo:
  // -Oabc123XYZ
  String id;

  // Título da tarefa
  // Exemplo:
  // "Estudar Flutter"
  String titulo;

  // Boolean:
  // true  = tarefa concluída
  // false = tarefa pendente
  bool concluida;

  // Construtor da classe Tarefa
  //
  // required:
  // significa que o valor é obrigatório na criação do objeto.
  //
  // this.concluida = false
  // define um valor padrão caso nenhum valor seja informado.
  Tarefa({required this.id, required this.titulo, this.concluida = false});

  // factory:
  // Construtor especial usado para criar objetos
  // a partir de dados externos.
  //
  // Nesse caso:
  // converte os dados vindos do Firebase
  // em um objeto Tarefa.
  //
  // fromJson:
  // significa "criar a partir de JSON".
  //
  // JSON:
  // formato de dados muito utilizado em APIs e bancos NoSQL.
  factory Tarefa.fromJson(
    // json:
    // dados vindos do Firebase
    Map<dynamic, dynamic> json,

    // id da tarefa no Firebase
    String id,
  ) {
    // Retorna um novo objeto Tarefa
    return Tarefa(
      // ID recebido do Firebase
      id: id,

      // Pega o título dentro do JSON
      //
      // Exemplo:
      // json['titulo'] => "Estudar Flutter"
      titulo: json['titulo'],

      // Pega o valor de concluída
      //
      // ?? false:
      // Se vier nulo, assume false como padrão
      concluida: json['concluida'] ?? false,
    );
  }

  // Método responsável por converter
  // o objeto Tarefa para JSON.
  //
  // Isso é usado para enviar os dados
  // para o Firebase.
  Map<String, dynamic> toJson() {
    // Retorna um Map
    //
    // Map:
    // estrutura chave/valor
    //
    // Exemplo:
    // "titulo": "Estudar Flutter"
    return {
      // Campo titulo
      'titulo': titulo,

      // Campo concluida
      'concluida': concluida,
    };
  }
}
