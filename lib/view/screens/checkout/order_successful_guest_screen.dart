import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/theme_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:provider/provider.dart';

class OrderSuccessfulGuestScreen extends StatefulWidget {
  final String orderID;
  final int status;
  OrderSuccessfulGuestScreen({@required this.orderID, @required this.status});

  @override
  State<OrderSuccessfulGuestScreen> createState() => _OrderSuccessfulGuestScreenState();
}

class _OrderSuccessfulGuestScreenState extends State<OrderSuccessfulGuestScreen> {
  bool _isReload = true;

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(100)) : null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
       children: [
         Text(
           " Guest Mode Order Can't Be Tracked\n\nOnly Login Order Can Be Tracked\n\n Thank You\n",
           textAlign: TextAlign.center,
           style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE,fontFamily: 'Rubik',),
         ),
         Text(
           getTranslated('order_placed_successfully', context),
           style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE,  fontFamily: 'Rubik',),
         ),
         SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
         Row(mainAxisAlignment: MainAxisAlignment.center, children: [
           Text('${getTranslated('order_id', context)}:', style: rubikRegular.copyWith(fontFamily: 'Rubik',fontSize: Dimensions.PADDING_SIZE_LARGE,color: Colors.green)),
           SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
           Text(widget.orderID, style: rubikMedium.copyWith(fontSize: Dimensions.PADDING_SIZE_LARGE,fontFamily: 'Rubik',color: Colors.green)),


         ]),
         ElevatedButton(onPressed: (){
           Navigator.pushNamed(context, Routes.getDashboardRoute('home'));
         }, child: Text("Back To Home"),style: ElevatedButton.styleFrom(
           primary: Colors.red,
         ),)
       ],
      )
    );
  }
}
