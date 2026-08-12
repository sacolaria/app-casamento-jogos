import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MeuAppEvento());
}

class MeuAppEvento extends StatelessWidget {
  const MeuAppEvento({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Eventos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}

// -----------------------------------------------------------------------------
// TELA PRINCIPAL (MENU DO CONVIDADO)
// -----------------------------------------------------------------------------
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  String? _caminhoHeader;
  List<String> _fotosJogos = [];
  String _fraseVitoria = "Parabéns por concluir!";
  String? _caminhoAudio;

  @override
  void initState() {
    super.initState();
    _carregarDadosSalvos();
  }

  Future<void> _carregarDadosSalvos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _caminhoHeader = prefs.getString('caminho_header');
      _fotosJogos = prefs.getStringList('fotos_jogos') ?? [];
      _fraseVitoria = prefs.getString('frase_vitoria') ?? "Parabéns por concluir!";
      _caminhoAudio = prefs.getString('caminho_audio');
    });
  }

  void _abrirAutenticacaoAdmin() {
    final controllerSenha = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acesso Administrativo'),
        content: TextField(
          controller: controllerSenha,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Senha de Acesso',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controllerSenha.text == '1234') { // Senha padrão: 1234
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PainelAdmin()),
                ).then((_) => _carregarDadosSalvos());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha incorreta!')),
                );
              }
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  void _iniciarJogoMemoria() {
    if (_fotosJogos.length < 4) {
      _alertaFotosInsuficientes();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JogoMemoriaPage(
          fotosDisponiveis: _fotosJogos,
          fraseVitoria: _fraseVitoria,
          caminhoAudio: _caminhoAudio,
        ),
      ),
    );
  }

  void _iniciarQuebraCabeca() {
    if (_fotosJogos.isEmpty) {
      _alertaFotosInsuficientes();
      return;
    }
    // Sorteia uma foto aleatória
    final random = Random();
    final fotoSorteada = _fotosJogos[random.nextInt(_fotosJogos.length)];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuebraCabecaPage(
          caminhoFoto: fotoSorteada,
          fraseVitoria: _fraseVitoria,
          caminhoAudio: _caminhoAudio,
        ),
      ),
    );
  }

  void _alertaFotosInsuficientes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fotos Insuficientes'),
        content: const Text('É necessário cadastrar pelo menos 4 fotos no Painel Administrativo para jogar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _caminhoHeader != null && File(_caminhoHeader!).existsSync()
                        ? Image.file(
                            File(_caminhoHeader!),
                            height: 70,
                            fit: BoxFit.contain,
                          )
                        : const Text(
                            'BEM-VINDO AO NOSSO EVENTO',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.grey, size: 28),
                    onPressed: _abrirAutenticacaoAdmin,
                    tooltip: 'Painel Admin',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // SELEÇÃO DE JOGOS
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Escolha um jogo para se divertir!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _botaoJogo(
                            titulo: 'Jogo da Memória',
                            icone: Icons.grid_view_rounded,
                            cor: Colors.pinkAccent,
                            onTap: _iniciarJogoMemoria,
                          ),
                          const SizedBox(width: 30),
                          _botaoJogo(
                            titulo: 'Quebra-Cabeça',
                            icone: Icons.extension_rounded,
                            cor: Colors.deepPurpleAccent,
                            onTap: _iniciarQuebraCabeca,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoJogo({
    required String titulo,
    required IconData icone,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: cor.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 70, color: cor),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// JOGO 1: QUEBRA-CABEÇA (3x3)
// -----------------------------------------------------------------------------
class QuebraCabecaPage extends StatefulWidget {
  final String caminhoFoto;
  final String fraseVitoria;
  final String? caminhoAudio;

  const QuebraCabecaPage({
    super.key,
    required this.caminhoFoto,
    required this.fraseVitoria,
    this.caminhoAudio,
  });

  @override
  State<QuebraCabecaPage> createState() => _QuebraCabecaPageState();
}

class _QuebraCabecaPageState extends State<QuebraCabecaPage> {
  final int gridDimension = 3; // Grid 3x3 (9 peças)
  late List<int> _ordemAtual;
  int? _pecaSelecionada;

  @override
  void initState() {
    super.initState();
    _embaralharPecas();
  }

  void _embaralharPecas() {
    _ordemAtual = List.generate(gridDimension * gridDimension, (i) => i);
    _ordemAtual.shuffle();
  }

  void _selecionarPeca(int index) {
    setState(() {
      if (_pecaSelecionada == null) {
        _pecaSelecionada = index;
      } else {
        // Troca as duas peças de posição
        final temp = _ordemAtual[_pecaSelecionada!];
        _ordemAtual[_pecaSelecionada!] = _ordemAtual[index];
        _ordemAtual[index] = temp;
        _pecaSelecionada = null;

        _verificarVitoria();
      }
    });
  }

  void _verificarVitoria() {
    bool venceu = true;
    for (int i = 0; i < _ordemAtual.length; i++) {
      if (_ordemAtual[i] != i) {
        venceu = false;
        break;
      }
    }

    if (venceu) {
      exibirDialogoVitoria(context, widget.fraseVitoria, widget.caminhoAudio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quebra-Cabeça'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Toque em duas peças para trocar suas posições!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 330,
              height: 330,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridDimension,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: gridDimension * gridDimension,
                itemBuilder: (context, index) {
                  final posicaoOriginal = _ordemAtual[index];
                  final isSelected = _pecaSelecionada == index;

                  final rowOriginal = posicaoOriginal ~/ gridDimension;
                  final colOriginal = posicaoOriginal % gridDimension;

                  return GestureDetector(
                    onTap: () => _selecionarPeca(index),
                    child: Container(
                      decoration: BoxDecoration(
                        border: isSelected
                            ? Border.all(color: Colors.amber, width: 4)
                            : Border.all(color: Colors.white, width: 1),
                      ),
                      child: ClipRect(
                        child: CustomPaint(
                          painter: ImageTilePainter(
                            caminhoFoto: widget.caminhoFoto,
                            row: rowOriginal,
                            col: colOriginal,
                            gridDimension: gridDimension,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter para fatiar dinamicamente a foto em um grid 3x3
class ImageTilePainter extends CustomPainter {
  final String caminhoFoto;
  final int row;
  final int col;
  final int gridDimension;

  ImageTilePainter({
    required this.caminhoFoto,
    required this.row,
    required this.col,
    required this.gridDimension,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final image = FileImage(File(caminhoFoto));
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final imgWidth = info.image.width.toDouble();
        final imgHeight = info.image.height.toDouble();

        final tileWidth = imgWidth / gridDimension;
        final tileHeight = imgHeight / gridDimension;

        final srcRect = Rect.fromLTWH(
          col * tileWidth,
          row * tileHeight,
          tileWidth,
          tileHeight,
        );

        final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

        canvas.drawImageRect(info.image, srcRect, dstRect, Paint());
      }),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// JOGO 2: JOGO DA MEMÓRIA
// -----------------------------------------------------------------------------
class CartaMemoria {
  final int id;
  final String caminhoFoto;
  bool estaVirada;
  bool estaEncontrada;

  CartaMemoria({
    required this.id,
    required this.caminhoFoto,
    this.estaVirada = false,
    this.estaEncontrada = false,
  });
}

class JogoMemoriaPage extends StatefulWidget {
  final List<String> fotosDisponiveis;
  final String fraseVitoria;
  final String? caminhoAudio;

  const JogoMemoriaPage({
    super.key,
    required this.fotosDisponiveis,
    required this.fraseVitoria,
    this.caminhoAudio,
  });

  @override
  State<JogoMemoriaPage> createState() => _JogoMemoriaPageState();
}

class _JogoMemoriaPageState extends State<JogoMemoriaPage> {
  late List<CartaMemoria> _cartas;
  int? _primeiraCartaIndex;
  bool _bloquearToque = false;

  @override
  void initState() {
    super.initState();
    _prepararTabuleiro();
  }

  void _prepararTabuleiro() {
    // Seleciona 4 fotos aleatórias das cadastradas
    final random = Random();
    List<String> fotosEmbaralhadas = List.from(widget.fotosDisponiveis)..shuffle(random);
    List<String> fotosSorteadas = fotosEmbaralhadas.take(4).toList();

    // Cria as duplas (8 cartas no total)
    _cartas = [];
    for (int i = 0; i < fotosSorteadas.length; i++) {
      _cartas.add(CartaMemoria(id: i, caminhoFoto: fotosSorteadas[i]));
      _cartas.add(CartaMemoria(id: i, caminhoFoto: fotosSorteadas[i]));
    }
    _cartas.shuffle(random);
  }

  void _virarCarta(int index) {
    if (_bloquearToque || _cartas[index].estaVirada || _cartas[index].estaEncontrada) {
      return;
    }

    setState(() {
      _cartas[index].estaVirada = true;
    });

    if (_primeiraCartaIndex == null) {
      _primeiraCartaIndex = index;
    } else {
      _bloquearToque = true;
      final primeira = _cartas[_primeiraCartaIndex!];
      final segunda = _cartas[index];

      if (primeira.id == segunda.id) {
        // Encontrou um par!
        setState(() {
          primeira.estaEncontrada = true;
          segunda.estaEncontrada = true;
          _primeiraCartaIndex = null;
          _bloquearToque = false;
        });

        _verificarVitoria();
      } else {
        // Não é um par, desvira após 1 segundo
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            primeira.estaVirada = false;
            segunda.estaVirada = false;
            _primeiraCartaIndex = null;
            _bloquearToque = false;
          });
        });
      }
    }
  }

  void _verificarVitoria() {
    if (_cartas.every((carta) => carta.estaEncontrada)) {
      exibirDialogoVitoria(context, widget.fraseVitoria, widget.caminhoAudio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo da Memória'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _cartas.length,
            itemBuilder: (context, index) {
              final carta = _cartas[index];
              return GestureDetector(
                onTap: () => _virarCarta(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: carta.estaVirada || carta.estaEncontrada
                        ? Colors.white
                        : Colors.pink.shade300,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: carta.estaVirada || carta.estaEncontrada
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(carta.caminhoFoto),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DIÁLOGO DE VITÓRIA E ÁUDIO
// -----------------------------------------------------------------------------
void exibirDialogoVitoria(BuildContext context, String frase, String? caminhoAudio) async {
  final AudioPlayer audioPlayer = AudioPlayer();

  if (caminhoAudio != null && File(caminhoAudio).existsSync()) {
    await audioPlayer.play(DeviceFileSource(caminhoAudio));
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Column(
        children: [
          Icon(Icons.emoji_events, size: 60, color: Colors.amber),
          SizedBox(height: 10),
          Text(
            'Parabéns!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        frase,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            audioPlayer.stop();
            audioPlayer.dispose();
            Navigator.pop(context); // Fecha o diálogo
            Navigator.pop(context); // Volta para a tela principal
          },
          child: const Text('Voltar ao Menu', style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}

// -----------------------------------------------------------------------------
// PAINEL ADMINISTRATIVO
// -----------------------------------------------------------------------------
class PainelAdmin extends StatefulWidget {
  const PainelAdmin({super.key});

  @override
  State<PainelAdmin> createState() => _PainelAdminState();
}

class _PainelAdminState extends State<PainelAdmin> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controllerFrase = TextEditingController();

  String? _caminhoHeader;
  List<String> _fotosJogos = [];
  String? _caminhoAudio;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _caminhoHeader = prefs.getString('caminho_header');
      _fotosJogos = prefs.getStringList('fotos_jogos') ?? [];
      _controllerFrase.text = prefs.getString('frase_vitoria') ?? "Obrigado por celebrar conosco!";
      _caminhoAudio = prefs.getString('caminho_audio');
    });
  }

  Future<void> _selecionarHeader() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('caminho_header', image.path);
      setState(() {
        _caminhoHeader = image.path;
      });
    }
  }

  Future<void> _adicionarFotoJogo() async {
    if (_fotosJogos.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de 10 fotos atingido.')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _fotosJogos.add(image.path);
      });
      await prefs.setStringList('fotos_jogos', _fotosJogos);
    }
  }

  Future<void> _removerFotoJogo(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fotosJogos.removeAt(index);
    });
    await prefs.setStringList('fotos_jogos', _fotosJogos);
  }

  Future<void> _selecionarAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('caminho_audio', path);
      setState(() {
        _caminhoAudio = path;
      });
    }
  }

  Future<void> _salvarFrase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('frase_vitoria', _controllerFrase.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Frase salva com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _tituloSecao('1. Imagem do Cabeçalho (PNG)'),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _selecionarHeader,
                icon: const Icon(Icons.upload_file),
                label: const Text('Carregar Logo'),
              ),
              const SizedBox(width: 16),
              if (_caminhoHeader != null && File(_caminhoHeader!).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_caminhoHeader!), height: 50, fit: BoxFit.cover),
                )
              else
                const Text('Nenhuma imagem carregada', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const Divider(height: 40),

          _tituloSecao('2. Fotos para os Jogos (${_fotosJogos.length}/10)'),
          const Text('Cadastre entre 4 e 10 fotos que serão sorteadas nas partidas.'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _adicionarFotoJogo,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Adicionar Foto'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade50),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _fotosJogos.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_fotosJogos[index]), fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removerFotoJogo(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 40),

          _tituloSecao('3. Frase de Conclusão / Vitória'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controllerFrase,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Obrigado por compartilhar esse momento conosco!',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _salvarFrase,
                child: const Text('Salvar'),
              ),
            ],
          ),
          const Divider(height: 40),

          _tituloSecao('4. Música Comemorativa (MP3 / WAV)'),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _selecionarAudio,
                icon: const Icon(Icons.music_note),
                label: const Text('Carregar Áudio'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _caminhoAudio != null
                      ? _caminhoAudio!.split('/').last
                      : 'Nenhum áudio selecionado',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tituloSecao(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black80),
    );
  }
}