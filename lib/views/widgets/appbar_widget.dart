// ignore_for_file: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;
//
import '../../const/const.dart';
import 'test_style.dart';

AppBar appbarWidget(title) {
  return AppBar(
    backgroundColor: white,
    automaticallyImplyLeading: false,
    title: boldText(text: title, color: fontGrey, size: 16.0),
    actions: [
      Center(
        child: normalText(
            //text: intl.DateFormat('EEEEEEEE,d MMM,' 'yy', 'fr').format(DateTime.now()),
            text: intl.DateFormat('EEEE, d MMM, yy', 'fr').format(DateTime.now()),

            color: purpleColor),
      ),
      10.widthBox,
    ],
  );
}
