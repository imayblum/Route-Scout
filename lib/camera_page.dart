import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pytorch_mobile/model.dart';
import './end_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// class Annotation {
//   final int id;
//   final String title;
//
//   const Album({required this.id, required this.title});
//
//   factory Album.fromJson(Map<String, dynamic> json) {
//     return Album(
//       id: json['id'],
//       title: json['title'],
//     );
//   }
// }

class CameraPage extends StatefulWidget {

  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;


  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future<http.Response> fetchAlbum() {
    return http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                picture: picture,
              )));

    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.medium);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Stack(children: [
            (_cameraController.value.isInitialized)
                ? CameraPreview(_cameraController)
                : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator())),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.20,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      color: Colors.black),
                  child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 30,
                          icon: Icon(
                              _isRearCameraSelected
                                  ? CupertinoIcons.switch_camera
                                  : CupertinoIcons.switch_camera_solid,
                              color: Colors.white),
                          onPressed: () {
                            setState(
                                    () => _isRearCameraSelected = !_isRearCameraSelected);
                            initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                          },
                        )),
                    Expanded(
                        child: IconButton(
                          onPressed: takePicture,
                          iconSize: 50,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.circle, color: Colors.white),
                        )),
                    const Spacer(),
                  ]),
                )),
          ]),
        ));
  }
}