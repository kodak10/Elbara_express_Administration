import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import '../../const/const.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/test_style.dart';
import 'order_details.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _firestore = FirebaseFirestore.instance;
  final List<String> statuses = ['all', 'onTheWay', 'canceled', 'delivered', 'upcoming', 'pending'];
  String? selectedYear;
  String? selectedMonth;
  String? selectedStatus = 'all';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget('Historique des Commandes'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder(
              stream: _getFilteredOrders(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return loadingIndicator();
                } else {
                  var data = snapshot.data!.docs;
                  return data.isEmpty
                      ? Center(child: Text('Aucune commande trouvée', style: TextStyle(color: fontGrey)))
                      : SingleChildScrollView(
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
                                                  orderSnapshot: data[index],
                                                ),
                                                transition: Transition.rightToLeft,
                                              );
                                            },
                                            title: boldText(
                                              text: "${data[index]['orderId']}",
                                              color: fontGrey,
                                              size: 14.0,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Rechercher par numéro de commande',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: selectedYear,
                  hint: Text('Année'),
                  items: List.generate(10, (index) {
                    final year = DateTime.now().year - index;
                    return DropdownMenuItem<String>(
                      value: year.toString(),
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedMonth,
                  hint: Text('Mois'),
                  items: List.generate(12, (index) {
                    final month = intl.DateFormat('MMMM', 'fr_FR').format(DateTime(0, index + 1));
                    return DropdownMenuItem<String>(
                      value: (index + 1).toString(),
                      child: Text(month),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedStatus,
                  hint: Text('Statut'),
                  items: statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status == 'all' ? 'Tous' : mapDeliveryStatus(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Stream<QuerySnapshot> _getFilteredOrders() {
  Query query = _firestore.collection('orders');

  // Debugging outputs
  print("Search Query: $searchQuery");
  print("Selected Year: $selectedYear");
  print("Selected Month: $selectedMonth");
  print("Selected Status: $selectedStatus");

  // Filtrage par numéro de commande
  if (searchQuery.isNotEmpty) {
    query = query.where('orderId', isGreaterThanOrEqualTo: searchQuery)
                 .where('orderId', isLessThanOrEqualTo: '$searchQuery\uf8ff');
  }

  // Filtrage par date
  if (selectedYear != null && selectedMonth != null) {
    DateTime startDate = DateTime(int.parse(selectedYear!), int.parse(selectedMonth!), 1);
    DateTime endDate = DateTime(int.parse(selectedYear!), int.parse(selectedMonth!) + 1, 1).subtract(Duration(days: 1));
    
    query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
                 .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
  } else if (selectedYear != null) {
    DateTime startDate = DateTime(int.parse(selectedYear!), 1, 1);
    DateTime endDate = DateTime(int.parse(selectedYear!) + 1, 1, 1).subtract(Duration(days: 1));
    
    query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
                 .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
  } else if (selectedMonth != null) {
    final now = DateTime.now();
    DateTime startDate = DateTime(now.year, int.parse(selectedMonth!), 1);
    DateTime endDate = DateTime(now.year, int.parse(selectedMonth!) + 1, 1).subtract(Duration(days: 1));
    
    query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
                 .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
  }

  // Filtrage par statut de livraison
  if (selectedStatus != null && selectedStatus != 'all') {
    query = query.where('deliveryStatus', isEqualTo: selectedStatus);
  }

  query = query.orderBy('date', descending: true); // Assurez-vous que le champ 'date' est indexé

  return query.snapshots();
}




  String mapDeliveryStatus(String deliveryStatus) {
    switch (deliveryStatus) {
      case 'onTheWay':
        return 'Livraison en cours';
      case 'canceled':
        return 'Livraison annulée';
      case 'delivered':
        return 'Livraison terminée';
      case 'upcoming':
        return 'Livraison à venir';
      case 'pending':
        return 'Livraison en attente';
      default:
        return deliveryStatus;
    }
  }
}
