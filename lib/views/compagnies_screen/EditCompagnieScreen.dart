import 'dart:io';
import 'package:elbaraexpress_admin/const/custom_floating_edit_text.dart';
import 'package:elbaraexpress_admin/const/size_utils.dart';
import 'package:elbaraexpress_admin/const/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';
import 'package:elbaraexpress_admin/views/widgets/custom_button.dart';

class EditCompagnieScreen extends StatefulWidget {
  final String compagnieId;

  const EditCompagnieScreen({Key? key, required this.compagnieId})
      : super(key: key);

  @override
  _EditCompagnieScreenState createState() => _EditCompagnieScreenState();
}

class _EditCompagnieScreenState extends State<EditCompagnieScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();
  final RxBool isLoading = false.obs;
  File? _logoImage;
  String? _currentLogoUrl;

  @override
  void initState() {
    super.initState();
    _loadCompagnie();
  }

  void _loadCompagnie() async {
    final doc = await FirebaseFirestore.instance
        .collection('compagnie')
        .doc(widget.compagnieId)
        .get();
    setState(() {
      _nameController.text = doc['name'];
      _currentLogoUrl = doc['logo'];
      if (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty) {
        _logoController.text = _currentLogoUrl!;
      }
    });
  }

  void _updateCompagnie() async {
    isLoading(true);
    try {
      String logoUrl = _currentLogoUrl ?? '';

      if (_logoImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('images/compagnies/${widget.compagnieId}');
        await storageRef.putFile(_logoImage!);
        logoUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('compagnie')
          .doc(widget.compagnieId)
          .update({
        'name': _nameController.text,
        'logo': logoUrl,
      });
      Get.snackbar('Succès', 'Compagnie mise à jour');
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur: $error');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
        _logoController.text = pickedFile.path; // Save the file path for later use
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: purpleColor,
        appBar: AppBar(
          title: boldText(text: 'Modifier la Compagnie', size: 16.0),
          actions: [
            isLoading.value
                ? loadingIndicator(circleColor: Colors.white)
                : TextButton(
                    onPressed: _updateCompagnie,
                    child: normalText(text: 'Sauvegarder'),
                  ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300],
                  ),
                  child: _logoImage != null
                      ? Image.file(
                          _logoImage!,
                          fit: BoxFit.cover,
                        )
                      : _currentLogoUrl != null && _currentLogoUrl!.isNotEmpty
                          ? Image.network(
                              _currentLogoUrl!,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              CustomFloatingEditText(
                controller: _nameController,
                labelText: "Nom de la Compagnie",
                hintText: "Entrez le nom",
                prefixConstraints: BoxConstraints(
                    maxHeight: getSize(54),
                    minHeight: getSize(54)),
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    showCustomSnackBar(context, "Le champ Nom est requis", isError: true);
                    return;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              CustomButton(
                height: getVerticalSize(54),
                text: "Sauvegarder",
                margin: getMargin(top: 30),
                onTap: _updateCompagnie,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
