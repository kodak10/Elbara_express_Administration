import 'package:elbaraexpress_admin/views/widgets/test_style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/custom_button.dart';
import 'package:elbaraexpress_admin/const/custom_floating_edit_text.dart';
import 'package:elbaraexpress_admin/const/size_utils.dart';
import 'package:elbaraexpress_admin/const/snackbar.dart';

class CreatePromoCodeScreen extends StatefulWidget {
  @override
  _CreatePromoCodeScreenState createState() => _CreatePromoCodeScreenState();
}

class _CreatePromoCodeScreenState extends State<CreatePromoCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  bool isLoading = false;

  Future<void> _addPromoCode() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance.collection('codePromo').add({
        'discount': _codeController.text,
        'contact': '+225 ${_contactController.text}', 
        'userName': _userNameController.text,
      });
      Get.snackbar('Succès', 'Code promo ajouté');
      _codeController.clear();
      _contactController.clear();
      _userNameController.clear();
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purpleColor,
      appBar: AppBar(
        title: boldText(text: 'Ajouter Code Promo', size: 16.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomFloatingEditText(
              controller: _codeController,
              labelText: "Code Promo",
              hintText: "Entrez le code promo",
              margin: EdgeInsets.only(top: 10),
              prefixConstraints: BoxConstraints(maxHeight: 54, minHeight: 54),
              textInputType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  showCustomSnackBar(context, "Le champ Code Promo est requis", isError: true);
                  return;
                }
                return null;
              },
            ),
            CustomFloatingEditText(
              controller: _contactController,
              labelText: "Contact",
              hintText: "Entrez le contact",
              margin: EdgeInsets.only(top: 10),
              prefixConstraints: BoxConstraints(maxHeight: 54, minHeight: 54),
              textInputType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  showCustomSnackBar(context, "Le champ Contact est requis", isError: true);
                  return;
                }
                return null;
              },
            ),
            CustomFloatingEditText(
              controller: _userNameController,
              labelText: "Nom d'utilisateur",
              hintText: "Entrez le nom d'utilisateur",
              margin: EdgeInsets.only(top: 10),
              prefixConstraints: BoxConstraints(maxHeight: 54, minHeight: 54),
              textInputType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  showCustomSnackBar(context, "Le champ Nom d'utilisateur est requis", isError: true);
                  return;
                }
                return null;
              },
            ),
            20.heightBox,
            CustomButton(
              height: getVerticalSize(54),
              text: isLoading ? 'Enregistrement...' : "Ajouter Code Promo".tr,
              margin: getMargin(top: 30),
              onTap: _addPromoCode,
            ),
          ],
        ),
      ),
    );
  }
}
