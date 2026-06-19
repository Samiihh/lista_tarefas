// Importa a biblioteca visual principal do Flutter.
// É ela que permite usar widgets prontos como:
// Scaffold, Text, TextField, Column, Container, Button, Icon etc.
import 'package:flutter/material.dart';

// Importa o serviço de autenticação criado no projeto.
// Esse arquivo separa a lógica do Firebase da tela visual.
// Assim, a tela não precisa saber diretamente como o Firebase funciona;
// ela apenas chama métodos como login(), cadastrar() e logout().
import '../servicos/auth_service.dart';

// TelaLogin é um StatefulWidget porque essa tela precisa mudar durante o uso.
//
// Exemplo:
// - quando o usuário clica em "Entrar", aparece um loading;
// - se der erro, aparece uma mensagem;
// - se der certo, muda para a tela de tarefas.
//
// Sempre que uma tela precisa mudar visualmente, usamos StatefulWidget.
class TelaLogin extends StatefulWidget {
  // Construtor da tela.
  // O super.key ajuda o Flutter a identificar esse widget na árvore de widgets.
  const TelaLogin({super.key});

  // Cria o estado da tela.
  // A parte visual principal e a lógica ficarão dentro da classe _TelaLoginState.
  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

// Classe de estado da TelaLogin.
// Aqui ficam:
// - variáveis;
// - controllers;
// - funções;
// - construção da interface.
class _TelaLoginState extends State<TelaLogin> {
  // Controller do campo de e-mail.
  //
  // Ele serve para controlar e capturar o texto digitado no TextField.
  //
  // Exemplo:
  // Se o usuário digitar "teste@email.com",
  // conseguimos acessar esse valor usando:
  //
  // _emailController.text
  final _emailController = TextEditingController();

  // Controller do campo de senha.
  //
  // Funciona igual ao controller do e-mail,
  // mas será usado para capturar a senha digitada pelo usuário.
  final _senhaController = TextEditingController();

  // Cria uma instância do AuthService.
  //
  // O AuthService é a classe responsável por conversar com o Firebase Authentication.
  //
  // Nesta tela usaremos principalmente o método:
  // _authService.login(email, senha)
  final _authService = AuthService();

  // Variável de controle de carregamento.
  //
  // false = não está carregando, então mostra o botão "Entrar".
  // true = está carregando, então mostra o spinner.
  //
  // Essa variável é usada para dar feedback visual ao usuário.
  bool _carregando = false;

  // Função responsável por fazer login.
  //
  // Future<void> significa que essa função é assíncrona:
  // ela executa algo que pode demorar, como uma chamada ao Firebase pela internet.
  //
  // void significa que ela não retorna nenhum valor para quem chamou.
  Future<void> _fazerLogin() async {
    // Primeiro validamos os campos.
    //
    // _emailController.text pega o texto digitado.
    // trim() remove espaços antes e depois.
    // isEmpty verifica se ficou vazio.
    //
    // Isso evita enviar dados vazios para o Firebase.
    if (_emailController.text.trim().isEmpty ||
        _senhaController.text.trim().isEmpty) {
      // ScaffoldMessenger exibe mensagens temporárias na tela.
      //
      // showSnackBar mostra uma barra de aviso na parte inferior.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // Texto exibido dentro do SnackBar.
          content: Text('Preencha o e-mail e a senha.'),

          // Cor de fundo da mensagem.
          backgroundColor: Colors.red,
        ),
      );

      // return encerra a função aqui.
      //
      // Ou seja:
      // se os campos estiverem vazios,
      // ele mostra o aviso e não tenta fazer login.
      return;
    }

    // setState avisa o Flutter que algo mudou na tela.
    //
    // Aqui mudamos _carregando para true.
    //
    // Como essa variável controla se aparece botão ou loading,
    // a tela será reconstruída e o botão será substituído pelo spinner.
    setState(() => _carregando = true);

