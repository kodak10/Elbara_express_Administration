import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/compagnies_screen/CompagnieCreateScreen.dart';
import 'package:elbaraexpress_admin/views/compagnies_screen/EditCompagnieScreen.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class CompagnieListScreen extends StatelessWidget {
  const CompagnieListScreen({Key? key}) : super(key: key);

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
        stream: FirebaseFirestore.instance.collection('compagnie').snapshots(),
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
            title: Text(compagnie['name'], style: TextStyle(color: Colors.white)), // Texte en blanc
                //subtitle: Text(compagnie['logo']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                  icon: Icon(Icons.edit, color: Colors.yellow), // Bouton d'édition en jaune
                      onPressed: () => Get.to(
                          () => EditCompagnieScreen(compagnieId: compagnie.id)),
                    ),
                    IconButton(
                  icon: Icon(Icons.delete, color: Colors.red), // Bouton de suppression en rouge
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('compagnie')
                            .doc(compagnie.id)
                            .delete();
                        Get.snackbar('Succès', 'Compagnie supprimée');
                      },
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
}
