import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Importer la bibliothèque intl
import 'package:elbaraexpress_admin/const/const.dart'; // Importer le fichier de constantes pour les couleurs
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart'; // Importer le widget de chargement
import 'package:elbaraexpress_admin/views/widgets/test_style.dart'; // Importer le fichier de styles personnalisés

class BeneficeCodePromoScreen extends StatefulWidget {
  final String codePromo;

  BeneficeCodePromoScreen({required this.codePromo});

  @override
  _BeneficeCodePromoScreenState createState() => _BeneficeCodePromoScreenState();
}

class _BeneficeCodePromoScreenState extends State<BeneficeCodePromoScreen> {
  final RxBool isLoading = false.obs;

  Future<List<Map<String, dynamic>>> _fetchOrderDetails() async {
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('codePromo', isEqualTo: widget.codePromo)
        .get();

    List<Map<String, dynamic>> ordersList = [];
    double totalGain = 0;

    for (var user in userSnapshot.docs) {
      var orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.id)
          .get();

      for (var order in orderSnapshot.docs) {
        var amount = order['price'];
        if (amount is int) {
          amount = amount.toDouble();
        }
        var date = order['date']?.toDate() ?? DateTime.now();

        // Soustraire 1.5% du montant
        double adjustedAmount = amount * 0.985;
        // Calculer 10% du montant ajusté
        double gain = adjustedAmount * 0.1;

        totalGain += gain;

        ordersList.add({
          'amount': amount,
          'date': date,
          'gain': gain,
        });
      }
    }

    return ordersList;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: purpleColor, // Utiliser une couleur de fond similaire
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            boldText(text: '', size: 16.0),
            isLoading.value
                ? loadingIndicator(circleColor: Colors.white)
                : SizedBox.shrink(),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrderDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data!;
          double totalGain = orders.fold(0, (sum, order) => sum + order['gain']);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    var amount = order['amount'];
                    var date = order['date'];
                    var gain = order['gain'];

                    // Formatage de la date
                    var formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

                    return ListTile(
                      title: Text("Montant: ${amount.toStringAsFixed(2)} FCFA",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      subtitle: Text(
                        "Date: $formattedDate",
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]), // Couleur gris pour la date
                      ),
                      trailing: Text("+${gain.toStringAsFixed(2)} FCFA",
                          style: TextStyle(color: Colors.green, fontSize: 16)),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Total Gagné: ${totalGain.toStringAsFixed(2)} FCFA",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}
