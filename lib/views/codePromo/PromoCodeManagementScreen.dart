import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/cutom_textfield.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class PromoCodeManagementScreen extends StatefulWidget {
  @override
  _PromoCodeManagementScreenState createState() =>
      _PromoCodeManagementScreenState();
}

class _PromoCodeManagementScreenState extends State<PromoCodeManagementScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> _addPromoCode() async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance.collection('codePromo').add({
        'discount': _codeController.text,
        'contact': _contactController.text,
        'userName': _userNameController.text,
      });
      Get.snackbar('Succès', 'Code promo ajouté');
      _codeController.clear();
      _contactController.clear();
      _userNameController.clear();
    } catch (error) {
      Get.snackbar('Erreur', 'Erreur: $error');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _deletePromoCode(String docId) async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('promoCodes')
          .doc(docId)
          .delete();
      Get.snackbar('Succès', 'Code promo supprimé');
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
          title: boldText(text: 'Gestion des Codes Promo', size: 16.0),
          actions: [
            isLoading.value
                ? loadingIndicator(circleColor: Colors.white)
                : TextButton(
                    onPressed: _addPromoCode,
                    child: normalText(text: 'Ajouter'),
                  ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              customTextField(
                label: 'Code Promo',
                hint: 'Entrez le code promo',
                controller: _codeController,
              ),
              10.heightBox,
              customTextField(
                label: 'Contact',
                hint: 'Entrez le contact',
                controller: _contactController,
              ),
              10.heightBox,
              customTextField(
                label: 'Nom d\'utilisateur',
                hint: 'Entrez le nom d\'utilisateur',
                controller: _userNameController,
              ),
              20.heightBox,
              ElevatedButton(
                onPressed: _addPromoCode,
                child: Text('Ajouter Code Promo'),
              ),
              20.heightBox,
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('promoCodes')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Une erreur est survenue: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final promoCodes = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      itemCount: promoCodes.length,
                      itemBuilder: (context, index) {
                        final promoCode = promoCodes[index];
                        final docId = promoCode.id;
                        return ListTile(
                          title: Text(promoCode['discount']),
                          subtitle: Text(
                              'Contact: ${promoCode['contact']}\nUtilisateur: ${promoCode['userName']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePromoCode(docId),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
