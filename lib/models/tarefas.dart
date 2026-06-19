// =============================================================================
// Model Tarefa — Aula 2: Campos ampliados para recursos nativos
// =============================================================================
//
// O QUE É ESTE ARQUIVO?
//   Representa UMA tarefa do app — o "molde" dos dados que vão pro Firebase.
//
// ONDE É USADO?
//   - DbService        → salva e lê tarefas (toJson / fromJson)
//   - tela_tarefas     → lista de tarefas (getters temImagem, temLocalizacao...)
//   - tela_detalhe     → criar/editar tarefa (copyWith na edição)
//   - tela_mapa        → exibe latitude/longitude no mapa
//   - NotificacaoService → usa data + hora para agendar lembrete
//
// FLUXO DE DADOS:
//
//   [Salvar]  Tarefa → toJson() → Map → Firebase
//   [Ler]     Firebase → Map → fromJson() → Tarefa
//   [Editar]  Tarefa antiga → copyWith() → Tarefa nova → toJson() → Firebase
//
// ESTRUTURA NO FIREBASE:
//   tarefas/
//     {uidDoUsuario}/
//       {idDaTarefa}/
//         titulo, concluida, imagemBase64, dataFinalizacao,
//         horaLembrete, minutoLembrete, latitude, longitude, nfcTag

import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:nfc_manager/nfc_manager.dart';

class Tarefa {

  // ID único da tarefa
  // Esse ID normalmente vem do Firebase automaticamente.
  //
  // Exemplo:
  // -Oabc123XYZ
  String id;

  // Nome da tarefa digitado pelo usuário
  String titulo;

  // false = pendente | true = concluída (checkbox na lista)
  // Ao marcar true → tela_tarefas dispara notificação de conclusão
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
  // ===========================================================================
  // CAMPOS OPCIONAIS — preenchidos conforme o usuário usa recursos nativos
  // String?, int?, double? → o "?" significa que pode ser null (vazio)
  // ===========================================================================

  // --- Aula 3: Imagem (câmera / galeria) ---
  // Foto comprimida em texto base64 — salva direto no Firebase (sem Storage)
  // Usado em: preview na tela_detalhe, miniatura na tela_tarefas
  String? imagemBase64;

  // --- Aula 5: Data e lembrete ---
  // Prazo no formato ISO: "2026-06-25" (facilita DateTime.tryParse)
  // Usado em: DatePicker na tela_detalhe, texto "Prazo:" na lista
  String? dataFinalizacao;

  // Horário do lembrete no dia do prazo (0–23 e 0–59)
  // Usado em: showTimePicker na tela_detalhe, NotificacaoService.agendarLembrete
  int? horaLembrete;
  int? minutoLembrete;

  // --- Aula 6: Localização (GPS + mapa) ---
  // Coordenadas lidas pelo geolocator — exibidas no flutter_map (OpenStreetMap)
  // Usado em: MapaTarefaWidget, botão "Ver mapa" na lista
  double? latitude;
  double? longitude;

  // --- Aula 7: NFC ---
  // Texto lido da tag NFC — associado à tarefa
  // Usado em: botão "Ler tag NFC" na tela_detalhe, ícone na lista
  String? nfcTag;

  // ===========================================================================
  // CONSTRUTOR — cria uma instância de Tarefa
  // ===========================================================================
  //
  // required → obrigatório passar ao criar
  // concluida = false → tarefa nova já começa como pendente
  //
  // Exemplo — nova tarefa (tela_detalhe_tarefa.dart):
  //   Tarefa(id: '', titulo: 'Estudar', imagemBase64: fotoBase64, ...)
  Tarefa({
    required this.id,
    required this.titulo,
    this.concluida = false,
    this.imagemBase64,
    this.dataFinalizacao,
    this.horaLembrete,
    this.minutoLembrete,
    this.latitude,
    this.longitude,
    this.nfcTag,
  });

  // ===========================================================================
  // GETTERS AUXILIARES — a UI pergunta "tem X?" em vez de repetir if longos
  // ===========================================================================
  //
  // Centralizamos a lógica aqui. Se a regra mudar, alteramos só neste arquivo.
  //
  // Onde cada getter aparece:
  //   temImagem          → tela_tarefas (miniatura), toJson
  //   temLocalizacao     → tela_tarefas ("Ver mapa"), toJson, tela_mapa
  //   temNfc             → tela_tarefas (ícone NFC), toJson
  //   temDataFinalizacao → tela_tarefas ("Prazo:"), toJson, agendar lembrete

  // true quando imagemBase64 existe e não está vazia
  bool get temImagem => imagemBase64 != null && imagemBase64!.isNotEmpty;

  // true quando latitude E longitude existem (precisa dos dois para o mapa)
  bool get temLocalizacao => latitude != null && longitude != null;

  // true quando nfcTag foi lida e não está vazia
  bool get temNfc => nfcTag != null && nfcTag!.isNotEmpty;

  // true quando o usuário definiu um prazo
  bool get temDataFinalizacao =>
      dataFinalizacao != null && dataFinalizacao!.isNotEmpty;

  // Hora/minuto com valor padrão 09:00 se não definidos (tarefas antigas no Firebase)
  // O operador ?? significa: "se for null, use este valor"
  int get horaLembreteEfetiva => horaLembrete ?? 9;
  int get minutoLembreteEfetivo => minutoLembrete ?? 0;

