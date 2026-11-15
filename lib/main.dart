
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const verde = Color(0xFF245A48);

void main() => runApp(const SaboreApp());

class SaboreApp extends StatelessWidget {
  const SaboreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saborê',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: verde),
        scaffoldBackgroundColor: const Color(0xFFF8F5EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F5EF),
        ),
      ),
      home: const InicioPage(),
    );
  }
}

class Receita {
  final int id;
  final String nome, imagem, dificuldade, cozinha;
  final List<String> ingredientes, instrucoes, tipos;
  final int? preparo, cozimento, porcoes;
  final num? avaliacao;

  Receita.fromJson(Map<String, dynamic> json)
      : id = _id(json['id']),
        nome = _nome(json['name']),
        imagem = _texto(json['image']),
        dificuldade = _texto(json['difficulty']),
        cozinha = _texto(json['cuisine']),
        ingredientes = _lista(json['ingredients']),
        instrucoes = _lista(json['instructions']),
        tipos = _lista(json['mealType']),
        preparo = _inteiro(json['prepTimeMinutes']),
        cozimento = _inteiro(json['cookTimeMinutes']),
        porcoes = _inteiro(json['servings']),
        avaliacao = json['rating'] is num ? json['rating'] : null;

  static int _id(dynamic v) {
    if (v is! num) throw const FormatException('ID inválido');
    return v.toInt();
  }

  static String _nome(dynamic v) {
    if (v is! String || v.trim().isEmpty) {
      throw const FormatException('Nome inválido');
    }
    return v.trim();
  }

  static String _texto(dynamic v) => v is String ? v : '';

  static List<String> _lista(dynamic v) =>
      v is List ? v.whereType<String>().toList() : [];

  static int? _inteiro(dynamic v) => v is num ? v.toInt() : null;

  int? get tempo => preparo != null && cozimento != null
      ? preparo! + cozimento!
      : null;
}

class ReceitasApi {
  static Future<List<Receita>> buscar([String? nome]) async {
    final url = Uri.https(
      'dummyjson.com',
      nome == null ? '/recipes' : '/recipes/search',
      nome == null ? {'limit': '30'} : {'q': nome},
    );

    final resposta = await http.get(url)
        .timeout(const Duration(seconds: 15));

    if (resposta.statusCode != 200) {
      throw Exception('Erro HTTP ${resposta.statusCode}');
    }

    final dados = jsonDecode(utf8.decode(resposta.bodyBytes));

    if (dados is! Map || dados['recipes'] is! List) {
      throw const FormatException('Resposta inválida');
    }

    return (dados['recipes'] as List).map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Receita inválida');
      }
      return Receita.fromJson(item);
    }).toList();
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final campo = TextEditingController();
  final Map<int, Receita> favoritos = {};

  List<Receita> receitas = [];
  String? pesquisa, erro;
  bool carregando = false;
  int aba = 0;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  void dispose() {
    campo.dispose();
    super.dispose();
  }

  Future<void> carregar([String? nome]) async {
    if (carregando) return;

    setState(() {
      carregando = true;
      erro = null;
      pesquisa = nome;
    });

    try {
      final resultado = await ReceitasApi.buscar(nome);
      if (!mounted) return;
      setState(() => receitas = resultado);
    } catch (_) {
      if (!mounted) return;
      setState(() => erro = 'Não foi possível carregar as receitas.');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  void buscar() {
    final nome = campo.text.trim();
    if (carregando) return;

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome da receita.')),
      );
      return;
    }
    carregar(nome);
  }

  void favoritar(Receita receita) {
    setState(() {
      if (favoritos.containsKey(receita.id)) {
        favoritos.remove(receita.id);
      } else {
        favoritos[receita.id] = receita;
      }
    });
  }

  Future<void> abrir(Receita receita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhePage(
          receita: receita,
          favorito: () => favoritos.containsKey(receita.id),
          alterar: () => favoritar(receita),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saborê')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: aba,
        onDestinationSelected: (i) => setState(() => aba = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
        ],
      ),
      body: aba == 0 ? explorar() : telaFavoritos(),
    );
  }

  Widget explorar() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Receitas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text('Pesquise uma receita pelo nome.'),
        const SizedBox(height: 16),
        TextField(
          controller: campo,
          enabled: !carregando,
          onSubmitted: (_) => buscar(),
          decoration: const InputDecoration(
            labelText: 'Nome da receita',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: carregando ? null : buscar,
          child: const Text('Pesquisar'),
        ),
        const SizedBox(height: 16),
        Text(
          pesquisa == null
              ? 'Receitas disponíveis'
              : 'Resultados para "$pesquisa"',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (pesquisa != null)
          TextButton(
            onPressed: carregando ? null : () {
              campo.clear();
              carregar();
            },
            child: const Text('Limpar pesquisa'),
          ),
        const SizedBox(height: 12),
        if (carregando)
          const Center(child: CircularProgressIndicator())
        else if (erro != null)
          aviso('Erro de conexão ou resposta', erro!, 'Tentar novamente',
                  () => carregar(pesquisa))
        else if (receitas.isEmpty)
            aviso('Nenhum resultado', 'Receita não encontrada.',
                'Ver todas', () {
                  campo.clear();
                  carregar();
                })
          else
            ...receitas.map(cartao),
      ],
    );
  }

  Widget telaFavoritos() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Favoritos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (favoritos.isEmpty)
          aviso('Nenhum favorito', 'Salve uma receita para vê-la aqui.',
              'Explorar receitas', () => setState(() => aba = 0))
        else
          ...favoritos.values.map(cartao),
      ],
    );
  }

  Widget cartao(Receita receita) {
    final salvo = favoritos.containsKey(receita.id);

    return Card(
      child: ListTile(
        leading: foto(receita, 60, 60),
        title: Text(receita.nome),
        subtitle: Text(
          '${receita.tempo == null ? "Tempo não informado" : "${receita.tempo} min"}'
              ' • ${receita.dificuldade.isEmpty ? "Dificuldade não informada" : receita.dificuldade}'
              '\n${receita.avaliacao == null ? "Sem avaliação" : "${receita.avaliacao} / 5"}',
        ),
        isThreeLine: true,
        onTap: () => abrir(receita),
        trailing: IconButton(
          onPressed: () => favoritar(receita),
          icon: Icon(
            salvo ? Icons.favorite : Icons.favorite_border,
            color: verde,
          ),
        ),
      ),
    );
  }

  Widget aviso(String titulo, String texto, String botao, VoidCallback acao) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Text(titulo, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text(texto, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton(onPressed: acao, child: Text(botao)),
      ],
    );
  }
}

