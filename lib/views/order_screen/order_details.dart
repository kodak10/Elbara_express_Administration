// ignore: depend_on_referenced_packages
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'package:qaswa_admin/const/app_style.dart';
import 'package:qaswa_admin/const/color_constant.dart';
import 'package:qaswa_admin/const/size_utils.dart';
import 'package:qaswa_admin/views/widgets/appbar_widget.dart';
import 'package:qaswa_admin/views/widgets/custom_button.dart';
//
import '../../const/const.dart';
import '../../controller/order_controller.dart';
import '../widgets/our_button.dart';
import '../widgets/test_style.dart';
import 'components/order_place.dart';
import 'package:http/http.dart' as http;

class OrderDetail extends StatefulWidget {
  final dynamic data;
  final DocumentSnapshot
      orderSnapshot; // Déclarez la variable orderSnapshot ici

  const OrderDetail({
    Key? key,
    required this.orderSnapshot,
    this.data, // Ajoutez-le comme paramètre du constructeur
  }) : super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  var controller = Get.put(OrdersController());
  String? selectedValue;
  String? selectedDriverPhotoUrl; // URL de la photo du livreur sélectionné
  String selectedDriverName = "Choisir un livreur";
  late String deliveryStatus = "";
  late String paymentRef = "";

  String? orderStatus;

  @override
  void initState() {
    super.initState();
    fetchOrderStatus();
  }

  Future<void> fetchOrderStatus() async {
    final url =
        Uri.parse('https://app.paydunya.com/api/v1/dmp-api/check-status');
    final headers = {
      'Content-Type': 'application/json',
      'PAYDUNYA-MASTER-KEY': 'fhRrUGWg-Upkg-0r3x-Z7DI-d8fR0aIHgxc2',
      'PAYDUNYA-PRIVATE-KEY': 'live_private_tvQxERrcZFOVXgpi3NyUckcWDDL',
      'PAYDUNYA-TOKEN': 'vI7BDJAJvpWDY8Y4rjBL',
    };

    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderSnapshot
            .id) // Utilisation de l'ID de la commande pour obtenir le document
        .get();

    final String paymentRef =
        snapshot.get('paymentRef'); // Extrait la valeur du champ paymentRef