  // Formata "14:30" para exibir na lista e na tela de detalhe
  // padLeft(2, '0') → 9 vira "09", 0 vira "00"
  String get horarioLembreteFormatado {
    final h = horaLembreteEfetiva.toString().padLeft(2, '0');
    final m = minutoLembreteEfetivo.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ===========================================================================
  // fromJson — Firebase (Map) → objeto Tarefa (Dart)
  // ===========================================================================
  //
  // factory → construtor especial para criar Tarefa a partir de JSON
  //
  // Chamado em: DbService.lerTarefas() — cada item do Firebase vira uma Tarefa
  //
  // Parâmetros:
  //   json → dados lidos do Firebase (Map)
  //   id   → chave do nó (ex: "-Nx8k2j...")
  factory Tarefa.fromJson(Map<dynamic, dynamic> json, String id) {
    return Tarefa(
      id: id,
      // ?? '' e ?? false → se o campo não existir no Firebase, usa valor padrão
      titulo: json['titulo'] ?? '',
      concluida: json['concluida'] ?? false,
      imagemBase64: json['imagemBase64'] as String?,
      dataFinalizacao: json['dataFinalizacao'] as String?,
      horaLembrete: _parseInt(json['horaLembrete']),
      minutoLembrete: _parseInt(json['minutoLembrete']),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      nfcTag: json['nfcTag'] as String?,

      imageBase64: json['imageBase64'] as String?,
      dataFinalizacao: json['dataFinalizacao'] as String?,
      horaLembrete: _parseInt(json['horaLembrete']),
      minutoLembrete: _parseInt(json['minutoLembrete']),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      nfcTag: json['nfcTag'] as String?,
    );
  }

  // Converte número do Firebase para double (GPS)
  // Firebase pode retornar int ou double — normalizamos para double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  // Converte número do Firebase para int (hora/minuto do lembrete)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  // ===========================================================================
  // toJson — objeto Tarefa (Dart) → Map → Firebase
  // ===========================================================================
  //
  // Chamado em: DbService.criarTarefa() e DbService.atualizarTarefa()
  //
  // Campos obrigatórios (sempre salvos): titulo, concluida
  //
  // Campos opcionais: só entram se o getter for true (collection-if)
  //   if (temImagem) 'imagemBase64': ...  → chave nem aparece se não tiver foto
  //
  // Usamos os getters (temImagem, temDataFinalizacao...) — mesma regra da UI
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'concluida': concluida,

      // Aula 3
      if (temImagem) 'imagemBase64': imagemBase64,

      // Aula 5 — data e horário do lembrete vão juntos
      if (temDataFinalizacao) 'dataFinalizacao': dataFinalizacao,
      if (temDataFinalizacao) 'horaLembrete': horaLembreteEfetiva,
      if (temDataFinalizacao) 'minutoLembrete': minutoLembreteEfetivo,

      // Aula 6
      if (temLocalizacao) 'latitude': latitude,
      if (temLocalizacao) 'longitude': longitude,

      // Aula 7
      if (temNfc) 'nfcTag': nfcTag,
    };
  }

  // ===========================================================================
  // copyWith — copia a tarefa alterando só o necessário (EDIÇÃO)
  // ===========================================================================
  //
  // Chamado em: tela_detalhe_tarefa.dart → _salvar() ao editar tarefa existente
  //
  // Por que não criar Tarefa(...) do zero?
  //   Porque na edição só mudam alguns campos — copyWith mantém o resto.
  //
  // Regra de cada campo opcional:
  //   1. removerX == true     → apaga (null) — usuário removeu na tela
  //   2. novoValor informado  → usa o valor novo
  //   3. senão                → mantém valor antigo (this.campo)
  //
  // Por que removerImagem / removerData / etc.?
  //   null no copyWith significa "não mudou" (null ?? antigo = antigo).
  //   Para APAGAR um campo, precisamos da flag removerX: true.
  //
  // Exemplo na tela_detalhe:
  //   widget.tarefa!.copyWith(
  //     titulo: 'Novo título',
  //     imagemBase64: _imagemBase64,
  //     removerImagem: _imagemBase64 == null,
  //     removerData: _dataFinalizacao == null,
  //   )
  Tarefa copyWith({
    String? titulo,
    bool? concluida,
    String? imagemBase64,
    bool removerImagem = false,
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
    return Tarefa(
      id: id, // ID nunca muda na edição
      titulo: titulo ?? this.titulo,
      concluida: concluida ?? this.concluida,

      // Aula 3 — imagem
      imagemBase64: removerImagem ? null : (imagemBase64 ?? this.imagemBase64),

      // Aula 5 — removerData limpa data + hora + minuto juntos
      dataFinalizacao:
          removerData ? null : (dataFinalizacao ?? this.dataFinalizacao),
      horaLembrete: removerData ? null : (horaLembrete ?? this.horaLembrete),
      minutoLembrete:
          removerData ? null : (minutoLembrete ?? this.minutoLembrete),

      // Aula 6 — removerLocalizacao limpa latitude e longitude juntos
      latitude: removerLocalizacao ? null : (latitude ?? this.latitude),
      longitude: removerLocalizacao ? null : (longitude ?? this.longitude),

      // Aula 7 — NFC
      nfcTag: removerNfc ? null : (nfcTag ?? this.nfcTag),
    );
  }
}