Widget foto(Receita receita, double largura, double altura) {
  final alternativa = Container(
    color: Colors.grey.shade200,
    child: const Icon(Icons.restaurant, color: verde),
  );

  return SizedBox(
    width: largura,
    height: altura,
    child: receita.imagem.isEmpty
        ? alternativa
        : Image.network(
      receita.imagem,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => alternativa,
    ),
  );
}

class DetalhePage extends StatefulWidget {
  final Receita receita;
  final bool Function() favorito;
  final VoidCallback alterar;

  const DetalhePage({
    super.key,
    required this.receita,
    required this.favorito,
    required this.alterar,
  });

  @override
  State<DetalhePage> createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  @override
  Widget build(BuildContext context) {
    final r = widget.receita;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receita'),
        actions: [
          IconButton(
            onPressed: () {
              widget.alterar();
              setState(() {});
            },
            icon: Icon(
              widget.favorito()
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: verde,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          foto(r, double.infinity, 200),
          const SizedBox(height: 15),
          Text(
            r.nome,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${r.cozinha} • ${r.dificuldade} '
                '• ${r.avaliacao == null ? "Sem avaliação" : "${r.avaliacao} / 5"}',
          ),
          const SizedBox(height: 12),
          Text('Tempo total: ${r.tempo == null ? "Não informado" : "${r.tempo} min"}'),
          Text('Porções: ${r.porcoes?.toString() ?? "Não informado"}'),
          if (r.tipos.isNotEmpty)
            Text('Tipo: ${r.tipos.join(", ")}'),
          const SizedBox(height: 20),
          const Text(
            'Ingredientes',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (r.ingredientes.isEmpty)
            const Text('Não informados')
          else
            ...r.ingredientes.map((i) => Text('• $i')),
          const SizedBox(height: 20),
          const Text(
            'Modo de preparo',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (r.instrucoes.isEmpty)
            const Text('Não informado')
          else
            ...r.instrucoes.asMap().entries.map(
                  (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${e.key + 1}. ${e.value}'),
              ),
            ),
        ],
      ),
    );
  }
}
