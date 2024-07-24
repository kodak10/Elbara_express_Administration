import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbaraexpress_admin/views/order_screen/order_details.dart';
//
import '../../const/const.dart';
import '../../services/store_services.dart';
import '../products_screen/product_detail_screen.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/dashboard_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/test_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget(dashboard),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("orders")
                      .where('deliveryStatus', isEqualTo: "pending")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return loadingIndicator();
                    } else {
                      var data = snapshot.data!.docs;
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: dashboardButton(context,
                                title: enAttentes,
                                count: '${data.length}',
                                icon: icOrders),
                          ));
                    }
                  },
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("orders")
                      .where('deliveryStatus', isEqualTo: "onTheWay")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return loadingIndicator();
                    } else {
                      var data = snapshot.data!.docs;
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: dashboardButton(context,
                                title: enCours,
                                count: '${data.length}',
                                icon: icProducts),
                          ));
                    }
                  },
                ),
              ],
            ),
            10.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("orders")
                      .where('deliveryStatus', isEqualTo: "delivered")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return loadingIndicator();
                    } else {
                      var data = snapshot.data!.docs;
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: dashboardButton(context,
                                title: terminees,
                                count: '${data.length}',
                                icon: done),
                          ));
                    }
                  },
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("orders")
                      .where('paymentStatus', isEqualTo: 'payer')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return loadingIndicator();
                    } else {
                      var data = snapshot.data!.docs;
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: dashboardButton(context,
                                title: solde,
                                count: '${data.length}',
                                icon: monney),
                          ));
                    }
                  },
                ),
              ],
            ),
            10.heightBox,
            const Divider(),
            10.heightBox,
            Center(
              child: boldText(
                text: attentes,
                color: fontGrey,
                size: 16.0,
              ),
            ),
            20.heightBox,

            // StreamBuilder for the last section
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("orders")
                  .where('deliveryStatus', isEqualTo: "pending")
                  .snapshots(),
              //stream: FirebaseFirestore.instance.collection("orders").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return loadingIndicator();
                } else {
                  var data = snapshot.data!.docs;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(
                        data.length,
                        (index) => data[index]['orderId'].isEmpty
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Card(
                                  child: ListTile(
                                    onTap: () {
                                      Get.to(
                                        () => OrderDetail(
                                          orderSnapshot: data[
                                              index], // Passer orderSnapshot ici
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
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                    leading: const Icon(
                                      Icons.account_circle_rounded,
                                      size: 30,
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                    dense: true,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
