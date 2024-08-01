import 'package:elbaraexpress_admin/const/custom_floating_edit_text.dart';
import 'package:elbaraexpress_admin/const/size_utils.dart';
import 'package:elbaraexpress_admin/const/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/custom_button.dart'; // Assurez-vous que ce chemin est correct
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';
import 'dart:io';

class CreateLivreurScreen extends StatefulWidget {
  @override
  _CreateLivreurScreenState createState() => _CreateLivreurScreenState();
}

class _CreateLivreurScreenState extends State<CreateLivreurScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController(); // Nouveau contrôleur pour le champ de code
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

Future<void> _addLivreur() async {
  isLoading(true);
  try {
    // Créez un utilisateur dans Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: 'password',  // Mot de passe par défaut
    );

    // Utilisez l'ID de l'utilisateur créé
    String uid = userCredential.user!.uid;

    // Référence du document avec l'ID de l'utilisateur
    DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await docRef.set({
      'displayName': _nameController.text,
      'email': _emailController.text,
      'phoneNumber': '+225${_phoneController.text.trim()}', // Ajouter le téléphone
      'code': _codeController.text, // Ajouter le code
      'photoURL': 'https://firebasestorage.googleapis.com/v0/b/elbaraexpress-9b834.appspot.com/o/images%2Fuser.png?alt=media&token=d2065aab-9369-4c90-9438-f03c15a84fca',
      'role': 'livreur',
      'verif': false,
      'id': uid, // Ajouter l'ID de l'utilisateur
      'fcmToken': '',
    });

    Get.snackbar('Succès', 'Livreur ajouté');

    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _codeController.clear();

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
          title: boldText(text: 'Ajouter un Livreur', size: 16.0),
          actions: [
            isLoading.value
                ? loadingIndicator(circleColor: Colors.white)
                : Container(),  // Vous pouvez ajouter un bouton si vous le souhaitez
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFloatingEditText(
                controller: _nameController,
                labelText: "Nom",
                hintText: "Entrez le nom",
                margin: getMargin(top: 31),
                prefixConstraints: BoxConstraints(
                    maxHeight: getSize(54),
                    minHeight: getSize(54)),
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    showCustomSnackBar(context,
                        "Le champ Nom est requis",
                        isError: true);
                    return;
                  }
                  return null;
                },
              ),
              CustomFloatingEditText(
                controller: _emailController,
                labelText: "Email",
                hintText: "Entrez l'email",
                margin: getMargin(top: 31),
                prefixConstraints: BoxConstraints(
                    maxHeight: getSize(54),
                    minHeight: getSize(54)),
                textInputType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    showCustomSnackBar(context,
                        "Le champ Email est requis",
                        isError: true);
                    return;
                  }
                  return null;
                },
              ),
              CustomFloatingEditText(
                controller: _phoneController,
                labelText: "Téléphone",
                hintText: "Entrez le téléphone",
                margin: getMargin(top: 31),
                prefixConstraints: BoxConstraints(
                    maxHeight: getSize(54),
                    minHeight: getSize(54)),
                textInputType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    showCustomSnackBar(context,
                        "Le champ Téléphone est requis",
                        isError: true);
                    return;
                  }
                  return null;
                },
              ),
              CustomFloatingEditText(
                controller: _codeController,
                labelText: "Code",
                hintText: "Entrez le code",
                margin: getMargin(top: 31),
                prefixConstraints: BoxConstraints(
                    maxHeight: getSize(54),
                    minHeight: getSize(54)),
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    showCustomSnackBar(context,
                        "Le champ Code est requis",
                        isError: true);
                    return;
                  }
                  return null;
                },
              ),
              20.heightBox,
              CustomButton(
                height: getVerticalSize(54),
                text: "Ajouter Livreur".tr,
                margin: getMargin(top: 30),
                onTap: _addLivreur,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
