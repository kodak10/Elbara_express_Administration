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
  List<SelectionPopupModel> compagnies = [];

  @override
  void initState() {
    super.initState();
    _fetchCompagnies();
    _loadGare();
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
        print('Fetched compagnies: $compagnies'); // Debug statement
      });
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur lors de la récupération des compagnies: $error');
    }
  }

  void _loadGare() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('gare')
          .doc(widget.gareId)
          .get();
      _nomController.text = doc['nom'];
      selectedCompagnie = doc['compagnie'];
      setState(() {
        print('Loaded gare: $_nomController.text, $selectedCompagnie'); // Debug statement
      });
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur lors du chargement de la gare: $error');
    }
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
                : Container(), // Hide the button while loading
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
                hintText: "Modifier la compagnie",
                margin: getMargin(top: 16),
                items: compagnies,
                onChanged: (value) {
                  setState(() {
                    selectedCompagnie = value?.value as String?;
                    print('Selected compagnie: $selectedCompagnie'); // Debug statement
                  });
                },
                // Ensure CustomDropDown handles and displays items correctly
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
                text: "Sauvegarder",
                margin: getMargin(top: 30),
                onTap: _updateGare,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
