import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/const/custom_floating_edit_text.dart';
import 'package:elbaraexpress_admin/const/size_utils.dart';
import 'package:elbaraexpress_admin/const/snackbar.dart';
import 'package:elbaraexpress_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/views/widgets/cutom_textfield.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateCompagnieScreen extends StatefulWidget {
  @override
  _CreateCompagnieScreenState createState() => _CreateCompagnieScreenState();
}

class _CreateCompagnieScreenState extends State<CreateCompagnieScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _logoUrl;
  final RxBool isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Upload the selected image to Firebase Storage
      final file = File(pickedFile.path);
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('images/compagnies')
            .child('${DateTime.now().toIso8601String()}_${pickedFile.name}');
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          _logoUrl = downloadUrl;
        });
      } catch (e) {
        Get.snackbar('Erreur', 'Erreur lors du téléchargement de l\'image: $e');
        
      }
    }
  }

  void _addCompagnie() async {
    if (_nameController.text.isEmpty || _logoUrl == null) {
      showCustomSnackBar(context, "Veuillez remplir tous les champs et ajouter un logo", isError: true);
      return;
    }

    isLoading(true);
    try {
      await FirebaseFirestore.instance.collection('compagnie').add({
        'name': _nameController.text,
        'logo': _logoUrl,
      });
      Get.snackbar('Succès', 'Compagnie ajoutée');
      _nameController.clear();
      setState(() {
        _logoUrl = null;
      });
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur: $error');
    } finally {
      isLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: purpleColor,
        appBar: AppBar(
          title: boldText(text: 'Créer une Compagnie', size: 16.0),
          actions: [
            isLoading.value
                ? loadingIndicator(circleColor: Colors.white)
                : SizedBox.shrink(), // No action button when loading
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: _logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_logoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _logoUrl == null
                      ? Center(child: Text('Sélectionner un logo', style: TextStyle(color: Colors.black54)))
                      : null,
                ),
              ),
              20.heightBox,
              CustomFloatingEditText(
                controller: _nameController,
                labelText: "Nom de la Compagnie",
                hintText: "Entrez le nom",
                margin: getMargin(top: 31),
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
              20.heightBox, // Adding space between the fields and the button
              CustomButton(
                height: getVerticalSize(54),
                text: "Ajouter Compagnie",
                margin: getMargin(top: 30),
                onTap: _addCompagnie,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
