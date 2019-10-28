import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class ImageField extends StatefulWidget{
  final void Function(File) onSaved;
  final String initialValue;
  final double imgHeight;
  final String noImagePath;

  ImageField({
    @required this.onSaved,
    @required this.initialValue,
    @required this.noImagePath,
    this.imgHeight = 200,
  });

  @override
  State<StatefulWidget> createState() {
    return new ImageFieldState();
  }
}

class ImageFieldState extends State<ImageField> {
  File image;
  Image tmpImg;

  @override
  void initState() {
    super.initState();
    if(widget.initialValue != null) {
      tmpImg = Image.memory(Base64Decoder().convert(widget.initialValue));
    } else {
      tmpImg = null;
    }
  }

  void _filePicker() async{
    File img = await ImagePicker.pickImage(source:ImageSource.gallery);
    if(img != null) {
      setState(() {
        image = img;
        tmpImg = Image.file(image, fit:BoxFit.scaleDown);
      });
      widget.onSaved(image);
    }
  }

  void _cameraPicker() async{
    File img = await ImagePicker.pickImage(source:ImageSource.camera);
    if(img != null) {
      setState(() {
        image = img;
        tmpImg = Image.file(image, fit:BoxFit.scaleDown);
      });
      widget.onSaved(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(height: widget.imgHeight,child:tmpImg != null ? tmpImg : (image == null ? Image.asset(widget.noImagePath, fit:BoxFit.scaleDown) : Image.file(image, fit:BoxFit.scaleDown))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.file_upload),
              onPressed: _filePicker,
            ),
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: _cameraPicker,
            )
          ],
        )
      ],
    );
  }
}