    try {
      // try significa:
      // "tente executar esse código".
      //
      // Colocamos aqui operações que podem dar erro.
      // Login no Firebase pode falhar por senha errada,
      // usuário inexistente, internet ruim etc.

      // Chama o método login do AuthService.
      //
      // Esse método recebe:
      // 1. e-mail digitado
      // 2. senha digitada
      //
      // O await espera o Firebase responder antes de continuar.
      await _authService.login(
        // Envia o e-mail sem espaços extras.
        _emailController.text.trim(),

        // Envia a senha sem espaços extras.
        _senhaController.text.trim(),
      );

      // mounted verifica se essa tela ainda existe.
      //
      // Isso é importante porque o login é assíncrono.
      // Enquanto o Firebase está respondendo, o usuário poderia sair da tela.
      //
      // Se tentarmos navegar ou atualizar uma tela que não existe mais,
      // o Flutter pode gerar erro.
      if (mounted) {
        // Se o login deu certo, navega para a tela de tarefas.
        //
        // pushReplacementNamed substitui a tela atual pela nova tela.
        //
        // Isso impede que o usuário aperte "voltar"
        // e retorne para a tela de login depois de estar autenticado.
        Navigator.pushReplacementNamed(context, '/tarefas');
      }
    } catch (e) {
      // catch captura qualquer erro que acontecer dentro do try.
      //
      // Exemplos:
      // - senha incorreta;
      // - usuário não encontrado;
      // - e-mail inválido;
      // - falha de conexão;
      // - erro vindo do Firebase.

      // Verifica se a tela ainda existe antes de mostrar a mensagem.
      if (mounted) {
        // Mostra o erro para o usuário usando SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // e.toString() transforma o erro em texto.
            content: Text(e.toString()),

            // Define a cor vermelha para indicar erro.
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // finally sempre executa.
      //
      // Não importa se:
      // - o login deu certo;
      // - o login deu erro.
      //
      // Ele é ideal para finalizar processos,
      // como desligar o loading.

      // Verifica se a tela ainda existe.
      if (mounted) {
        // Desativa o loading.
        //
        // Com isso, o spinner some e o botão volta a aparecer.
        setState(() => _carregando = false);
      }
    }
  }

  // dispose é executado quando a tela é removida da memória.
  //
  // Como criamos controllers, precisamos descartá-los manualmente.
  //
  // Isso evita vazamento de memória.
  @override
  void dispose() {
    // Descarta o controller do campo de e-mail.
    _emailController.dispose();

    // Descarta o controller do campo de senha.
    _senhaController.dispose();

    // Chama o dispose da classe pai.
    // Boa prática obrigatória quando sobrescrevemos dispose().
    super.dispose();
  }

  // build é o método responsável por construir a interface visual da tela.
  //
  // Sempre que o setState é chamado,
  // o Flutter executa o build novamente para atualizar a tela.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold é a estrutura base de uma tela no Flutter.
      //
      // Ele pode ter:
      // - AppBar;
      // - Body;
      // - FloatingActionButton;
      // - Drawer;
      // - BottomNavigationBar.
      //
      // Aqui usamos apenas o body.

      // Define a cor de fundo da tela.
      backgroundColor: const Color(0xFF121212),

