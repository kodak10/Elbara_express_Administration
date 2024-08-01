import 'package:elbaraexpress_admin/views/codePromo/benefice_code_promo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';
import 'package:elbaraexpress_admin/views/codePromo/EditPromoCodeScreen.dart';
import 'package:elbaraexpress_admin/views/codePromo/CreatePromoCodeScreen.dart';

class ListPromoCodesScreen extends StatefulWidget {
  const ListPromoCodesScreen({super.key});

  @override
  _ListPromoCodesScreenState createState() => _ListPromoCodesScreenState();
}

class _ListPromoCodesScreenState extends State<ListPromoCodesScreen> {
  final RxBool isLoading = false.obs;

  Future<void> _deletePromoCode(String docId) async {
    // Afficher la boîte de dialogue de confirmation
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Êtes-vous sûr de vouloir supprimer ce code promo ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    // Si l'utilisateur confirme, procéder à la suppression
    if (confirm == true) {
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
                                style: const TextStyle(color: Colors.white)));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final promoCodes = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        itemCount: promoCodes.length,
                        itemBuilder: (context, index) {
                          final promoCode = promoCodes[index];
                          final docId = promoCode.id;
                          return ListTile(
                            title: Text(promoCode['discount'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            subtitle: Text(
                                'Utilisateur: ${promoCode['userName']}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Get.to(PromoCodeEditScreen(docId: docId));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deletePromoCode(docId),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.white),
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
