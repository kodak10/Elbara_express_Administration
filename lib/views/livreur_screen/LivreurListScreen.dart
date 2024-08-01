import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:get/get.dart';
import 'package:elbaraexpress_admin/const/colors.dart';
import 'package:elbaraexpress_admin/views/livreur_screen/CreateLivreurScreen.dart';
import 'package:elbaraexpress_admin/views/livreur_screen/EditLivreurScreen.dart';
import 'package:elbaraexpress_admin/views/widgets/test_style.dart';

class LivreurListScreen extends StatelessWidget {
  const LivreurListScreen({super.key});

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
            return const Center(child: CircularProgressIndicator());
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
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                subtitle: Text(livreur['email'],
                    style: const TextStyle(fontSize: 14, color: Colors.white)),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(EditLivreurScreen(id: livreur.id));
                    } else if (value == 'delete') {
                      _confirmDelete(context, livreur.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Modifier'),
                    ),
                    const PopupMenuItem(
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

  void _confirmDelete(BuildContext context, String livreurId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Êtes-vous sûr de vouloir supprimer ce livreur ?"),
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
                try {
                  // Obtenir l'utilisateur Firestore
                  final doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(livreurId)
                      .get();
                  
                  final email = doc.data()?['email'];
                  final uid = doc.data()?['uid'];

                  // Supprimer le document Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(livreurId)
                      .delete();
                  
                  // Supprimer le compte utilisateur dans Firebase Authentication
                  if (email != null && uid != null) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && user.uid == uid) {
                      await user.delete();
                    }
                  }

                  Get.snackbar('Succès', 'Livreur et compte supprimés');
                } catch (e) {
                  Get.snackbar('Erreur', 'Erreur lors de la suppression: $e');
                }
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }
}
