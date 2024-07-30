import 'package:elbaraexpress_admin/views/codePromo/benefice_code_promo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';
import 'package:elbaraexpress_admin/views/codePromo/EditPromoCodeScreen.dart'; // Assurez-vous que ce fichier est correctement importé
import 'package:elbaraexpress_admin/views/codePromo/CreatePromoCodeScreen.dart'; // Import du fichier pour créer un code promo

class ListPromoCodesScreen extends StatefulWidget {
  @override
  _ListPromoCodesScreenState createState() => _ListPromoCodesScreenState();
}

class _ListPromoCodesScreenState extends State<ListPromoCodesScreen> {
  final RxBool isLoading = false.obs;

  Future<void> _deletePromoCode(String docId) async {
    isLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('codePromo')
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
    return Obx(() => Scaffold(
          backgroundColor: purpleColor,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                boldText(text: 'Liste des Codes Promo', size: 16.0),
                isLoading.value
                    ? loadingIndicator(circleColor: Colors.white)
                    : TextButton(
                        onPressed: () {
                          Get.to(CreatePromoCodeScreen());
                        },
                        child: normalText(text: "Créer", color: Colors.white),
                      ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('codePromo')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Une erreur est survenue: ${snapshot.error}',
                                style: TextStyle(color: Colors.white)));
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
                            title: Text(promoCode['discount'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            subtitle: Text(
                                'Utilisateur: ${promoCode['userName']}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Get.to(PromoCodeEditScreen(docId: docId));
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deletePromoCode(docId),
                                ),

                                IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BeneficeCodePromoScreen(codePromo: promoCode['discount']),
                                      ),
                                    );
                                  },
                                ),


                              ],
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
        ));
  }
}
