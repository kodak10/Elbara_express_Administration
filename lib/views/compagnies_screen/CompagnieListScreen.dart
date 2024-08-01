import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/views/compagnies_screen/CompagnieCreateScreen.dart';
import 'package:elbaraexpress_admin/views/compagnies_screen/EditCompagnieScreen.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class CompagnieListScreen extends StatelessWidget {
  const CompagnieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purpleColor,
      appBar: AppBar(
        title: boldText(text: 'Liste des Compagnies', size: 16.0),
        actions: [
          TextButton(
            onPressed: () => Get.to(() => CreateCompagnieScreen()),
            child: normalText(text: 'Ajouter'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('compagnie').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: loadingIndicator(circleColor: Colors.white));
          }

          final compagnies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: compagnies.length,
            itemBuilder: (context, index) {
              final compagnie = compagnies[index];
              return ListTile(
                title: Text(compagnie['name'], style: const TextStyle(color: Colors.white)), // Texte en blanc
                //subtitle: Text(compagnie['logo']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.yellow), // Bouton d'édition en jaune
                      onPressed: () => Get.to(() => EditCompagnieScreen(compagnieId: compagnie.id)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red), // Bouton de suppression en rouge
                      onPressed: () => _confirmDelete(context, compagnie.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String compagnieId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text(""),
          content: const Text("Êtes-vous sûr de vouloir supprimer cette compagnie ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseFirestore.instance.collection('compagnie').doc(compagnieId).delete();
                Get.snackbar('Succès', 'Compagnie supprimée');
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }
}
