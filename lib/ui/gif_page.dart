import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GifPage extends StatelessWidget {
  const GifPage({Key? key, required this.gifData}) : super(key: key);

  final Map gifData;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(gifData["title"],style: TextStyle(color: Colors.black,fontSize: 16),),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: (){
            Share.share(gifData["images"]["fixed_height"]["url"]);
          }, icon: Icon(Icons.share,color: Colors.black,))
        ],
      ),
      body: Center(
        child: Image.network(gifData["images"]["fixed_height"]["url"]),
      ),

    );
  }
}
