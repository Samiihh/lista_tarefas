// ============================================================================
// ARQUIVO: tela_cadastro.dart
// OBJETIVO:
// Este arquivo representa a tela de cadastro de usuários do aplicativo.
//
// Nesta tela o usuário poderá:
// - Digitar um e-mail
// - Digitar uma senha
// - Clicar no botão "Cadastrar"
// - Enviar essas informações para o Firebase Authentication
// - Receber uma mensagem de sucesso ou erro
//
// CONCEITOS TRABALHADOS NESTE ARQUIVO:
// - StatefulWidget
// - TextEditingController
// - setState()
// - async / await
// - try / catch / finally
// - SnackBar
// - Navigator
// - Firebase Authentication através de um serviço separado
// - Organização visual com widgets do Flutter
// ============================================================================


// Importa a biblioteca principal do Flutter para criação de interfaces.
//
// O pacote material.dart fornece os widgets visuais baseados no Material Design,
// que é o padrão visual utilizado em muitos aplicativos Android.
//
// Através dele conseguimos usar componentes como:
// - Scaffold
// - AppBar
// - Text
// - TextField
// - Column
// - Center
// - Container
// - ElevatedButton
// - Icons
// - Colors
// - CircularProgressIndicator
import 'package:flutter/material.dart';


// Importa o arquivo AuthService, que foi criado dentro do projeto.
//
// Esse serviço é responsável por concentrar as regras de autenticação,
// como cadastro e login de usuário.
//
// Em vez de colocar o código do Firebase diretamente dentro da tela,
// criamos um arquivo separado para cuidar dessa responsabilidade.
//
// Isso deixa o projeto mais organizado, mais fácil de entender
// e mais fácil de dar manutenção.
import '../servicos/auth_service.dart';


// ============================================================================
// CLASSE PRINCIPAL DA TELA
// ============================================================================
//
// A classe TelaCadastro representa a tela de cadastro do aplicativo.
//
// Ela herda de StatefulWidget porque esta tela precisa mudar durante a execução.
//
// Exemplos de mudanças nesta tela:
// - O botão pode virar um indicador de carregamento.
// - Mensagens podem aparecer na tela.
// - Os campos recebem textos digitados pelo usuário.
//
// Quando uma tela possui dados que podem mudar, usamos StatefulWidget.
class TelaCadastro extends StatefulWidget {

  // Construtor da tela.
  //
  // O uso de const melhora a performance quando o widget não precisa ser
  // recriado desnecessariamente.
  //
  // O parâmetro super.key é usado pelo Flutter para identificar este widget
  // dentro da árvore de widgets.
  const TelaCadastro({super.key});

  // O método createState() cria o estado da tela.
  //
  // No Flutter, um StatefulWidget é dividido em duas partes:
  //
  // 1. O widget em si: TelaCadastro
  // 2. O estado desse widget: _TelaCadastroState
  //
  // A parte do estado é onde ficam as variáveis, funções e alterações da tela.
  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}


// ============================================================================
// CLASSE DE ESTADO DA TELA
// ============================================================================
//
// Esta classe guarda a lógica e os dados que podem mudar na tela.
//
// O underline no início do nome (_TelaCadastroState) indica que esta classe
// é privada, ou seja, só pode ser usada dentro deste arquivo.
//
// Aqui ficarão:
// - Controllers dos campos
// - Variável de carregamento
// - Função de cadastro
// - Método dispose
// - Método build com a interface visual
class _TelaCadastroState extends State<TelaCadastro> {

  // --------------------------------------------------------------------------
  // CONTROLLER DO CAMPO DE E-MAIL
  // --------------------------------------------------------------------------
  //
  // TextEditingController é usado para controlar o conteúdo digitado
  // dentro de um TextField.
  //
  // Com ele conseguimos:
  // - Ler o texto digitado pelo usuário
  // - Alterar o valor do campo via código
  // - Limpar o campo
  //
  // Exemplo:
  // _emailController.text
  //
  // Esse comando retorna o valor digitado no campo de e-mail.
  final _emailController = TextEditingController();


