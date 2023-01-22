import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:image/image.dart' as imglib;
import 'dart:typed_data';
import 'package:http/http.dart' as http;



class Prediction {
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;
  final String classification;

  const Prediction({
     this.x = 0,
     this.y = 0,
     this.width = 0,
     this.height = 0,
     this.confidence = 0,
     this.classification = "",
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      x: json["x"],
      y: json["y"],
      width: json["width"],
      height: json["height"],
      confidence: json["confidence"] as double,
      classification: json["class"] as String,
    );
  }
}


class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  State<PreviewPage> createState() => _PreviewPageState();

}

class _PreviewPageState extends State<PreviewPage> {
  List<Prediction> predictions = [];
  Image? labeled;
  num height = 720;
  num width = 480;
  var _isLoading = true;


  List<Widget> renderBoxes(Size screen) {
    if (predictions == []) return [];
    if (width == null || height == null) return [];
  //
  //
  //   double topleftX = screen.width / 2 - width / 2;
  //
  //   double topLeftY = (screen.height - 76) / 2 - height / 2;
  //
  //   Color blue = Colors.blue;
  //
  //   try {
  //     return predictions.map((re) {
  //       return Container(
  //         height: height.toDouble(),
  //         width: width.toDouble(),
  //         child:
  //       );
  //     }).toList();
  //   } on NullThrownError catch (e) {
  //     debugPrint('Error occured $e');
  //   }
  //   return [];
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      apiResponse();
    });
    rebuildAllChildren(context);
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }
  // void drawBounds() {
  //   Image newImage = Image.file(File(widget.picture.path));
  //   for (int i = 0; i < predictions.length; i++) {
  //     imglib.drawRect(newImage, predictions[i]["x"] - predictions[i]["width"]/2,
  //         predictions[i]["y"] + predictions[i]["height"]/2, predictions[i]["x"] + predictions[i]["width"]/2,
  //       predictions[i]["y"] - predictions[i]["height"]/2, Colors.blue);
  //   }
  //   setState(() {
  //     labeled = newImage;
  //   });
  //
  // }

  Future apiResponse() async {
    Uint8List bytes = await File(widget.picture!.path).readAsBytes();
    String picBase64 = base64Encode(bytes);
    String APIkey = "TVwnSql9wk4Nwt6Dc2SN";
    String endpoint = "route-scout/3";
    String URL = "https://detect.roboflow.com/" + endpoint + "?api_key=" + APIkey + "&name=YOUR_IMAGE.jpg";
    http.Response response = await http.post(
      Uri.parse(URL),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': utf8.encode(picBase64).length.toString(),
        'Content-Language': 'en-US',
      },
      body: picBase64,
    );
    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body)["predictions"];
      // height = int.parse(jsonDecode(response.body)["image"]["height"]);
      // width = int.parse(jsonDecode(response.body)["image"]["width"]);
      print(response.body);
      predictions = List<Prediction>.from(l.map((model)=> Prediction.fromJson(model)));
      setState(() {
        _isLoading = false;
      });
    } else {
      print(response.statusCode);
      throw Exception('Failed to create album.');
    }
  }

  Widget _buildBoxes() {
    double topleftX = 1080 / 2 - width / 2;

    double topLeftY = (2340 - 76) / 2 - height / 2;
    return
    Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          child: Stack(
            children:
              Iterable<Positioned>[predictions.map((re) {
                return
                  Positioned(
                      left: re.x + topleftX,
                      top: re.y + topLeftY,
                      width: re.width.toDouble(),
                      height: re.height.toDouble(),
                      child: ((re.confidence > 0.50)) ? Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue,
                              width: 3,
                            )
                        ),
                        child: Text(
                          "${re.classification} ${(re.confidence * 100).toStringAsFixed(
                              0)}%",
                          style: TextStyle(
                            background: Paint()
                              //..color = blue,
                            ,color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ) : Container()
                  );
              }
              )]

        )
        )],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: false ? Image.file(File(widget.picture.path)) : _buildBoxes()
      )
      );
  }
}