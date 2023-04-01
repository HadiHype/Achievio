import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../User Interface/app_colors.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class DescribeGroup extends StatefulWidget {
  const DescribeGroup({super.key});

  @override
  State<DescribeGroup> createState() => _DescribeGroupState();
}

class _DescribeGroupState extends State<DescribeGroup> {
  File? _pickedImage;

  void _pickImageCamera() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
    final pickedImageFile = File(pickedImage!.path);

    setState(() {
      saveImage(pickedImageFile);
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  Future<void> saveImage(File imageFile) async {
    if (await Permission.storage.request().isGranted &&
        await Permission.photos.request().isGranted &&
        await Permission.camera.request().isGranted &&
        await Permission.mediaLibrary.request().isGranted) {
      await FlutterExifRotation.rotateAndSaveImage(path: imageFile.path);

      // compress rotated file
      try {
        await FlutterImageCompress.compressWithFile(
          imageFile.path,
          format: CompressFormat.jpeg,
        );

        // convert to bytes
        final bytes = imageFile.readAsBytesSync();

        final result = await ImageGallerySaver.saveImage(
          bytes,
          name: 'achievio',
        );

        print(result);
        print('permission granted');
      } catch (e) {
        print(e);
      }
    } else {
      print('permission denied');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _pickImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
      saveImage(pickedImageFile);
    });
    Navigator.pop(context);
  }

  void _remove() {
    setState(() {
      _pickedImage = null;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Describe your group',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          elevation: 1,
          backgroundColor: kTertiaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // create a form that takes in image input, group name, group description
            children: [
              // TODO: Implement image input
              // create a button that opens a dialog box that allows the user to select an image from their gallery
              // the image should be displayed in the dialog box
              // the image should be displayed in the group card
              const SizedBox(
                height: 20,
              ),

              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Select an image'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [
                              InkWell(
                                onTap: () async {
                                  _pickImageCamera();
                                },
                                child: const ListTile(
                                  title: Text('Camera'),
                                  leading: Icon(Icons.camera_alt_rounded),
                                ),
                              ),
                              InkWell(
                                onTap: _pickImageGallery,
                                child: const ListTile(
                                  title: Text('Gallery'),
                                  leading: Icon(Icons.photo_album_rounded),
                                ),
                              ),
                              InkWell(
                                onTap: _remove,
                                child: const ListTile(
                                  title: Text('Remove'),
                                  leading: Icon(Icons.delete_rounded),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                customBorder: const CircleBorder(),
                child: Stack(
                  children: _pickedImage == null
                      ? [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: kGreyColor,
                              borderRadius: BorderRadius.circular(70),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(70),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ]
                      : [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircleAvatar(
                              radius: 90,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _pickedImage == null
                                  ? null
                                  : FileImage(_pickedImage!),
                            ),
                          ),
                        ],
                ),
              )

              // TODO: Implement group name input

              // TODO: Implement group description input
            ],
          ),
        ),
      ),
    );
  }
}
