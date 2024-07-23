import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/cutom_textfield.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

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
    _nameController.text = doc['name'];
    _logoController.text = doc['logo'];
  }

  void _updateCompagnie() async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('compagnie')
          .doc(widget.compagnieId)
          .update({
        'name': _nameController.text,
        'logo': _logoController.text,
      });
      Get.snackbar('Succès', 'Compagnie mise à jour');
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              customTextField(
                label: 'Nom de la Compagnie',
                hint: 'Entrez le nom',
                controller: _nameController,
              ),
              // SizedBox(height: 10),
              // customTextField(
              //   label: 'URL du Logo',
              //   hint: 'Entrez l\'URL du logo',
              //   controller: _logoController,
              // ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _updateCompagnie,
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
