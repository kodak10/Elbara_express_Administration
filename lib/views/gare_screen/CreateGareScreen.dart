import 'package:elbaraexpress_admin/const/custom_drop_down.dart';
import 'package:elbaraexpress_admin/const/custom_floating_edit_text.dart';
import 'package:elbaraexpress_admin/const/custom_image_view.dart';
import 'package:elbaraexpress_admin/const/selection_popup_model.dart';
import 'package:elbaraexpress_admin/const/size_utils.dart';
import 'package:elbaraexpress_admin/const/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/custom_button.dart';
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
  List<SelectionPopupModel> compagnies = [];

  @override
  void initState() {
    super.initState();
    _fetchCompagnies();
  }

  Future<void> _fetchCompagnies() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('compagnie').get();
      setState(() {
        compagnies = snapshot.docs.map((doc) {
          return SelectionPopupModel(
            title: doc['name'].toString(),
            value: doc['name'].toString(),
          );
        }).toList();
      });
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur lors de la récupération des compagnies: $error');
    }
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
                : Container(), // Remove or hide the button while loading
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomDropDown(
                padding: DropDownPadding.PaddingT17,
                icon: Container(
                  margin: getMargin(left: 30, right: 15),
                  // child: CustomImageView(
                  //   svgPath: ImageConstant.imgArrowdown,
                  // ),
                ),
                hintText: "Sélectionner une compagnie",
                margin: getMargin(top: 16),
                items: compagnies,
                onChanged: (value) {
                  setState(() {
                    selectedCompagnie = value?.value as String?;
                  });
                },
              ),
              SizedBox(height: 10),
              CustomFloatingEditText(
                controller: _nomController,
                labelText: "Nom de la Gare",
                hintText: "Entrez le nom",
                margin: getMargin(top: 31),
                prefixConstraints: BoxConstraints(
                  maxHeight: getSize(54),
                  minHeight: getSize(54),
                ),
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
                text: "Ajouter Gare",
                margin: getMargin(top: 30),
                onTap: _addGare,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