    final body = jsonEncode({'reference_number': paymentRef});

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print('paymentRef: $paymentRef');
      final responseData = jsonDecode(response.body);
      setState(() {
        orderStatus = responseData['status'];
      });
    } else {
      // Gérer les erreurs ici, par exemple afficher un message d'erreur à l'utilisateur
      print(
          'Erreur lors de la récupération du statut de la commande: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .doc(widget.orderSnapshot.id)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              deliveryStatus = data['deliveryStatus'];
              paymentRef = data['paymentRef'];
              print('valeur: $deliveryStatus');
              return Padding(
                  //body: Container(
                  padding: getPadding(top: 24, bottom: 8),
                  child: ListView(
                      padding: getPadding(left: 16, right: 16),
                      children: [
                        Padding(
                            padding: getPadding(top: 3),
                            child: Text("Adresse de ramassage".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        Padding(
                            padding: getPadding(left: 2, top: 12),
                            child: Text(data['lieu_depart'],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBody)),
                        Padding(
                            padding: getPadding(top: 19),
                            child: Text("Adresse de livraison".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        Padding(
                            padding: getPadding(left: 2, top: 11, bottom: 16),
                            child: Text(data['lieu_arrive'],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBody)),
                        Divider(
                            height: getVerticalSize(1),
                            thickness: getVerticalSize(1),
                            color: ColorConstant.gray300),
                        SizedBox(
                          height: getVerticalSize(8),
                        ),
                        Padding(
                            padding: getPadding(top: 16, bottom: 16),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Coût:",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtSFProTextBold20),
                                  Text(
                                      data['price']
                                          .toString(), // Convert integer to string
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtSFProTextBold20)
                                ])),
                        SizedBox(
                          height: getVerticalSize(8),
                        ),
                        Divider(
                            height: getVerticalSize(1),
                            thickness: getVerticalSize(1),
                            color: ColorConstant.gray300),
                        Padding(
                            padding: getPadding(top: 32),
                            child: Text("Détails de la commande".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProTextBold20)),
                        Padding(
                            padding: getPadding(top: 21),
                            child: Text("Date de commande".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        Padding(
                            padding: getPadding(top: 10, bottom: 0),
                            child: Text(
                                data['dateRegister']
                                    .toDate()
                                    .toString(), // Convert Timestamp to DateTime, then to String
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBody)),

                        Padding(
                            padding: getPadding(top: 22),
                            child: Text("Référence du colis".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        Padding(
                            padding: getPadding(top: 10, bottom: 0),
                            child: Text(data['orderId'],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBody)),
                        Padding(
                            padding: getPadding(top: 22),
                            child: Text("Type de service".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        Padding(
                            padding: getPadding(top: 10, bottom: 0),
                            child: Text(data['type_colis'],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBody)),
                        Padding(
                            padding: getPadding(top: 22),
                            child: Text("Type d'engin".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        Padding(
                            padding: getPadding(top: 10, bottom: 0),
                            child: Text(data['selectedVehicle'],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBody)),
                        Padding(
                            padding: getPadding(top: 22),
                            child: Text("Informations supplémentaires".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        Padding(
                            padding: getPadding(top: 10, bottom: 0),
                            child: Text(data['infos_complementaire'],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBody)),

                         Divider(
                            height: getVerticalSize(1),
                            thickness: getVerticalSize(1),
                            color: ColorConstant.gray300),
                        SizedBox(
                          height: getVerticalSize(8),
                        ),
                        
                        Padding(
                            padding: getPadding(top: 22),
                            child: Text("Métode de payement".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        Padding(
                            padding: getPadding(top: 10, bottom: 0),
                            child: Text(data['paymentMethod'],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBody)),
                        Padding(
                          padding: getPadding(top: 10, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Statut de paiement",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600, // Conservez le style spécifié
                              ),
                              SizedBox(height: 10),
                              orderStatus != null
                                  ?  Text( 
                                      orderStatus == "canceled" 
                                        ? "Annulé" 
                                        : orderStatus == "pending" 
                                          ? "En attente" 
                                          : orderStatus == "completed" 
                                            ? "Payer" 
                                            : "Erreur", 
                                      style: orderStatus == "canceled" 
                                        ? AppStyle.txtOutfitRegular14Red // Texte bleu pour "onTheWay" 
                                        : orderStatus == "pending" 
                                          ? AppStyle.txtOutfitRegular14Amber // Texte jaune pour "pending" 
                                          : orderStatus == "completed" 
                                            ? AppStyle.txtOutfitRegular14Green // Texte vert pour "delivered" 
                                            : AppStyle.txtOutfitBlue, // Texte rouge par défaut 
                                    ) 
                                  : CircularProgressIndicator(), // Affiche un indicateur de chargement tant que le statut n'est pas récupéré
                            ],
                          ),
                        ),


                        Padding(
                            padding: getPadding(top: 20),
                            child: Text("Status de la livraison".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        Padding(
                          padding: getPadding(top: 10),
                          child: Text(
                            data['deliveryStatus'] == "canceled"
                                ? "Annulé"
                                : data['deliveryStatus'] == "pending"
                                    ? "En attente"
                                    : data['deliveryStatus'] == "delivered"
                                        ? "Livré"
                                        : "En transit",
                            style: data['deliveryStatus'] == "canceled"
                                ? AppStyle
                                    .txtOutfitRegular14Red // Texte bleu pour "onTheWay"
                                : data['deliveryStatus'] == "pending"
                                    ? AppStyle
                                        .txtOutfitRegular14Amber // Texte jaune pour "pending"
                                    : data['deliveryStatus'] == "delivered"
                                        ? AppStyle
                                            .txtOutfitRegular14Green // Texte vert pour "delivered"
                                        : AppStyle
                                            .txtOutfitBlue, // Texte rouge par défaut
                          ),
                        ),
                        SizedBox(
                          height: getVerticalSize(8),
                        ),
                        SizedBox(
                          height: getVerticalSize(8),
                        ),
                        Divider(
                            height: getVerticalSize(1),
                            thickness: getVerticalSize(1),
                            color: ColorConstant.gray300),
                        SizedBox(
                          height: getVerticalSize(8),
                        ),
                         Padding(
                            padding: getPadding(top: 21),
                            child: Text("Nom du livreur".tr,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtBodyGray600)),
                        //      Padding(
                        // padding: getPadding(top: 10, bottom: 0),
                        // child: StreamBuilder<DocumentSnapshot>(
                        //   stream: FirebaseFirestore.instance.collection('users').doc(data['deliveryId']).snapshots(),
                        //   builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        //     if (snapshot.hasError) {
                        //       return Text("Une erreur s'est produite");
                        //     }

                        //     if (snapshot.connectionState == ConnectionState.waiting) {
                        //       return CircularProgressIndicator();
                        //     }

                        //     if (!snapshot.hasData || snapshot.data!.data() == null) {
                        //       return Text("Aucun livreur trouvé");
                        //     }

                        //     var userData = snapshot.data!.data() as Map<String, dynamic>;
                        //     var driverName = userData['name'];

                        //     return Text(
                        //       driverName,
                        //       overflow: TextOverflow.ellipsis,
                        //       textAlign: TextAlign.left,
                        //       style: AppStyle.txtBody,
                        //     );
                        //   },
                        // ),
                        //      )
                        
                      ]));
            }
          },
        ),
        bottomNavigationBar: Padding(
            padding: getPadding(left: 16, right: 16, bottom: 40),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CustomButton(
                height: getVerticalSize(54),
                width: getHorizontalSize(190),
                text: "Annuler".tr,
                variant: ButtonVariant.OutlineDeeppurple600,
                fontStyle: ButtonFontStyle.SFProTextBold18Deeppurple600,
              ),
              CustomButton(
                height: getVerticalSize(54),
                width: getHorizontalSize(190),
                text: "Affecter".tr,
                margin: getMargin(left: 16),
                onTap: () {
                  print('deliveryStatus: $deliveryStatus');
                  if (deliveryStatus == 'pending') {
                    _showDriverSelectionModal();
                  }
                },
              )
            ])));
  }

  void _showDriverSelectionModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'livreur')
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Une erreur s'est produite");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            List<DropdownMenuItem<String>> items = [];
            snapshot.data!.docs.forEach((DocumentSnapshot doc) {
              String userId = doc.id;
              String userName = doc['displayName'];
              items.add(DropdownMenuItem<String>(
                value: userId,
                child: Text(userName),
              ));
            });

            return AlertDialog(
              title: Text("Sélectionner un livreur"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue;
                        // _loadDriverInfo(
                        //     newValue); // Charger les informations du livreur sélectionné
                      });
                    },
                    items: items,
                  ),
                  SizedBox(height: 16),
                  // Afficher le nom du livreur sélectionné
                  selectedDriverName != null
                      ? Text(selectedDriverName!)
                      : Container(),
                  SizedBox(height: 16),
                  // Afficher l'image du livreur sélectionné
                  selectedDriverPhotoUrl != null
                      ? Image.network(selectedDriverPhotoUrl!)
                      : Container(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fermer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedValue != null) {
                      // Mettre à jour le champ deliveryId dans la collection orders
                      FirebaseFirestore.instance
                          .collection('orders')
                          .doc(widget.orderSnapshot.id)
                          .update({
                        'deliveryId': selectedValue,
                        'deliveryStatus': 'onTheWay',
                      }).then((_) {
                        // Afficher un message de succès
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Livreur attribué avec succès à la commande.'),
                          ),
                        );
                      }).catchError((error) {
                        // Afficher un message d'erreur s'il y a eu un problème lors de la mise à jour
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Une erreur s\'est produite lors de l\'attribution du livreur : $error'),
                          ),
                        );
                      });
                    }
                  },
                  child: Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _loadDriverInfo(String? driverId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          selectedDriverName =
              documentSnapshot['displayName']; // Récupérer le nom du livreur
          selectedDriverPhotoUrl = documentSnapshot[
              'photoURL']; // Récupérer l'URL de l'image du livreur
        });
      } else {
        print('Le document n\'existe pas');
      }
    }).catchError((error) {
      print('Erreur lors du chargement des informations du livreur : $error');
    });
  }

  Future<void> updateOrderData() async {
    try {
      // Vérifier si un utilisateur a été sélectionné
      if (selectedValue != null) {
        String orderId = widget.orderSnapshot
            .id; // Utiliser l'ID de la commande depuis widget.orderSnapshot

        // Mettre à jour la collection "orders" dans Firestore
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({
          'deliveryStatus': 'onTheWay', // Mettre à jour le statut de livraison
          'deliveryId': selectedValue, // Mettre à jour l'ID de livraison
        });

        // Afficher un Snackbar pour indiquer que la mise à jour a réussi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande attribuée au livreur avec succès.'),
          ),
        );
        print('Order updated successfully');
      } else {
        print('No user selected');
      }
    } catch (error) {
      print('Error updating order: $error');
    }
  }
}