  // --------------------------------------------------------------------------
  // CONTROLLER DO CAMPO DE SENHA
  // --------------------------------------------------------------------------
  //
  // Este controller funciona da mesma forma que o controller de e-mail,
  // mas será usado para capturar a senha digitada pelo usuário.
  //
  // Quando o usuário clicar no botão "Cadastrar", o conteúdo desse campo
  // será enviado para o serviço de autenticação.
  final _senhaController = TextEditingController();


  // --------------------------------------------------------------------------
  // INSTÂNCIA DO SERVIÇO DE AUTENTICAÇÃO
  // --------------------------------------------------------------------------
  //
  // Aqui criamos um objeto da classe AuthService.
  //
  // Esse objeto será responsável por chamar os métodos de autenticação,
  // como o método cadastrar().
  //
  // Isso evita que a tela precise saber diretamente como o Firebase funciona.
  //
  // A tela apenas pede:
  // "AuthService, cadastre este usuário para mim."
  final _authService = AuthService();


  // --------------------------------------------------------------------------
  // VARIÁVEL DE CONTROLE DE CARREGAMENTO
  // --------------------------------------------------------------------------
  //
  // Esta variável controla se a tela está carregando ou não.
  //
  // Quando _carregando for false:
  // - O botão "Cadastrar" aparece.
  //
  // Quando _carregando for true:
  // - O botão é substituído por um spinner de carregamento.
  //
  // Isso melhora a experiência do usuário, pois mostra que o cadastro
  // está sendo processado.
  bool _carregando = false;


