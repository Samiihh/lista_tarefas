// Classe Tarefa:
// Representa o modelo/estrutura de uma tarefa dentro do aplicativo.
//
// Model:
// No Flutter, usamos models para organizar os dados da aplicação.
// Essa classe representa como uma tarefa será armazenada e manipulada.
import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:nfc_manager/nfc_manager.dart';

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

  // Foto convertida para texto base64
  String? imageBase64;

  String? dataFinalizacao;

  // armazernar  hora e  minuto
  int? horaLembrete;
  int? minutoLembrete;

  double? latitude;
  double? longitude;

  String? nfcTag;

  // Construtor da classe Tarefa
  //
  // required:
  // significa que o valor é obrigatório na criação do objeto.
  //
  // this.concluida = false
  // define um valor padrão caso nenhum valor seja informado.
  Tarefa({
    required this.id,
    required this.titulo,
    this.concluida = false,
    this.imageBase64,
    this.dataFinalizacao,
    this.horaLembrete,
    this.minutoLembrete,
    this.latitude,
    this.longitude,
    this.nfcTag,
  });

  bool get temImagem => imageBase64 != null && imageBase64!.isNotEmpty;
  bool get temLocalizacao => latitude != null && longitude != null;
  bool get temNfcTag => nfcTag != null && nfcTag!.isNotEmpty;
  bool get temDataFinalizacao =>
      dataFinalizacao != null && dataFinalizacao!.isNotEmpty;

  int get horaLembreteEfetiva => horaLembrete ?? 9;
  int get minutoLembreteEfetivo => minutoLembrete ?? 0;

  String get horarioLembreteFormatado {
    final h = horaLembreteEfetiva.toString().padLeft(2, '0');
    final m = minutoLembreteEfetivo.toString().padLeft(2, '0');
    return '$h:$m';
  }

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

      imageBase64: json['imageBase64'] as String?,
      dataFinalizacao: json['dataFinalizacao'] as String?,
      horaLembrete: _parseInt(json['horaLembrete']),
      minutoLembrete: _parseInt(json['minutoLembrete']),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      nfcTag: json['nfcTag'] as String?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
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
      if (temImagem) 'imageBase64': imageBase64,
      if (temDataFinalizacao) 'temDataFinalizacao': temDataFinalizacao,
      if (temDataFinalizacao) 'horaLembrete': horaLembreteEfetiva,
      if (temDataFinalizacao) 'minutoLembrete': minutoLembreteEfetivo,
      if (temLocalizacao) 'latitude': latitude,
      if (temLocalizacao) 'longitude': longitude,
      if (temNfcTag) 'nfcTag': nfcTag,
    };
  }

  Tarefa copyWith({
    String? titulo,
    bool? concluida,
    String? imageBase64,
    bool removerImage = false,
    String? dataFinalizacao,
    bool removerData = false,
    int? horaLembrete,
    int? minutoLembrete,
    double? latitude,
    double? longitude,
    bool removerLocalizacao = false,
    String? nfcTag,
    bool removerNfc = false,
  }) {
    final data = _resolverData(
      remover: removerData,
      novaData: dataFinalizacao,
      novaHora: horaLembrete,
      novoMinuto: minutoLembrete,
    );

    final coords = _resolverLocalizacao(
      remover: removerLocalizacao,
      novaLatitude: latitude,
      novaLongitude: longitude,
    );

    return Tarefa(
      id: id,
      titulo: titulo ?? this.titulo,
      concluida: concluida ?? this.concluida,
      imageBase64: _resolverOpcional(
        remover: removerImage,
        novoValor: imageBase64,
        valorAtual: this.imageBase64,
      ),
      dataFinalizacao: data.data,
      horaLembrete: data.hora,
      minutoLembrete: data.minuto,
      latitude: coords.latitude,
      longitude: coords.longitude,
      nfcTag: _resolverOpcional(
        remover: removerNfc,
        novoValor: nfcTag,
        valorAtual: this.nfcTag,
      ),
    );
  }

  T? _resolverOpcional<T>({
    required bool remover,
    T? novoValor,
    required T? valorAtual,
  }) {
    if (remover) return null;
    return novoValor ?? valorAtual;
  }

  ({String? data, int? hora, int? minuto}) _resolverData({
    required bool remover,
    String? novaData,
    int? novaHora,
    int? novoMinuto,
  }) {
    if (remover) return (data: null, hora: null, minuto: null);
    return (
      data: novaData ?? dataFinalizacao,
      hora: novaHora ?? horaLembrete,
      minuto: novoMinuto ?? minutoLembrete,
    );
  }

  ({double? latitude, double? longitude}) _resolverLocalizacao({
    required bool remover,
    double? novaLatitude,
    double? novaLongitude,
  }) {
    if (remover) return (latitude: null, longitude: null);
    return (
      latitude: novaLatitude ?? latitude,
      longitude: novaLongitude ?? longitude,
    );
  }
}
