import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/views/widgets/cutom_textfield.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class CreateCompagnieScreen extends StatelessWidget {
  CreateCompagnieScreen({Key? key}) : super(key: key);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();
  final RxBool isLoading = false.obs;

  void _addCompagnie() async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance.collection('compagnie').add({
        'name': _nameController.text,
        'logo': _logoController.text,
      });
      Get.snackbar('Succès', 'Compagnie ajoutée');
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
                : TextButton(
                    onPressed: _addCompagnie,
                    child: normalText(text: 'Ajouter'),
                  ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              customTextField(
                label: 'Nom de la Compagnie',
                hint: 'Entrez le nom',
                controller: _nameController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
