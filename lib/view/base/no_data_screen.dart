import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/localization_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:provider/provider.dart';

class NoDataScreen extends StatelessWidget {
  final bool isOrder;
  final bool isCart;
  final bool isNothing;
  final bool isFooter;
  final bool isAddress;
  NoDataScreen({this.isCart = false, this.isNothing = false, this.isOrder = false, this.isFooter = true, this.isAddress = false});

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                    Image.asset(
                      isOrder ? Images.clock : isCart ? Images.shopping_cart : isAddress ? Images.no_address : Images.noFoodImage,
                      width: MediaQuery.of(context).size.height*0.22,
                      height: MediaQuery.of(context).size.height*0.22,
                      //color: Theme.of(context).primaryColor,
                    ),

                    Text(
                      getTranslated(isOrder ? 'no_order_history_available' : isCart ? 'empty_cart' : 'nothing_found', context),
                      style: rubikBold.copyWith(color: Theme.of(context).primaryColor, fontSize: MediaQuery.of(context).size.height*0.023),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),

                    Text(
                      isOrder ? getTranslated('buy_something_to_see', context) : isCart ? getTranslated('look_like_have_not_added', context) : '',
                      style: rubikMedium.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175), textAlign: TextAlign.center,
                    ),


                  ]),
                ),
              ],
            ),
          ),
          if(ResponsiveHelper.isDesktop(context) && isFooter) FooterView()
        ],
      ),
    );
  }
}

class NoDataMenuScreen extends StatelessWidget {
  final bool isOrder;
  final bool isCart;
  final bool isNothing;
  final bool isFooter;
  final bool isAddress;
  NoDataMenuScreen({this.isCart = false, this.isNothing = false, this.isOrder = false, this.isFooter = true, this.isAddress = false});

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                " Your Cart ",
                style: rubikMedium.copyWith(fontSize: 22), textAlign: TextAlign.center,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [


                  Padding(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                      Image.asset(
                        isOrder ? Images.clock : isCart ? Images.shopping_cart : isAddress ? Images.no_address : Images.noFoodImage,
                        width: MediaQuery.of(context).size.height*0.22,
                        height: MediaQuery.of(context).size.height*0.22,
                        //color: Theme.of(context).primaryColor,
                      ),

                      Text(
                        getTranslated(isOrder ? 'no_order_history_available' : isCart ? 'empty_cart' : 'nothing_found', context),
                        style: rubikBold.copyWith(color: Theme.of(context).primaryColor, fontSize: MediaQuery.of(context).size.height*0.023),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),

                      Text(
                        isOrder ? getTranslated('buy_something_to_see', context) : isCart ? getTranslated('look_like_have_not_added', context) : '',
                        style: rubikMedium.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175), textAlign: TextAlign.center,
                      ),


                    ]),
                  ),


                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_LARGE),
              child:  Row(children: [
                Expanded(
                  child: TextField(

                    style: rubikRegular,
                    decoration: InputDecoration(
                      hintText: getTranslated('enter_promo_code', context),
                      hintStyle: rubikRegular.copyWith(color: ColorResources.getHintColor(context)),
                      isDense: true,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(Provider.of<LocalizationProvider>(context, listen: false).isLtr ? 10 : 0),
                          right: Radius.circular(Provider.of<LocalizationProvider>(context, listen: false).isLtr ? 0 : 10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                  },
                  child: Container(
                    height: 50, width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(Provider.of<LocalizationProvider>(context, listen: false).isLtr ? 0 : 10),
                        right: Radius.circular(Provider.of<LocalizationProvider>(context, listen: false).isLtr ? 10 : 0),
                      ),
                    ),
                    child:  Text(
                      getTranslated('apply', context),
                      style: rubikMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ]),
            ),
            Container(
              width: 1170,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_LARGE),
              child: CustomButton(btnTxt: getTranslated('continue_checkout', context), onTap: () {

              }),
            ),
           /// if(ResponsiveHelper.isDesktop(context) && isFooter) FooterView()
          ],
        ),
      ),
    );
  }
}
