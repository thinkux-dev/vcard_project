import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vcard_project/models/contact_model.dart';
import 'package:vcard_project/pages/form_page.dart';
import 'package:vcard_project/utils/constants.dart';

class ScanPage extends StatefulWidget {
  static const String routeName = 'scan';

  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanOver = false;
  List<String> lines = [];
  String name = '', mobile = '', email = '', address = '',
  company = '', designation = '', website = '', image = '';

  void createContact() {
    final contact = ContactModel(
      name: name,
      mobile: mobile,
      email: email,
      address: address,
      company: company,
      designation: designation,
      website: website,
      image: image,
    );
    context.goNamed(FormPage.routeName, extra: contact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Page'),
        actions: [
          IconButton(
            onPressed: name.isEmpty || mobile.isEmpty ? null : createContact,
            icon: const Icon(Icons.arrow_forward),
          )
        ],
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  getImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera),
                label: const Text('Capture'),
              ),
              TextButton.icon(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_album),
                label: const Text('Gallery'),
              ),
            ],
          ),
          if(isScanOver) Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DragTargetItem(property: ContactProperties.name, onDrop: getPropertyValue),
                  DragTargetItem(property: ContactProperties.mobile, onDrop: getPropertyValue),
                  DragTargetItem(property: ContactProperties.email, onDrop: getPropertyValue),
                  DragTargetItem(property: ContactProperties.company, onDrop: getPropertyValue),
                  DragTargetItem(property: ContactProperties.address, onDrop: getPropertyValue),
                  DragTargetItem(property: ContactProperties.designation, onDrop: getPropertyValue),
                  DragTargetItem(property: ContactProperties.website, onDrop: getPropertyValue),
                ],
              ),
            ),
          ),
          if(isScanOver) const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(hint),
          ),
          Wrap(
            // direction: Axis.vertical,
            children: lines.map((line) => LineItem(line: line)).toList(),
          ),
        ],
      ),
    );
  }

  void getImage(ImageSource camera) async {
    final xFile = await ImagePicker().pickImage(
      source: camera,
    );
    if (xFile != null) {
      setState(() {
        image = xFile.path;
      });
      EasyLoading.show(status: 'Please wait');
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      //Process image
      final RecognizedText recognizedText = await textRecognizer
          .processImage(InputImage.fromFile(File(xFile.path)));
      EasyLoading.dismiss();
      final tempList = <String>[];

      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          tempList.add(line.text);
        }
      }
      setState(() {
        lines = tempList;
        isScanOver = true;
      });
    }
  }

  getPropertyValue(String property, String value) {
    switch(property) {
      case ContactProperties.name:
        setState(() {
          name = value;
        });
        break;
      case ContactProperties.mobile:
        setState(() {
          mobile = value;
        });
        break;
      case ContactProperties.email:
        setState(() {
          email = value;
        });
        break;
      case ContactProperties.company:
        setState(() {
          company = value;
        });
        break;
      case ContactProperties.designation:
        setState(() {
          designation = value;
        });
        break;
      case ContactProperties.address:
        setState(() {
          address = value;
        });
        break;
      case ContactProperties.website:
        setState(() {
          website = value;
        });
        break;
    }
  }
}

class LineItem extends StatelessWidget {
  final String line;

  const LineItem({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: line,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Container(
        key: GlobalKey(),
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Colors.black45,
        ),
        child: Text(
          line,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
      child: Chip(
        label: Text(line),
      ),
    );
  }
}

class DragTargetItem extends StatefulWidget {
  final String property;
  final Function(String, String) onDrop;
  const DragTargetItem({super.key, required this.property, required this.onDrop});

  @override
  State<DragTargetItem> createState() => _DragTargetItemState();
}

class _DragTargetItemState extends State<DragTargetItem> {
  String dragItem = '';
  // String droppedValue = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(widget.property),
        ),
        Expanded(
          flex: 2,
          child: DragTarget<String> (
            builder: (context, candidateData, rejectedData) => Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: candidateData.isEmpty ? null
                          : Border.all(color: Colors.red, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(dragItem.isEmpty ? 'Drop here' : dragItem),
                  ),
                  if(dragItem.isNotEmpty) InkWell(
                    onTap: () {
                      setState(() {
                        dragItem = '';
                        // droppedValue = '';
                      });
                    },
                    child: const Icon(Icons.clear, size: 15,),
                  )
                ],
              ),
            ),
            onAcceptWithDetails: (value) {
              setState(() {
                if(dragItem.isEmpty) {
                  dragItem = value.data;
                } else {
                  dragItem += ' ${value.data}';
                }

                // Update the dropped value
                // droppedValue = value.data;
              });
              widget.onDrop(widget.property, dragItem);
            },
          ),
        )
      ],
    );
  }
}

