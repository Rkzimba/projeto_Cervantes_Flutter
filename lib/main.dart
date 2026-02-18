import 'package:flutter/material.dart';
import 'database/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cadastro SQLite",

      debugShowCheckedModeBanner: false,

      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textoController = TextEditingController();

  TextEditingController numeroController = TextEditingController();

  List<Map<String, dynamic>> lista = [];

  @override
  void initState() {
    super.initState();

    carregar();
  }

  Future carregar() async {
    final dados = await DatabaseHelper.listar();

    print("DADOS CARREGADOS:");
    print(dados);

    setState(() {
      lista = dados;
    });
  }

  Future inserir() async {
    try {
      final texto = textoController.text.trim();

      final numero = int.parse(numeroController.text.trim());

      await DatabaseHelper.inserir(texto, numero);

      textoController.clear();
      numeroController.clear();

      await carregar();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Inserido com sucesso")));
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  Future deletar(int id) async {
    await DatabaseHelper.deletar(id);

    await carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sistema de Cadastro")),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: SizedBox.expand(
          child: Column(
            children: [
              TextField(
                controller: textoController,

                decoration: InputDecoration(labelText: "Campo Texto"),
              ),

              TextField(
                controller: numeroController,

                keyboardType: TextInputType.number,

                decoration: InputDecoration(labelText: "Campo Número"),
              ),

              SizedBox(height: 10),

              ElevatedButton(onPressed: inserir, child: Text("Inserir")),

              SizedBox(height: 20),

              Expanded(
                child: lista.isEmpty
                    ? Center(child: Text("Nenhum cadastro ainda"))
                    : ListView.builder(
                        itemCount: lista.length,

                        itemBuilder: (context, index) {
                          var item = lista[index];

                          return Card(
                            child: ListTile(
                              title: Text(item["texto"].toString()),

                              subtitle: Text(
                                "Número: " + item["numero"].toString(),
                              ),

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),

                                    onPressed: () {
                                      mostrarDialogEditar(item);
                                    },
                                  ),

                                  IconButton(
                                    icon: Icon(Icons.delete),

                                    onPressed: () => deletar(item["id"]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void mostrarDialogEditar(Map<String, dynamic> item) {
    final textoEdit = TextEditingController(text: item["texto"]);

    final numeroEdit = TextEditingController(text: item["numero"].toString());

    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: Text("Editar"),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: textoEdit,
                decoration: InputDecoration(labelText: "Texto"),
              ),

              TextField(
                controller: numeroEdit,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Número"),
              ),
            ],
          ),

          actions: [
            TextButton(
              child: Text("Cancelar"),

              onPressed: () {
                Navigator.pop(context);
              },
            ),

            TextButton(
              child: Text("Salvar"),

              onPressed: () async {
                await DatabaseHelper.atualizar(
                  item["id"],

                  textoEdit.text,

                  int.parse(numeroEdit.text),
                );

                Navigator.pop(context);

                carregar();
              },
            ),
          ],
        );
      },
    );
  }
}