  // ==========================================================================
  // FUNÇÃO RESPONSÁVEL PELO CADASTRO
  // ==========================================================================
  //
  // Esta função será chamada quando o usuário clicar no botão "Cadastrar".
  //
  // Ela é assíncrona porque o cadastro no Firebase não acontece instantaneamente.
  // A aplicação precisa enviar os dados para o servidor e aguardar uma resposta.
  //
  // Future<void> significa:
  // - Esta função vai executar uma tarefa que pode demorar.
  // - Ela não retorna nenhum valor no final.
  //
  // async permite usar await dentro da função.
  Future<void> _cadastrar() async {

    // ------------------------------------------------------------------------
    // VALIDAÇÃO DOS CAMPOS
    // ------------------------------------------------------------------------
    //
    // Antes de enviar os dados para o Firebase, verificamos se o usuário
    // preencheu os campos de e-mail e senha.
    //
    // _emailController.text pega o texto digitado no campo de e-mail.
    // _senhaController.text pega o texto digitado no campo de senha.
    //
    // trim() remove espaços em branco no começo e no final do texto.
    //
    // Exemplo:
    // "   teste@email.com   "
    //
    // Depois do trim(), vira:
    // "teste@email.com"
    //
    // isEmpty verifica se o texto está vazio.
    //
    // O operador || significa "OU".
    //
    // Então a condição abaixo significa:
    // "Se o e-mail estiver vazio OU se a senha estiver vazia..."
    if (_emailController.text.trim().isEmpty ||
        _senhaController.text.trim().isEmpty) {

      // ----------------------------------------------------------------------
      // EXIBINDO MENSAGEM DE ERRO COM SNACKBAR
      // ----------------------------------------------------------------------
      //
      // ScaffoldMessenger é usado para mostrar mensagens temporárias na tela.
      //
      // O SnackBar aparece normalmente na parte inferior do aplicativo.
      //
      // Ele é muito usado para mensagens rápidas, como:
      // - Erros
      // - Confirmações
      // - Alertas simples
      ScaffoldMessenger.of(context).showSnackBar(

        // SnackBar é o componente visual da mensagem.
        const SnackBar(

          // content define o conteúdo exibido dentro do SnackBar.
          //
          // Aqui usamos um Text para mostrar a mensagem ao usuário.
          content: Text('Preencha o e-mail e a senha.'),

          // backgroundColor define a cor de fundo do SnackBar.
          //
          // Usamos vermelho para indicar erro ou atenção.
          backgroundColor: Colors.red,
        ),
      );

      // return interrompe a execução da função.
      //
      // Se os campos estão vazios, não faz sentido continuar
      // e tentar cadastrar no Firebase.
      return;
    }


    // ------------------------------------------------------------------------
    // INICIANDO O CARREGAMENTO
    // ------------------------------------------------------------------------
    //
    // setState() informa ao Flutter que alguma informação da tela mudou.
    //
    // Sempre que setState() é chamado:
    // 1. O valor da variável é alterado.
    // 2. O método build() é executado novamente.
    // 3. A interface é redesenhada com o novo estado.
    //
    // Aqui estamos alterando _carregando para true.
    //
    // Isso fará o botão "Cadastrar" desaparecer e o CircularProgressIndicator
    // aparecer no lugar dele.
    setState(() => _carregando = true);


    // ------------------------------------------------------------------------
    // TRY / CATCH / FINALLY
    // ------------------------------------------------------------------------
    //
    // Usamos try/catch/finally quando existe a possibilidade de erro.
    //
    // Como estamos lidando com Firebase e internet, erros podem acontecer:
    // - Sem conexão
    // - E-mail já cadastrado
    // - Senha fraca
    // - Problema no servidor
    //
    // try: tenta executar o código principal.
    // catch: captura o erro se algo der errado.
    // finally: executa no final, dando certo ou dando erro.
    try {

      // ----------------------------------------------------------------------
      // CHAMANDO O SERVIÇO DE CADASTRO
      // ----------------------------------------------------------------------
      //
      // Aqui chamamos o método cadastrar() do AuthService.
      //
      // Esse método provavelmente usa Firebase Authentication para criar
      // uma nova conta com e-mail e senha.
      //
      // O await faz o código esperar o cadastro terminar antes de continuar.
      //
      // Sem await, o código seguiria imediatamente para as próximas linhas,
      // mesmo sem saber se o cadastro deu certo ou errado.
      await _authService.cadastrar(

        // Envia para o AuthService o e-mail digitado pelo usuário.
        //
        // O trim() é usado novamente para garantir que espaços extras
        // não sejam enviados para o Firebase.
        _emailController.text.trim(),

        // Envia para o AuthService a senha digitada pelo usuário.
        //
        // Também usamos trim() para remover espaços acidentais.
        _senhaController.text.trim(),
      );


      // ----------------------------------------------------------------------
      // VERIFICAÇÃO COM mounted
      // ----------------------------------------------------------------------
      //
      // mounted é uma propriedade que informa se esta tela ainda está ativa
      // na árvore de widgets do Flutter.
      //
      // Isso é importante em operações assíncronas.
      //
      // Imagine o seguinte cenário:
      // 1. O usuário clica em "Cadastrar".
      // 2. O Firebase começa a processar o cadastro.
      // 3. Antes da resposta chegar, o usuário sai da tela.
      // 4. A resposta chega depois.
      //
      // Se tentarmos mostrar SnackBar ou navegar usando context
      // com uma tela que já foi fechada, pode ocorrer erro.
      //
      // Por isso verificamos if (mounted) antes de interagir com a tela.
      if (mounted) {

        // --------------------------------------------------------------------
        // MENSAGEM DE SUCESSO
        // --------------------------------------------------------------------
        //
        // Se o cadastro chegou até aqui, significa que não caiu no catch.
        // Portanto, o usuário foi cadastrado com sucesso.
        //
        // Exibimos um SnackBar verde para indicar sucesso.
        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            // Mensagem exibida ao usuário.
            content: Text('Cadastro realizado com sucesso!'),

            // Verde costuma representar confirmação ou sucesso.
            backgroundColor: Colors.green,
          ),
        );


        // --------------------------------------------------------------------
        // VOLTANDO PARA A TELA ANTERIOR
        // --------------------------------------------------------------------
        //
        // Navigator é o recurso do Flutter usado para navegação entre telas.
        //
        // Navigator.pop(context) fecha a tela atual e volta para a anterior.
        //
        // Neste caso, após cadastrar com sucesso, a tela de cadastro é fechada
        // e o usuário retorna para a tela de login.
        Navigator.pop(context);
      }

    } catch (e) {

      // ----------------------------------------------------------------------
      // TRATAMENTO DE ERROS
      // ----------------------------------------------------------------------
      //
      // O catch captura qualquer erro que acontecer dentro do bloco try.
      //
      // A variável e representa o erro capturado.
      //
      // Exemplos de erros possíveis:
      // - E-mail já cadastrado
      // - Senha muito fraca
      // - Formato de e-mail inválido
      // - Falha na conexão com a internet
      // - Firebase indisponível
      //
      // Tratar erros é importante para que o aplicativo não quebre
      // e para que o usuário receba uma resposta clara.

      // Antes de mostrar a mensagem, verificamos se a tela ainda está ativa.
      if (mounted) {

        // Mostra o erro para o usuário usando SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            // e.toString() converte o erro para texto.
            //
            // Isso permite exibir a mensagem dentro do componente Text.
            content: Text(e.toString()),

            // Vermelho indica que algo deu errado.
            backgroundColor: Colors.red,
          ),
        );
      }

    } finally {

      // ----------------------------------------------------------------------
      // FINALIZANDO O CARREGAMENTO
      // ----------------------------------------------------------------------
      //
      // O finally sempre será executado:
      // - Se o cadastro der certo.
      // - Se o cadastro der erro.
      //
      // Isso é útil para garantir que o loading será encerrado
      // independentemente do resultado.
      //
      // Sem o finally, o aplicativo poderia ficar travado mostrando
      // o indicador de carregamento para sempre.

      // Verifica se a tela ainda está ativa antes de chamar setState().
      if (mounted) {

        // Altera _carregando para false.
        //
        // Com isso, o CircularProgressIndicator some
        // e o botão "Cadastrar" volta a aparecer.
        setState(() => _carregando = false);
      }
    }
  }


  // ==========================================================================
  // MÉTODO dispose()
  // ==========================================================================
  //
  // O dispose() é chamado automaticamente quando a tela é removida da memória.
  //
  // Isso acontece, por exemplo, quando:
  // - O usuário volta para a tela anterior.
  // - A tela é fechada.
  // - O Flutter remove esse widget da árvore.
  //
  // Sempre que usamos TextEditingController, precisamos liberar esses objetos
  // da memória usando dispose().
  //
  // Isso evita consumo desnecessário de memória.
  @override
  void dispose() {

    // Libera da memória o controller do campo de e-mail.
    _emailController.dispose();

    // Libera da memória o controller do campo de senha.
    _senhaController.dispose();

    // Chama o dispose da classe pai.
    //
    // Essa linha deve ficar no final para garantir que o Flutter finalize
    // corretamente o ciclo de vida do widget.
    super.dispose();
  }


  // ==========================================================================
  // MÉTODO build()
  // ==========================================================================
  //
  // O método build() é responsável por construir a interface visual da tela.
  //
  // Ele retorna uma árvore de widgets.
  //
  // Sempre que setState() é chamado, o build() pode ser executado novamente
  // para atualizar a tela com os novos valores.
  @override
  Widget build(BuildContext context) {

    // Scaffold é a estrutura base de uma tela no Flutter.
    //
    // Ele permite usar:
    // - AppBar
    // - Body
    // - FloatingActionButton
    // - Drawer
    // - BottomNavigationBar
    //
    // Neste caso usamos AppBar e body.
    return Scaffold(

      // Define a cor de fundo da tela.
      //
      // Color(0xFF121212) representa um tom escuro, comum em interfaces dark.
      //
      // O prefixo 0xFF indica opacidade total.
      backgroundColor: const Color(0xFF121212),


      // ----------------------------------------------------------------------
      // APPBAR
      // ----------------------------------------------------------------------
      //
      // AppBar é a barra superior do aplicativo.
      //
      // Normalmente é usada para mostrar:
      // - Título da tela
      // - Botão de voltar
      // - Ações no topo
      appBar: AppBar(

        // Título exibido no centro da barra superior.
        title: const Text('Criar Conta'),

        // Centraliza o título da AppBar.
        centerTitle: true,

        // Deixa o fundo da AppBar transparente.
        //
        // Como a tela já possui um fundo escuro, isso ajuda a criar
        // um visual mais moderno.
        backgroundColor: Colors.transparent,

        // Remove a sombra padrão da AppBar.
        //
        // elevation 0 deixa a barra mais limpa e sem relevo.
        elevation: 0,
      ),


      // ----------------------------------------------------------------------
      // BODY
      // ----------------------------------------------------------------------
      //
      // body é o conteúdo principal da tela.
      body: SafeArea(

        // SafeArea evita que o conteúdo fique atrás de áreas do sistema,
        // como notch, barra de status ou barra de navegação.
        child: Center(

          // Center centraliza seu filho na tela.
          child: SingleChildScrollView(

            // SingleChildScrollView permite que a tela tenha rolagem.
            //
            // Isso é muito importante em telas com formulário,
            // principalmente quando o teclado aparece e ocupa parte da tela.
            child: Padding(

              // Padding adiciona espaçamento interno ao redor do conteúdo.
              //
              // EdgeInsets.all(24.0) aplica 24 pixels de espaço em todos os lados.
              padding: const EdgeInsets.all(24.0),

              // Column organiza os widgets em uma coluna vertical.
              //
              // Os widgets filhos serão exibidos um abaixo do outro.
              child: Column(

                // mainAxisAlignment controla o alinhamento no eixo principal.
                //
                // Em uma Column, o eixo principal é vertical.
                //
                // MainAxisAlignment.center tenta centralizar os elementos
                // verticalmente.
                mainAxisAlignment: MainAxisAlignment.center,

                // children recebe a lista de widgets que serão exibidos na coluna.
                children: [

                  // ----------------------------------------------------------------
                  // ÍCONE PRINCIPAL DA TELA
                  // ----------------------------------------------------------------
                  //
                  // Container é um widget usado para criar caixas visuais.
                  //
                  // Ele pode receber:
                  // - largura
                  // - altura
                  // - cor
                  // - borda
                  // - sombra
                  // - margem
                  // - padding
                  //
                  // Aqui usamos o Container para criar um bloco roxo com ícone.
                  Container(

                    // Largura do container.
                    width: 100,

                    // Altura do container.
                    height: 100,

                    // decoration permite personalizar o visual do Container.
                    //
                    // Quando usamos decoration, propriedades como cor,
                    // borda e sombra ficam dentro do BoxDecoration.
                    decoration: BoxDecoration(

                      // Define a cor de fundo do container.
                      color: Colors.deepPurple,

                      // borderRadius arredonda os cantos do container.
                      //
                      // Quanto maior o valor, mais arredondado fica.
                      borderRadius: BorderRadius.circular(30),

                      // boxShadow adiciona sombra ao container.
                      //
                      // Recebe uma lista porque um mesmo elemento pode ter
                      // mais de uma sombra.
                      boxShadow: [

                        BoxShadow(

                          // Define a cor da sombra.
                          //
                          // withOpacity(0.4) deixa a cor com 40% de opacidade,
                          // criando uma sombra mais suave.
                          color: Colors.deepPurple.withOpacity(0.4),

                          // blurRadius define o quanto a sombra fica espalhada.
                          //
                          // Quanto maior o valor, mais desfocada fica a sombra.
                          blurRadius: 20,

                          // offset define o deslocamento da sombra.
                          //
                          // Offset(0, 10) significa:
                          // - 0 no eixo X: sem deslocamento horizontal
                          // - 10 no eixo Y: sombra deslocada para baixo
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    // child é o conteúdo interno do Container.
                    //
                    // Aqui colocamos um ícone dentro da caixa roxa.
                    child: const Icon(

                      // Ícone de adicionar pessoa.
                      Icons.person_add_alt_1,

                      // Cor do ícone.
                      color: Colors.white,

                      // Tamanho do ícone.
                      size: 50,
                    ),
                  ),


                  // SizedBox cria um espaço vazio entre widgets.
                  //
                  // Aqui ele adiciona 30 pixels de distância
                  // entre o ícone e o título.
                  const SizedBox(height: 30),


                  // ----------------------------------------------------------------
                  // TÍTULO PRINCIPAL
                  // ----------------------------------------------------------------
                  //
                  // Text exibe um texto na tela.
                  const Text(

                    // Texto exibido.
                    'Criar Conta',

                    // style define a aparência do texto.
                    style: TextStyle(

                      // Tamanho da fonte.
                      fontSize: 32,

                      // Peso da fonte.
                      //
                      // FontWeight.bold deixa o texto em negrito.
                      fontWeight: FontWeight.bold,

                      // Cor do texto.
                      color: Colors.white,
                    ),
                  ),


                  // Espaço entre o título e o subtítulo.
                  const SizedBox(height: 10),


                  // ----------------------------------------------------------------
                  // SUBTÍTULO
                  // ----------------------------------------------------------------
                  //
                  // Texto auxiliar para explicar a finalidade da tela.
                  const Text(

                    'Cadastre-se para salvar suas tarefas 🔥',

                    // Centraliza o texto caso ele quebre em mais de uma linha.
                    textAlign: TextAlign.center,

                    style: TextStyle(

                      // Tamanho do texto.
                      fontSize: 16,

                      // Cor branca com transparência.
                      //
                      // white70 deixa o texto menos forte que o título.
                      color: Colors.white70,
                    ),
                  ),


                  // Espaço entre o subtítulo e o primeiro campo.
                  const SizedBox(height: 40),


                  // ----------------------------------------------------------------
                  // CAMPO DE E-MAIL
                  // ----------------------------------------------------------------
                  //
                  // TextField é o campo usado para entrada de texto.
                  //
                  // Neste caso será usado para digitar o e-mail.
                  TextField(

                    // Associa este campo ao controller de e-mail.
                    //
                    // Assim conseguimos acessar o texto digitado através de:
                    // _emailController.text
                    controller: _emailController,

                    // Define o estilo do texto digitado pelo usuário.
                    //
                    // Aqui o texto digitado será branco.
                    style: const TextStyle(color: Colors.white),

                    // decoration configura a aparência visual do campo.
                    decoration: InputDecoration(

                      // hintText é o texto de dica exibido quando o campo está vazio.
                      hintText: 'Digite seu e-mail',

                      // Estilo visual do texto de dica.
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                      ),

                      // labelText é o rótulo do campo.
                      //
                      // Ele identifica qual informação deve ser digitada.
                      labelText: 'E-mail',

                      // Estilo visual da label.
                      labelStyle: const TextStyle(
                        color: Colors.deepPurple,
                      ),

                      // prefixIcon adiciona um ícone no início do campo.
                      //
                      // Ajuda o usuário a identificar visualmente o tipo de dado.
                      prefixIcon: const Icon(

                        // Ícone de e-mail.
                        Icons.email,

                        // Cor do ícone.
                        color: Colors.deepPurple,
                      ),

                      // filled ativa o preenchimento de fundo do campo.
                      filled: true,

                      // fillColor define a cor de fundo do campo.
                      fillColor: const Color(0xFF1E1E1E),

                      // border define o formato da borda do campo.
                      border: OutlineInputBorder(

                        // Arredonda os cantos da borda.
                        borderRadius: BorderRadius.circular(16),

                        // Remove a linha da borda.
                        //
                        // Como o campo já tem fundo escuro, a borda não é necessária.
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),


                  // Espaço entre o campo de e-mail e o campo de senha.
                  const SizedBox(height: 20),


                  // ----------------------------------------------------------------
                  // CAMPO DE SENHA
                  // ----------------------------------------------------------------
                  //
                  // Segundo TextField da tela, agora para a senha.
                  TextField(

                    // Associa este campo ao controller de senha.
                    //
                    // Assim conseguimos acessar o texto digitado através de:
                    // _senhaController.text
                    controller: _senhaController,

                    // obscureText true esconde os caracteres digitados.
                    //
                    // Isso é usado em campos de senha para proteger a informação.
                    obscureText: true,

                    // Cor do texto digitado.
                    style: const TextStyle(color: Colors.white),

                    // Aparência visual do campo de senha.
                    decoration: InputDecoration(

                      // Texto exibido quando o campo está vazio.
                      hintText: 'Digite sua senha',

                      // Estilo do texto de dica.
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                      ),

                      // Label do campo.
                      labelText: 'Senha',

                      // Estilo da label.
                      labelStyle: const TextStyle(
                        color: Colors.deepPurple,
                      ),

                      // Ícone exibido no início do campo.
                      prefixIcon: const Icon(

                        // Ícone de cadeado.
                        Icons.lock,

                        // Cor do ícone.
                        color: Colors.deepPurple,
                      ),

                      // Ativa o preenchimento do campo.
                      filled: true,

                      // Define a cor de fundo do campo.
                      fillColor: const Color(0xFF1E1E1E),

                      // Define a borda do campo.
                      border: OutlineInputBorder(

                        // Arredonda os cantos.
                        borderRadius: BorderRadius.circular(16),

                        // Remove a linha da borda.
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),


                  // Espaço entre o campo de senha e o botão.
                  const SizedBox(height: 30),


                  // ----------------------------------------------------------------
                  // OPERADOR TERNÁRIO PARA TROCAR BOTÃO POR LOADING
                  // ----------------------------------------------------------------
                  //
                  // Aqui usamos um operador ternário.
                  //
                  // O operador ternário é uma forma resumida de escrever um if/else.
                  //
                  // Estrutura:
                  //
                  // condição ? valor_se_verdadeiro : valor_se_falso
                  //
                  // Neste caso:
                  //
                  // Se _carregando for true:
                  // - Mostra CircularProgressIndicator
                  //
                  // Senão:
                  // - Mostra o botão "Cadastrar"
                  _carregando

                      // ------------------------------------------------------------
                      // INDICADOR DE CARREGAMENTO
                      // ------------------------------------------------------------
                      //
                      // CircularProgressIndicator mostra um círculo girando.
                      //
                      // Ele indica ao usuário que alguma ação está sendo processada.
                      ? const CircularProgressIndicator(

                          // Define a cor do loading.
                          color: Colors.deepPurple,
                        )

                      // ------------------------------------------------------------
                      // BOTÃO DE CADASTRO
                      // ------------------------------------------------------------
                      //
                      // Se não estiver carregando, exibe o botão.
                      : SizedBox(

                          // Faz o botão ocupar toda a largura disponível.
                          width: double.infinity,

                          // Define a altura do botão.
                          height: 55,

                          // ElevatedButton é um botão com destaque visual.
                          child: ElevatedButton(

                            // onPressed define qual função será executada
                            // quando o botão for clicado.
                            //
                            // Aqui chamamos a função _cadastrar,
                            // responsável por validar os campos e enviar os dados
                            // para o Firebase.
                            onPressed: _cadastrar,

                            // style define a aparência do botão.
                            style: ElevatedButton.styleFrom(

                              // Cor de fundo do botão.
                              backgroundColor: Colors.deepPurple,

                              // Cor do texto e dos ícones dentro do botão.
                              foregroundColor: Colors.white,

                              // Define o formato do botão.
                              shape: RoundedRectangleBorder(

                                // Arredonda os cantos do botão.
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            // Texto exibido dentro do botão.
                            child: const Text(

                              'Cadastrar',

                              // Estilo do texto do botão.
                              style: TextStyle(

                                // Tamanho da fonte.
                                fontSize: 18,

                                // Negrito.
                                fontWeight: FontWeight.bold,
                              ),
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
