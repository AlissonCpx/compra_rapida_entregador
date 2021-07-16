import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);

  final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool isComposing = false;

  final TextEditingController controller = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File foto;

  void showOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Column(
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () async {
                                        final imgFile = await _picker.getImage(
                                            source: ImageSource.camera);
                                        if (imgFile != null) {
                                          foto = File(imgFile.path);
                                          widget.sendMessage(imgFile: foto);
                                          Navigator.pop(context);
                                        }
                                      }),
                                  Text("Camera")
                                ],
                              )),
                          Expanded(
                              child: Column(
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.photo),
                                      onPressed: () async {
                                        final imgFile = await _picker.getImage(
                                            source: ImageSource.gallery);
                                        if (imgFile != null) {
                                          foto = File(imgFile.path);
                                          widget.sendMessage(imgFile: foto);
                                          Navigator.pop(context);
                                        }
                                      }),
                                  Text("Galeria")
                                ],
                              ))
                        ],
                      )
                    ],
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () async {
                /*final File imgFile = null;
                //await ImagePicker.pickImage(source: ImageSource.camera);
                if (imgFile != null) {
                  widget.sendMessage(imgFile: imgFile);
                } else {
                  return;
                }*/
                showOptions(context);
              }),
          Expanded(
              child: TextField(
                controller: controller,
                decoration:
                InputDecoration.collapsed(hintText: "Enviar uma Mensagem"),
                onChanged: (text) {
                  setState(() {
                    isComposing = text.isNotEmpty;
                  });
                },
              )),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: isComposing
                ? () {
              widget.sendMessage(text: controller.text);
              controller.clear();
              setState(() {
                isComposing = false;
              });
            }
                : null,
          )
        ],
      ),
    );
  }
}