import 'package:elbaraexpress_admin/const/custom_floating_edit_text.dart';
import 'package:elbaraexpress_admin/const/size_utils.dart';
import 'package:elbaraexpress_admin/const/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/custom_button.dart';  // Assurez-vous que ce chemin est correct
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
  final TextEditingController _codeController = TextEditingController();  // Nouveau champ
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _existingImageUrl;

  Future<void> _updateLivreur() async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.id)
          .update({
        //'displayName': _nameController.text,
        //'email': _emailController.text,
        //'phoneNumber': _phoneController.text,
        'code': _codeController.text,  // Ajout du champ code
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
      Get.back();
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
      //_nameController.text = data['displayName'];
     // _emailController.text = data['email'];
      //_phoneController.text = data['phoneNumber'];
      _codeController.text = data['code'] ?? '';  // Charger le code s'il existe
      //_existingImageUrl = data['photoURL'];
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
                : Container(),  // Vous pouvez ajouter un bouton si vous le souhaitez
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // CustomFloatingEditText(
              //   controller: _nameController,
              //   labelText: 'Nom',
              //   hintText: 'Entrez le nom',
              //   margin: getMargin(top: 31),
              //   prefixConstraints: BoxConstraints(
              //     maxHeight: getSize(54),
              //     minHeight: getSize(54),
              //   ),
              //   textInputType: TextInputType.text,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       showCustomSnackBar(context, 'Le champ Nom est requis', isError: true);
              //       return;
              //     }
              //     return null;
              //   },
              // ),
              // CustomFloatingEditText(
              //   controller: _emailController,
              //   labelText: 'Email',
              //   hintText: 'Entrez l\'email',
              //   margin: getMargin(top: 31),
              //   prefixConstraints: BoxConstraints(
              //     maxHeight: getSize(54),
              //     minHeight: getSize(54),
              //   ),
              //   textInputType: TextInputType.emailAddress,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       showCustomSnackBar(context, 'Le champ Email est requis', isError: true);
              //       return;
              //     }
              //     return null;
              //   },
              // ),
              // CustomFloatingEditText(
              //   controller: _phoneController,
              //   labelText: 'Téléphone',
              //   hintText: 'Entrez le téléphone',
              //   margin: getMargin(top: 31),
              //   prefixConstraints: BoxConstraints(
              //     maxHeight: getSize(54),
              //     minHeight: getSize(54),
              //   ),
              //   textInputType: TextInputType.phone,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       showCustomSnackBar(context, 'Le champ Téléphone est requis', isError: true);
              //       return;
              //     }
              //     return null;
              //   },
              // ),
              CustomFloatingEditText(
                controller: _codeController,
                labelText: 'Code',
                hintText: 'Entrez le code',
                margin: getMargin(top: 31),
                prefixConstraints: BoxConstraints(
                  maxHeight: getSize(54),
                  minHeight: getSize(54),
                ),
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    showCustomSnackBar(context, 'Le champ Code est requis', isError: true);
                    return;
                  }
                  return null;
                },
              ),
              20.heightBox,
              CustomButton(
                height: getVerticalSize(54),
                text: 'Sauvegarder',
                margin: getMargin(top: 30),
                onTap: _updateLivreur,
              ),
              10.heightBox,
              // CustomButton(
              //   height: getVerticalSize(54),
              //   text: 'Supprimer',
              //   margin: getMargin(top: 30),
              //   onTap: _deleteLivreur,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
