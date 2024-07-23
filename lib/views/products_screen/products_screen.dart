import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../const/const.dart';
import '../../controller/products_controller.dart';
import '../../services/store_services.dart';
import '../brand/brand.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/test_style.dart';
import 'add_product.dart';
import 'components/floatingbuttons.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProductsController());

    return Scaffold(
      
      appBar: appbarWidget(products),
      body: StreamBuilder(
          stream: StoreServices.getProducts(currentUser!.uid),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return loadingIndicator();
            } else {
              var data = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                      children: List.generate(
                    data.length,
                    (index) => ListTile(
                      onTap: () {
                        Get.to(
                          () => ProductDetailScreen(
                            data: data[index],
                          ),
                          transition: Transition.downToUp,
                        );
                      },
                      leading: CachedNetworkImage(
                        placeholder: (context, url) => loadingIndicator(),
                        imageUrl: "${data[index]['image'][0]}",
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      title: boldText(
                          text: "${data[index]['p_name']}",
                          color: fontGrey,
                          size: 14.0),
                      subtitle: Row(
                        children: [
                          normalText(
                              text: "\$ ${data[index]['p_price']}",
                              color: darkGrey),
                          10.widthBox,
                          boldText(
                              text: data[index]['is_featured'] == true
                                  ? "Featured"
                                  : '',
                              color: green)
                        ],
                      ),
                    ),
                  )),
                ),
              );
            }
          }),
    );
  }
}
