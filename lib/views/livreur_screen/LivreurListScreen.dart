import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/views/livreur_screen/CreateLivreurScreen.dart';
import 'package:elbaraexpress_admin/views/livreur_screen/EditLivreurScreen.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class LivreurListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purpleColor,
      appBar: AppBar(
        title: boldText(text: 'Liste des Livreurs', size: 16.0),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(CreateLivreurScreen());
            },
            child: normalText(text: 'Ajouter'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'livreur')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final livreurs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: livreurs.length,
            itemBuilder: (context, index) {
              final livreur = livreurs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(livreur['photoURL']),
                ),
                 title: Text(livreur['displayName'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),

                subtitle: Text(livreur['email'],
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),

                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(EditLivreurScreen(id: livreur.id));
                    } else if (value == 'delete') {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(livreur.id)
                          .delete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Modifier'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Supprimer'),
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
