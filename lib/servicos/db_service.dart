// Importa a biblioteca async do Dart
//
// Essa biblioteca fornece recursos para:
// - Future
// - async/await
// - TimeoutException
import 'dart:async';


// Importa o Firebase Authentication
//
// Responsável por:
// - login
// - cadastro
// - logout
// - controle de usuário autenticado
import 'package:firebase_auth/firebase_auth.dart';


// Classe responsável pelos serviços de autenticação
//
// Aqui centralizamos toda lógica de login/cadastro/logout
// deixando o código mais organizado.
class AuthService {

  // Cria uma instância do Firebase Authentication
  //
  // FirebaseAuth.instance:
  // acessa a instância principal do Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Getter:
  // Retorna o usuário atual autenticado.
  //
  // User?:
  // significa que o retorno pode ser:
  // - um usuário
  // - ou null
  //
  // null = ninguém logado
  User? get usuarioAtual => _auth.currentUser;


  // Função responsável por cadastrar usuário
  //
  // Future:
  // indica que é uma operação assíncrona.
  //
  // UserCredential:
  // objeto retornado pelo Firebase após autenticação.
  Future<UserCredential> cadastrar(

    // E-mail digitado pelo usuário
    String email,

    // Senha digitada pelo usuário
    String senha,
  ) async {

    try {

      // createUserWithEmailAndPassword:
      // cria usuário no Firebase Authentication
      return await _auth

          .createUserWithEmailAndPassword(

            // E-mail enviado para o Firebase
            email: email,

            // Senha enviada para o Firebase
            password: senha,
          )

          // timeout:
          // define um tempo máximo para a operação
          //
          // Se passar de 20 segundos:
          // dispara TimeoutException
          .timeout(const Duration(seconds: 20));



    // Captura erros específicos do Firebase Authentication
    } on FirebaseAuthException catch (e) {

      // Lança uma Exception personalizada
      // usando mensagens mais amigáveis
      throw Exception(_mensagemErroAuth(e));


    // Captura erro de tempo excedido
    } on TimeoutException {

      throw Exception(

        'Tempo esgotado. Verifique sua internet e tente novamente.',
      );


    // Captura qualquer outro erro inesperado
    } catch (e) {

      throw Exception('Erro ao cadastrar: $e');
    }
  }


  // Função responsável pelo login
  Future<UserCredential> login(

    // E-mail do usuário
    String email,

    // Senha do usuário
    String senha,
  ) async {

    try {

      // signInWithEmailAndPassword:
      // faz login no Firebase Authentication
      return await _auth

          .signInWithEmailAndPassword(

            // E-mail enviado
            email: email,

            // Senha enviada
            password: senha,
          )

          // Limite máximo de tempo
          .timeout(const Duration(seconds: 20));



    // Captura erros específicos do Firebase
    } on FirebaseAuthException catch (e) {

      // Converte o erro técnico
      // para uma mensagem amigável
      throw Exception(_mensagemErroAuth(e));


    // Captura timeout
    } on TimeoutException {

      throw Exception(

        'Tempo esgotado. Verifique sua internet e tente novamente.',
      );


    // Captura erros genéricos
    } catch (e) {

      throw Exception('Erro ao fazer login: $e');
    }
  }


  // Função responsável pelo logout
  Future<void> logout() async {

    // signOut:
    // desconecta o usuário atual do Firebase
    await _auth.signOut();
  }


  // Função privada responsável por traduzir
  // os erros técnicos do Firebase
  //
  // _ no início:
  // significa que a função é privada
  // e só pode ser usada dentro desta classe.
  String _mensagemErroAuth(

    // Objeto de erro vindo do Firebase
    FirebaseAuthException erro,
  ) {

    // switch:
    // verifica qual foi o código do erro
    switch (erro.code) {


      // E-mail já cadastrado
      case 'email-already-in-use':

        return 'Este e-mail ja esta cadastrado.';


      // E-mail inválido
      case 'invalid-email':

        return 'Digite um e-mail valido.';


      // Senha fraca
      case 'weak-password':

        return 'A senha precisa ter pelo menos 6 caracteres.';


      // Problema de conexão
      case 'network-request-failed':

        return 'Falha de conexao. Verifique sua internet.';


      // Método de autenticação desabilitado no Firebase
      case 'operation-not-allowed':

        return 'Cadastro por e-mail e senha nao esta habilitado no Firebase.';


      // Qualquer outro erro
      default:

        // erro.message:
        // mensagem original do Firebase
        //
        // ??:
        // se vier null, usa a mensagem padrão
        return erro.message ?? 'Erro de autenticacao.';
    }
  }
}
