import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/const/const.dart';
import 'package:elbaraexpress_admin/views/gare_screen/CreateGareScreen.dart';
import 'package:elbaraexpress_admin/views/gare_screen/EditGareScreen.dart';
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class GareListScreen extends StatelessWidget {
  const GareListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purpleColor,
      appBar: AppBar(
        title: boldText(text: 'Liste des Gares', size: 16.0),
        actions: [
          TextButton(
            onPressed: () => Get.to(() => CreateGareScreen()),
            child: normalText(text: 'Ajouter'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('gare').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: loadingIndicator(circleColor: Colors.white));
          }

          final gares = snapshot.data!.docs;

          return ListView.builder(
            itemCount: gares.length,
            itemBuilder: (context, index) {
              final gare = gares[index];
              return ListTile(
                title: Text(gare['nom'], style: TextStyle(color: Colors.white)), // Texte en blanc
              
                subtitle: Text(gare['compagnie'], style: TextStyle(color: Colors.white)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.yellow), // Bouton d'édition en jaune
                      onPressed: () =>
                          Get.to(() => EditGareScreen(gareId: gare.id)),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red), // Bouton de suppression en rouge

                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('gare')
                            .doc(gare.id)
                            .delete();
                        Get.snackbar('Succès', 'Gare supprimée');
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
