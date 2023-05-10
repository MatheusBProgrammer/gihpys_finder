import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gihpys_finder/ui/gif_page.dart';
import "package:http/http.dart" as http;
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  int _offSet = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null || _search == '') {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=lGmvXCKYZRh7kDWFrLluH1mPIjiXWGHi&limit=24&rating=g')); //Tredding}
    } else {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=lGmvXCKYZRh7kDWFrLluH1mPIjiXWGHi&q=$_search&limit=19&offset=$_offSet&rating=g&lang=en'));
    }

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  _search = text;
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'^\s'))
              ],
              decoration: InputDecoration(
                labelText: "Pesquise Aqui",
                labelStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container(
                          width: 200,
                          height: 200,
                          alignment: Alignment.center,
                          child: const Text('Erro ao carregar os gifs'));
                    } else {
                      return _creatGifTable(context, snapshot);
                    }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search.toString() == "") {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _creatGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //quantos items pode ter na horizontal
        crossAxisSpacing: 10.0, //espaçamento entre os itens na horizontal
        mainAxisSpacing: 10.0, // espaçamento entre os itens na vertival
      ),
      itemCount: _getCount(snapshot.data['data']),
      //quantos itens mostrar na tela
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(gifData: snapshot.data["data"][index])));
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
          );
        } else {
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 70,
                  ),
                  Text(
                    "Carregar mais",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  _offSet += 19;
                });
                ;
              },
            ),
          );
        }
      },
    );
  }
}
