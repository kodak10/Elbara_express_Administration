import 'package:elbaraexpress_admin/const/custom_floating_edit_text.dart';
import 'package:elbaraexpress_admin/const/size_utils.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/custom_button.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';

class PromoCodeEditScreen extends StatefulWidget {
  final String docId; // Document ID du code promo à éditer

  PromoCodeEditScreen({required this.docId});

  @override
  _PromoCodeEditScreenState createState() => _PromoCodeEditScreenState();
}

class _PromoCodeEditScreenState extends State<PromoCodeEditScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadPromoCode();
  }

  Future<void> _loadPromoCode() async {
    isLoading(true);
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('codePromo')
          .doc(widget.docId)
          .get();
      if (doc.exists) {
        _codeController.text = doc['discount'];
        _contactController.text = doc['contact'];
        _userNameController.text = doc['userName'];
      } else {
        Get.snackbar('Erreur', 'Le code promo n\'existe pas');
        Get.back();
      }
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur: $error');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _updatePromoCode() async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('codePromo')
          .doc(widget.docId)
          .update({
        //'discount': _codeController.text,
        'contact': _contactController.text,
        'userName': _userNameController.text,
      });
      Get.snackbar('Succès', 'Code promo mis à jour');
      Get.back();
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
          title: boldText(text: 'Édition du Code Promo', size: 16.0),
          actions: [
            isLoading.value
                ? loadingIndicator(circleColor: Colors.white)
                : Container()
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // CustomFloatingEditText(
              //   controller: _codeController,
              //   labelText: "Code Promo",
              //   hintText: "Entrez le code promo",
              //   margin: EdgeInsets.only(top: 10),
              //   prefixConstraints: BoxConstraints(
              //       maxHeight: 54, minHeight: 54),
              //   textInputType: TextInputType.text,
              // ),
              CustomFloatingEditText(
                controller: _contactController,
                labelText: "Contact",
                hintText: "Entrez le contact",
                margin: EdgeInsets.only(top: 10),
                prefixConstraints: BoxConstraints(
                    maxHeight: 54, minHeight: 54),
                textInputType: TextInputType.text,
              ),
              CustomFloatingEditText(
                controller: _userNameController,
                labelText: "Nom d'utilisateur",
                hintText: "Entrez le nom d'utilisateur",
                margin: EdgeInsets.only(top: 10),
                prefixConstraints: BoxConstraints(
                    maxHeight: 54, minHeight: 54),
                textInputType: TextInputType.text,
              ),
              20.heightBox,
              CustomButton(
                height: getVerticalSize(54),
                text: "Enregistrer".tr,
                margin: getMargin(top: 30),
                onTap: _updatePromoCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
