import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/cutom_textfield.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class CreateGareScreen extends StatefulWidget {
  @override
  _CreateGareScreenState createState() => _CreateGareScreenState();
}

class _CreateGareScreenState extends State<CreateGareScreen> {
  final TextEditingController _nomController = TextEditingController();
  final RxBool isLoading = false.obs;
  String? selectedCompagnie;

  Future<List<String>> _fetchCompagnies() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('compagnie').get();
    return snapshot.docs.map((doc) => doc['name'].toString()).toList();
  }

  void _addGare() async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance.collection('gare').add({
        'nom': _nomController.text,
        'compagnie': selectedCompagnie,
      });
      Get.snackbar('Succès', 'Gare ajoutée');
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
          title: boldText(text: 'Créer une Gare', size: 16.0),
          actions: [
            isLoading.value
                ? loadingIndicator(circleColor: Colors.white)
                : TextButton(
                    onPressed: _addGare,
                    child: normalText(text: 'Ajouter'),
                  ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<String>>(
            future: _fetchCompagnies(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Erreur: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return Center(
                    child: loadingIndicator(circleColor: Colors.white));
              }

              final compagnies = snapshot.data!;

              return Column(
                children: [
                  DropdownButton<String>(
                    value: selectedCompagnie,
                    hint: Text('Sélectionner une compagnie'),
                    items: compagnies.map((compagnie) {
                      return DropdownMenuItem<String>(
                        value: compagnie,
                        child: Text(compagnie),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCompagnie = value;
                      });
                    },
                  ),
                  customTextField(
                    label: 'Nom de la Gare',
                    hint: 'Entrez le nom',
                    controller: _nomController,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addGare,
                    child: Text('Ajouter Gare'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
