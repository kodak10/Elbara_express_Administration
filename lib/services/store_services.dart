import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbaraexpress_admin/const/const.dart';

class StoreServices {
  static getProfile(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: uid)
        .get();
  }



  // get messages
  static getAllmessage() {
    return firestore
        .collection(chatsCollection)
        .where('toId', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  // get all chat messages

  static getChatMessages(docId) {
    return firestore
        .collection(chatsCollection)
        .doc(docId)
        .collection(messageCollection)
        .orderBy('created_on', descending: false)
        .snapshots();
  }

  // get all orders
  static getAllOrders(uid) {
    return firestore.collection(ordersCollection).snapshots();
  }

  //// arrayContains  only use for list  or aray
  static getOrders(uid) {
    return firestore
        .collection(ordersCollection)
        .where('userId', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  // get all Products

  static getProducts(uid) {
    return firestore
        .collection(productsCollection)
        .where('vaendor_id', isEqualTo: uid)
        .snapshots();
  }

  // get all category

  static getBrand(uid) {
    return firestore
        .collection(brandCollection)
        .where('vaendor_id', isEqualTo: uid)
        .snapshots();
  }
}
