import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;
//
import '../../const/const.dart';
import '../../services/store_services.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/test_style.dart';

import 'order_details.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: appbarWidget(order),
    //   body: StreamBuilder(
    //       //stream: StoreServices.getOrders(currentUser!.uid),
    //       stream: FirebaseFirestore.instance.collection("orders").snapshots(),
    //       builder:
    //           (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //         if (!snapshot.hasData) {
    //           return loadingIndicator();
    //         } else {
    //           var data = snapshot.data!.docs;

    //            return Padding(
    //                 padding: const EdgeInsets.symmetric(vertical: 10.0),
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.stretch,
    //                   children: List.generate(
    //                     data.length,
    //                     (index) => data[index]['orderId'].isEmpty
    //                         ? const SizedBox()
    //                         : Padding(
    //                             padding: const EdgeInsets.symmetric(horizontal: 10.0),
    //                             child: Card(
    //                               child: ListTile(
    //                                 onTap: () {
    //                                   Get.to(
    //                                     () => OrderDetail(
    //                                       data: data[index],
    //                                     ),
    //                                     transition: Transition.rightToLeft,
    //                                   );
    //                                 },
    //                                 title: boldText(
    //                                   text: "${data[index]['orderId']}",
    //                                   color: fontGrey,
    //                                   size: 14.0,
    //                                 ),
    //                                 subtitle: normalText(
    //                                   text: "\$ ${data[index]['userNote']}",
    //                                   color: darkGrey,
    //                                 ),
    //                                 trailing: const Icon(Icons.arrow_forward_ios),
    //                                 leading: const Icon(Icons.account_circle_rounded, size: 30,),
    //                                 contentPadding: const EdgeInsets.all(10),
    //                                 dense: true,
    //                               ),
    //                             ),
    //                           ),
    //                   ),
    //                 ),
    //               );
    //         }
    //       }),
    // );
    return Scaffold(
      appBar: appbarWidget(order),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("orders").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return loadingIndicator();
          } else {
            var data = snapshot.data!.docs;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(
                    data.length,
                    (index) => data[index]['orderId'].isEmpty
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Card(
                              child: ListTile(
                                onTap: () {
                                  Get.to(
                                    () => OrderDetail(
                                      orderSnapshot: data[index], // Passer orderSnapshot ici
                                    ),
                                    transition: Transition.rightToLeft,
                                  );
                                },
                                title: boldText(
                                  text: "${data[index]['orderId']}",
                                  color: fontGrey,
                                  size: 14.0,
                                ),
                                subtitle: normalText(
                                  text: "\$ ${data[index]['userNote']}",
                                  color: darkGrey,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                leading: const Icon(Icons.account_circle_rounded, size: 30,),
                                contentPadding: const EdgeInsets.all(10),
                                dense: true,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Fonction pour mapper les valeurs de statut de livraison à des textes explicites
  String mapDeliveryStatus(String deliveryStatus) {
    switch (deliveryStatus) {
      case 'onTheWay':
        return 'Livraison en cours';
      case 'canceled':
        return 'Livraison annulée';
      case 'delivered':
        return 'Livraison Terminée';
      case 'upcoming':
        return 'Livraison à venir';
      case 'pending':
        return 'Livraison en attente';
      default:
        return deliveryStatus; // Retourne la valeur par défaut si elle ne correspond à aucun cas spécifié
    }
  }

  }

