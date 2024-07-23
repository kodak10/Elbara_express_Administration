import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/cutom_textfield.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'dart:io';

import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class EditLivreurScreen extends StatefulWidget {
  final String id;
  EditLivreurScreen({required this.id});

  @override
  _EditLivreurScreenState createState() => _EditLivreurScreenState();
}

class _EditLivreurScreenState extends State<EditLivreurScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _existingImageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images/${_imageFile!.name}');
      final uploadTask = storageRef.putFile(File(_imageFile!.path));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }

  Future<void> _updateLivreur() async {
    isLoading(true);
    try {
      final imageUrl = await _uploadImage();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.id)
          .update({
        'displayName': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'photoURL': imageUrl ?? _existingImageUrl,
      });
      Get.snackbar('Succès', 'Livreur mis à jour');
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur: $error');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _deleteLivreur() async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.id)
          .delete();
      Get.snackbar('Succès', 'Livreur supprimé');
      Get.back(); // Retourne à la liste des livreurs après suppression
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur: $error');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _loadLivreurData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['displayName'];
      _emailController.text = data['email'];
      _phoneController.text = data['phoneNumber'];
      _existingImageUrl = data['photoURL'];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLivreurData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: purpleColor,
        appBar: AppBar(
          title: boldText(text: 'Modifier un Livreur', size: 16.0),
          actions: [
            isLoading.value
                ? loadingIndicator(circleColor: Colors.white)
                : TextButton(
                    onPressed: _updateLivreur,
                    child: normalText(text: 'Sauvegarder'),
                  ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: _imageFile == null
                      ? _existingImageUrl != null
                          ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                          : Center(child: Text('Sélectionner une image'))
                      : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                ),
              ),
              customTextField(
                label: 'Nom',
                hint: 'Entrez le nom',
                controller: _nameController,
              ),
              10.heightBox,
              customTextField(
                label: 'Email',
                hint: 'Entrez l\'email',
                controller: _emailController,
              ),
              10.heightBox,
              customTextField(
                label: 'Téléphone',
                hint: 'Entrez le téléphone',
                controller: _phoneController,
              ),
              10.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _updateLivreur,
                    child: Text('Sauvegarder'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteLivreur,
                    child: Text('Supprimer'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
