// Importa os componentes visuais do Flutter
//
// Exemplo:
// - MaterialApp
// - ThemeData
// - Widgets básicos
import 'package:flutter/material.dart';


// Importa o núcleo do Firebase
//
// Necessário para inicializar o Firebase
// antes de utilizar Authentication,
// Realtime Database, Firestore, etc.
import 'package:firebase_core/firebase_core.dart';


// Arquivo gerado automaticamente pelo FlutterFire
//
// Contém as configurações do Firebase:
//
// - API Key
// - Project ID
// - App ID
// - Configurações Android/Web/iOS
import 'firebase_options.dart';


// Importa as telas do sistema
import 'telas/tela_login.dart';
import 'telas/tela_cadastro.dart';
import 'telas/tela_tarefas.dart';


// Importa o serviço de autenticação
//
// Será utilizado para verificar
// se existe um usuário logado.
import 'servicos/auth_service.dart';


// ======================================================
// FUNÇÃO PRINCIPAL DO APP
// ======================================================
//
// Todo aplicativo Flutter começa aqui.
void main() async {

  // Garante que o Flutter seja inicializado
  // antes de executar código assíncrono.
  //
  // É obrigatório quando usamos:
  // - Firebase
  // - SharedPreferences
  // - Banco de dados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  //
  // Sem essa linha o Firebase não funciona.
  await Firebase.initializeApp(

    // Configura automaticamente a plataforma atual
    //
    // Android -> usa configuração Android
    // Web -> usa configuração Web
    // iOS -> usa configuração iOS
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicia o aplicativo
  runApp(const AppTarefas());
}


// ======================================================
// WIDGET PRINCIPAL DO SISTEMA
// ======================================================
//
// StatelessWidget:
//
// Utilizado quando o widget não precisa
// atualizar informações internamente.
class AppTarefas extends StatelessWidget {

  // Construtor da classe
  const AppTarefas({super.key});

  @override
  Widget build(BuildContext context) {

    // Verifica se existe usuário autenticado
    //
    // usuarioAtual retorna:
    //
    // User -> existe usuário logado
    // null -> ninguém logado
    final usuarioLogado =
        AuthService().usuarioAtual != null;

    // MaterialApp:
    //
    // Widget principal responsável por:
    //
    // - Tema
    // - Rotas
    // - Navegação
    // - Configurações globais
    return MaterialApp(

      // Nome do aplicativo
      title: 'App de Tarefas',

      // Tema global do sistema
      //
      // Todas as telas herdarão esse tema
      theme: ThemeData(

        // Cor principal do aplicativo
        primarySwatch: Colors.blue,
      ),

      // Remove a faixa DEBUG
      //
      // Antes:
      // [DEBUG]
      //
      // Depois:
      // sem a faixa vermelha
      debugShowCheckedModeBanner: false,

      // ==================================================
      // TELA INICIAL
      // ==================================================
      //
      // Operador ternário:
      //
      // condição ? valorSeTrue : valorSeFalse
      //
      // Se existir usuário logado:
      //
      // vai direto para tarefas
      //
      // Caso contrário:
      //
      // abre a tela de login
      initialRoute:

          usuarioLogado

              ? '/tarefas'

              : '/login',

      // ==================================================
      // ROTAS DO SISTEMA
      // ==================================================
      //
      // Mapa contendo todas as páginas.
      routes: {

        // Rota da tela de login
        '/login': (context) =>
            const TelaLogin(),

        // Rota da tela de cadastro
        '/cadastro': (context) =>
            const TelaCadastro(),

        // Rota da tela principal de tarefas
        '/tarefas': (context) =>
            const TelaTarefas(),
      },
    );
  }
}
