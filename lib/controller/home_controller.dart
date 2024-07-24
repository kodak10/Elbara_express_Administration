import 'package:get/get.dart';

import '../const/firebase_conts.dart';

class HomeController extends GetxController {
  // here execute the getusername method start
  @override
  void onInit() {
    getUsername();
    super.onInit();
  }
  // here execute the getusername method end

  /// for bottom nav start
  var navIndex = 0.obs;

  /// for bottom nav end

// for get seller name start

  var username = '';

  // getUsername() async {
  //   var n = await firestore
  //       .collection(vendorsCollection)
  //       .where('id', isEqualTo: currentUser!.uid)
  //       .get()
  //       .then((value) {
  //     if (value.docs.isNotEmpty) {
  //       return value.docs.single['name']; // Parfait
  //     }
  //   });
  //   username = n;
  // }

  Future<void> getUsername() async {
  try {
    // Assurez-vous que `currentUser` n'est pas nul
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    // Requête Firestore
    var querySnapshot = await firestore
        .collection(vendorsCollection)
        .where('id', isEqualTo: currentUser!.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Récupérer le nom d'utilisateur
      var name = querySnapshot.docs.single.data()['displayName'];
      // Assigner à `username`
      username = name;
    } else {
      // Gérer le cas où aucun document n'est trouvé
      username = 'Nom non trouvé';
    }
  } catch (e) {
    // Gérer les erreurs et afficher un message si nécessaire
    print('Erreur lors de la récupération du nom d\'utilisateur: $e');
    username = 'Erreur lors de la récupération du nom';
  }
}


  // for get seller name end
}
