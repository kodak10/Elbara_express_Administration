import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/cutom_textfield.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class EditGareScreen extends StatefulWidget {
  final String gareId;

  const EditGareScreen({Key? key, required this.gareId}) : super(key: key);

  @override
  _EditGareScreenState createState() => _EditGareScreenState();
}

class _EditGareScreenState extends State<EditGareScreen> {
  final TextEditingController _nomController = TextEditingController();
  final RxBool isLoading = false.obs;
  String? selectedCompagnie;

  @override
  void initState() {
    super.initState();
    _loadGare();
  }

  void _loadGare() async {
    final doc = await FirebaseFirestore.instance
        .collection('gare')
        .doc(widget.gareId)
        .get();
    _nomController.text = doc['nom'];
    selectedCompagnie = doc['compagnie'];
    setState(() {});
  }

  Future<List<String>> _fetchCompagnies() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('compagnie').get();
    return snapshot.docs.map((doc) => doc['name'].toString()).toList();
  }

  void _updateGare() async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('gare')
          .doc(widget.gareId)
          .update({
        'nom': _nomController.text,
        'compagnie': selectedCompagnie,
      });
      Get.snackbar('Succès', 'Gare mise à jour');
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
          title: boldText(text: 'Modifier la Gare', size: 16.0),
          actions: [
            isLoading.value
                ? loadingIndicator(circleColor: Colors.white)
                : TextButton(
                    onPressed: _updateGare,
                    child: normalText(text: 'Sauvegarder'),
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
                    onPressed: _updateGare,
                    child: Text('Sauvegarder'),
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