      // SafeArea evita que o conteúdo fique por baixo de áreas do sistema,
      // como barra de status, notch ou bordas do aparelho.
      body: SafeArea(
        // Center centraliza o conteúdo na tela.
        child: Center(
          // SingleChildScrollView permite rolagem.
          //
          // Isso é importante para telas menores,
          // porque evita que o teclado ou pouco espaço quebre o layout.
          child: SingleChildScrollView(
            // Padding adiciona espaçamento interno nas bordas da tela.
            child: Padding(
              padding: const EdgeInsets.all(24.0),

              // Column organiza os widgets na vertical.
              child: Column(
                // Centraliza os elementos verticalmente dentro da coluna.
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // Container usado para criar o bloco visual do ícone.
                  Container(
                    // Largura do container.
                    width: 100,

                    // Altura do container.
                    height: 100,

                    // decoration permite estilizar o Container.
                    decoration: BoxDecoration(
                      // Cor de fundo do container.
                      color: Colors.deepPurple,

                      // Bordas arredondadas.
                      borderRadius: BorderRadius.circular(30),

                      // Sombra do container.
                      boxShadow: [
                        BoxShadow(
                          // Cor da sombra com transparência.
                          color: Colors.deepPurple.withOpacity(0.4),

                          // Espalhamento/suavidade da sombra.
                          blurRadius: 20,

                          // Posição da sombra:
                          // x = 0, y = 10.
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    // Ícone dentro do container.
                    child: const Icon(
                      // Ícone de check.
                      Icons.check_circle_outline,

                      // Cor do ícone.
                      color: Colors.white,

                      // Tamanho do ícone.
                      size: 50,
                    ),
                  ),

                  // Espaço vertical entre o ícone e o título.
                  const SizedBox(height: 30),

                  // Título principal da tela.
                  const Text(
                    'App de Tarefas',

                    // Estilização do texto.
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // Espaço entre título e subtítulo.
                  const SizedBox(height: 10),

                  // Subtítulo da tela.
                  const Text(
                    'Organize sua rotina com Firebase 🔥',

                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  // Espaço antes do formulário.
                  const SizedBox(height: 40),

                  // Campo de texto para e-mail.
                  TextField(
                    // Liga o campo ao controller de e-mail.
                    //
                    // Assim conseguimos recuperar o valor digitado.
                    controller: _emailController,

                    // Define a cor do texto digitado.
                    style: const TextStyle(color: Colors.white),

                    // decoration define a aparência do campo.
                    decoration: InputDecoration(
                      // Texto exibido dentro do campo antes do usuário digitar.
                      hintText: 'Digite seu e-mail',

                      // Estilo do hintText.
                      hintStyle: const TextStyle(color: Colors.white54),

                      // Label do campo.
                      //
                      // Ela aparece como identificação do input.
                      labelText: 'E-mail',

                      // Estilo da label.
                      labelStyle: const TextStyle(color: Colors.deepPurple),

                      // Ícone no começo do campo.
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.deepPurple,
                      ),

                      // Ativa preenchimento de fundo.
                      filled: true,

                      // Cor de fundo do campo.
                      fillColor: const Color(0xFF1E1E1E),

                      // Borda do campo.
                      border: OutlineInputBorder(
                        // Arredonda a borda.
                        borderRadius: BorderRadius.circular(16),

                        // Remove a linha da borda.
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  // Espaço entre e-mail e senha.
                  const SizedBox(height: 20),

                  // Campo de texto para senha.
                  TextField(
                    // Liga o campo ao controller de senha.
                    controller: _senhaController,

                    // obscureText esconde os caracteres digitados.
                    //
                    // Exemplo:
                    // senha123 vira ********
                    obscureText: true,

                    // Cor do texto digitado.
                    style: const TextStyle(color: Colors.white),

                    // Aparência do campo.
                    decoration: InputDecoration(
                      // Texto de dica.
                      hintText: 'Digite sua senha',

                      // Estilo da dica.
                      hintStyle: const TextStyle(color: Colors.white54),

                      // Label do campo.
                      labelText: 'Senha',

                      // Cor da label.
                      labelStyle: const TextStyle(color: Colors.deepPurple),

                      // Ícone de cadeado.
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.deepPurple,
                      ),

                      // Ativa fundo preenchido.
                      filled: true,

                      // Cor de fundo do campo.
                      fillColor: const Color(0xFF1E1E1E),

                      // Borda do campo.
                      border: OutlineInputBorder(
                        // Arredonda as bordas.
                        borderRadius: BorderRadius.circular(16),

                        // Remove borda visível.
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  // Espaço antes do botão.
                  const SizedBox(height: 30),

                  // Operador ternário.
                  //
                  // Estrutura:
                  //
                  // condição ? seVerdadeiro : seFalso
                  //
                  // Aqui:
                  //
                  // Se _carregando for true:
                  // mostra CircularProgressIndicator.
                  //
                  // Se _carregando for false:
                  // mostra botão Entrar.
                  _carregando
                      ? const CircularProgressIndicator(
                          // Cor do spinner.
                          color: Colors.deepPurple,
                        )
                      : SizedBox(
                          // Faz o botão ocupar toda a largura disponível.
                          width: double.infinity,

                          // Altura fixa do botão.
                          height: 55,

                          // Botão principal de login.
                          child: ElevatedButton(
                            // Função chamada quando o botão é pressionado.
                            onPressed: _fazerLogin,

                            // Estilo visual do botão.
                            style: ElevatedButton.styleFrom(
                              // Cor de fundo.
                              backgroundColor: Colors.deepPurple,

                              // Cor do texto/ícone.
                              foregroundColor: Colors.white,

                              // Formato do botão.
                              shape: RoundedRectangleBorder(
                                // Arredonda as bordas.
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            // Texto do botão.
                            child: const Text(
                              'Entrar',

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                  // Espaço entre o botão e o link de cadastro.
                  const SizedBox(height: 20),

                  // Botão de texto para ir à tela de cadastro.
                  TextButton(
                    // Quando clicado, navega para a rota /cadastro.
                    onPressed: () {
                      // Navigator controla a navegação entre telas.
                      //
                      // pushNamed abre uma nova tela usando o nome da rota.
                      //
                      // Diferente do pushReplacementNamed,
                      // aqui a tela de login continua na pilha.
                      //
                      // Assim, se o usuário apertar voltar,
                      // ele retorna para o login.
                      Navigator.pushNamed(context, '/cadastro');
                    },

                    // Texto exibido no botão.
                    child: const Text(
                      'Não tem conta? Cadastre-se',

                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 16,
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
