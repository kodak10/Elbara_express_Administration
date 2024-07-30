import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Importer la bibliothèque intl
import 'package:elbaraexpress_admin/const/const.dart'; // Importer le fichier de constantes pour les couleurs
import 'package:elbaraexpress_admin/views/widgets/loading_indicator.dart'; // Importer le widget de chargement
import 'package:elbaraexpress_admin/views/widgets/test_style.dart'; // Importer le fichier de styles personnalisés
import 'package:pdf/pdf.dart'; // Importer les bibliothèques PDF
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Importer la bibliothèque de génération PDF

class BeneficeCodePromoScreen extends StatefulWidget {
  final String codePromo;

  BeneficeCodePromoScreen({required this.codePromo});

  @override
  _BeneficeCodePromoScreenState createState() => _BeneficeCodePromoScreenState();
}

class _BeneficeCodePromoScreenState extends State<BeneficeCodePromoScreen> {
  final RxBool isLoading = false.obs;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy HH:mm', 'fr_FR'); // Format de date en français

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
          .where('deliveryStatus', isEqualTo: "delivered")
          .where('userId', isEqualTo: user.id)
          .get();

      for (var order in orderSnapshot.docs) {
        var amount = order['price'];
        if (amount is int) {
          amount = amount.toDouble();
        }
        var date = order['date']?.toDate() ?? DateTime.now();

        // Filtrer par mois et année
        if (date.month == selectedMonth && date.year == selectedYear) {
          double adjustedAmount = amount * 0.985;
          double gain = adjustedAmount * 0.1;

          totalGain += gain;

          ordersList.add({
            'amount': amount,
            'date': date,
            'gain': gain,
          });
        }
      }
    }

    return ordersList;
  }

Future<void> _generatePdf(List<Map<String, dynamic>> orders) async {
  final pdf = pw.Document();

  // Calculer la période
  String period = '${DateFormat('MMMM yyyy', 'fr_FR').format(DateTime(selectedYear, selectedMonth))}';

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Rapport des Gains: ${widget.codePromo}',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Période: $period',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Date', 'Montant', 'Gain'],
            data: orders.map((order) {
              return [
                _dateFormat.format(order['date']),
                '${(order['amount'] * 0.985).toStringAsFixed(2)} FCFA', // Montant après réduction
                '${order['gain'].toStringAsFixed(2)} FCFA',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Total Gagné: ${orders.fold<double>(0, (sum, order) => sum + order['gain']).toStringAsFixed(2)} FCFA',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}


  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: purpleColor,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    dropdownColor: purpleColor, // Couleur de fond du menu déroulant
                    style: TextStyle(color: Colors.white), // Couleur du texte du bouton sélectionné
                    items: List.generate(12, (index) => index + 1).map((month) {
                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text(
                          DateFormat('MMMM', 'fr_FR').format(DateTime(0, month)),
                          style: TextStyle(color: Colors.white), // Couleur du texte des éléments du menu déroulant
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                        // Recharger les données après changement
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    dropdownColor: purpleColor, // Couleur de fond du menu déroulant
                    style: TextStyle(color: Colors.white), // Couleur du texte du bouton sélectionné
                    items: List.generate(10, (index) => DateTime.now().year - index).map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(
                          year.toString(),
                          style: TextStyle(color: Colors.white), // Couleur du texte des éléments du menu déroulant
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                        // Recharger les données après changement
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchOrderDetails(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var orders = snapshot.data!;
                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucune commande trouvée pour ce code promo.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }

                double totalGain = orders.fold(0, (sum, order) => sum + order['gain']);

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[600], // Couleur des pointillés
                          thickness: 1, // Épaisseur de la ligne
                          endIndent: 16,
                          indent: 16,
                        ),
                        itemBuilder: (context, index) {
                          var order = orders[index];
                          var amount = order['amount'];
                          var date = order['date'];
                          var gain = order['gain'];

                          var formattedDate = _dateFormat.format(date);

                          return ListTile(
                            title: Text("Montant: ${amount.toStringAsFixed(2)} FCFA",
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                            subtitle: Text(
                              "Date: $formattedDate",
                              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
                    ElevatedButton(
                      onPressed: () => _generatePdf(orders),
                      child: Text('Imprimer'),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}
