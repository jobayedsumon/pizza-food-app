import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/cart_model.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/product_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/theme_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/read_more_text.dart';
import 'package:flutter_restaurant/view/base/rating_bar.dart';
import 'package:flutter_restaurant/view/base/wish_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CartBottomSheet extends StatefulWidget {
  final Product product;
  final bool fromSetMenu;
  final Function callback;
  final CartModel cart;
  final int cartIndex;
  final bool fromCart;

  CartBottomSheet({@required this.product, this.fromSetMenu = false, this.callback, this.cart, this.cartIndex, this.fromCart = false});

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}


class _CartBottomSheetState extends State<CartBottomSheet> {
  int _cartIndex;
  List<String> _selectedAnimals = [];
  static List<Allergies> _allergies = [];

  final _items = _allergies.map((allergie) => MultiSelectItem<Allergies>(allergie, allergie.name)).toList();
  //List<Animal> _selectedAnimals = [];
  List<Allergies> _selectedAllergiesItem = [];
  List<Allergies> _selectedAnimals3 = [];
  //List<Animal> _selectedAnimals4 = [];
  List<Allergies> _selectedAllergies = [];
  final _multiSelectKey = GlobalKey<FormFieldState>();
  int selectedItem = 0;

  @override
  void initState() {
    Provider.of<ProductProvider>(context, listen: false).initData(widget.product, widget.cart, context);
    super.initState();
    _selectedAllergies = _allergies;
  }

  @override
  Widget build(BuildContext context) {
    Variation _variation = Variation();

    return Consumer<CartProvider>(
        builder: (context, _cartProvider, child) {
          _cartProvider.setCartUpdate(false);
         // _cartProvider.cartList
        return Stack(
          children: [
            Container(
              width: 600,
              //height: MediaQuery.of(context).size.height,
              constraints: BoxConstraints(
              //  maxHeight:  ResponsiveHelper.isMobile(context)?MediaQuery.of(context).size.height*.9:MediaQuery.of(context).size.height*.9,
                //minHeight:_cartProvider.cartList. MediaQuery.of(context).size.height,
              ),
              padding: EdgeInsets.symmetric(horizontal:Dimensions.PADDING_SIZE_DEFAULT),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: ResponsiveHelper.isMobile(context)
                    ? BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                    : BorderRadius.all(Radius.circular(20)),
              ),
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  double _startingPrice;
                  double _endingPrice;
                  if (widget.product.choiceOptions.length != 0) {
                    List<double> _priceList = [];
                    widget.product.variations.forEach((variation) => _priceList.add(variation.price));
                    _priceList.sort((a, b) => a.compareTo(b));
                    _startingPrice = _priceList[0];
                    if (_priceList[0] < _priceList[_priceList.length - 1]) {
                      _endingPrice = _priceList[_priceList.length - 1];
                    }
                  } else {
                    _startingPrice = widget.product.price;
                  }

                  List<String> _variationList = [];
                  for (int index = 0; index < widget.product.choiceOptions.length; index++) {
                    _variationList.add(widget.product.choiceOptions[index].options[productProvider.variationIndex[index]].replaceAll(' ', ''));
                  }
                  String variationType = '';
                  bool isFirst = true;
                  _variationList.forEach((variation) {
                    if (isFirst) {
                      variationType = '$variationType$variation';
                      isFirst = false;
                    } else {
                      variationType = '$variationType-$variation';
                    }
                  });


                  double price = widget.product.price;
                  for (Variation variation in widget.product.variations) {
                    if (variation.type == variationType) {
                      price = variation.price;
                      _variation = variation;
                      break;
                    }
                  }
                  double priceWithDiscount = PriceConverter.convertWithDiscount(context, price, widget.product.discount, widget.product.discountType);
                  double addonsCost = 0;
                  List<AddOn> _addOnIdList = [];
                  List<Allerg> _allergiesIdList = [];
                  for (int index = 0; index < widget.product.addOns.length; index++) {
                    if (productProvider.addOnActiveList[index]) {
                      addonsCost = addonsCost + (widget.product.addOns[index].price * productProvider.addOnQtyList[index]);
                      _addOnIdList.add(AddOn(id: widget.product.addOns[index].id, quantity: productProvider.addOnQtyList[index]));
                    }
                  }
                  for (int index = 0; index < widget.product.allergies.length; index++) {
                    if (productProvider.allergiesActiveList[index]) {
                     // addonsCost = addonsCost + (widget.product.addOns[index].price * productProvider.addOnQtyList[index]);
                      _allergiesIdList.add(Allerg(id: widget.product.allergies[index].id, quantity: productProvider.allergiesQtyList[index]));
                    }
                  }

                  DateTime _currentTime = Provider.of<SplashProvider>(context, listen: false).currentTime;
                  DateTime _start = DateFormat('hh:mm:ss').parse(widget.product.availableTimeStarts);
                  DateTime _end = DateFormat('hh:mm:ss').parse(widget.product.availableTimeEnds);
                  DateTime _startTime =
                  DateTime(_currentTime.year, _currentTime.month, _currentTime.day, _start.hour, _start.minute, _start.second);
                  DateTime _endTime = DateTime(_currentTime.year, _currentTime.month, _currentTime.day, _end.hour, _end.minute, _end.second);
                  if (_endTime.isBefore(_startTime)) {
                    _endTime = _endTime.add(Duration(days: 1));
                  }
                  bool _isAvailable = _currentTime.isAfter(_startTime) && _currentTime.isBefore(_endTime);

                  CartModel _cartModel = CartModel(
                    price,
                    priceWithDiscount,
                    [_variation],
                    (price - PriceConverter.convertWithDiscount(context, price, widget.product.discount, widget.product.discountType)),
                    productProvider.quantity,
                    price - PriceConverter.convertWithDiscount(context, price, widget.product.tax, widget.product.taxType),
                    _addOnIdList,
                    _allergiesIdList,
                    widget.product,
                  );

                  _cartIndex = _cartProvider.isExistInCart(
                    widget.product.id, variationType.isEmpty ? null : variationType, false, null,
                  );
                  print('is exit : $_cartIndex');

                  double priceWithQuantity = priceWithDiscount * productProvider.quantity;
                  double priceWithAddons = priceWithQuantity + addonsCost;

                  return Container(
                    constraints: BoxConstraints(
                        //maxHeight:  ResponsiveHelper.isMobile(context)?MediaQuery.of(context).size.height*.6:MediaQuery.of(context).size.height*.6,
                        maxHeight:  productProvider.addOnQtyList.length>0?MediaQuery.of(context).size.height*.91:MediaQuery.of(context).size.height*.7,
                      //minHeight:_cartProvider.cartList. MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: ResponsiveHelper.isMobile(context) ? EdgeInsets.zero :EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                            child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start, children: [
                              //Product
                               _productView(
                                 context, _startingPrice, _endingPrice,
                                 price, priceWithDiscount,
                                 _cartModel,
                               ),
                              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              // Quantity
                             ResponsiveHelper.isMobile(context) ? Column(
                               children: [
                                 _quantityView(context, _cartModel),
                                 SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                               ],
                             ) : _description(context),
                              // Variation
                              _variationView(productProvider, variationType),

                              widget.product.choiceOptions.length > 0 ? SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL) : SizedBox(),


                             if(ResponsiveHelper.isMobile(context)) _description(context),

                                  productProvider.addOnQtyList.length>0?Container(
                                    padding: EdgeInsets.only(bottom: 5),
                               height: 35,
                               child:  Row(
                                 children: [
                                   Expanded(
                                       flex: 1,
                                       child: InkWell(
                                         onTap: () {
                                           selectedItem=0;
                                           setState(() {

                                           });
                                         },
                                         child: Container(
                                           alignment: Alignment.center,
                                           padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,vertical:8),
                                           decoration: BoxDecoration(
                                             color: selectedItem==0 ? Theme.of(context).primaryColor:ColorResources.BACKGROUND_COLOR ,
                                             borderRadius: BorderRadius.circular(5),
                                           ),
                                           child: Text(
                                             "Addons",
                                             maxLines: 1,
                                             overflow: TextOverflow.ellipsis,
                                             style: rubikRegular.copyWith(
                                               color: selectedItem==0
                                                   ?  ColorResources.COLOR_WHITE:ColorResources.COLOR_BLACK,
                                             ),
                                           ),
                                         ),
                                       )
                                       /*CustomButton(
                                           btnTxt: 'Addons',
                                            textStyle:TextStyle(color: selectedItem==0?Colors.white:Colors.black),
                                           backgroundColor: selectedItem==0?Theme.of(context).primaryColor:Color(
                                               0xfff4f7fc),
                                           onTap: () {
                                             selectedItem=0;
                                            setState(() {

                                            });
                                           }
                                       )*/
                                   ),
                                   SizedBox(width: 5,),
                                   Expanded(
                                       flex: 1,
                                     child: InkWell(onTap: () {
                                       selectedItem=1;
                                       setState(() {

                                       });
                                     },
                                       child: Container(
                                         alignment: Alignment.center,
                                         padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                         decoration: BoxDecoration(
                                           color: selectedItem==1 ? Theme.of(context).primaryColor:ColorResources.BACKGROUND_COLOR,
                                           borderRadius: BorderRadius.circular(5),
                                         ),
                                         child: Text(
                                           "Allergies",
                                           maxLines: 1,
                                           overflow: TextOverflow.ellipsis,
                                           style: rubikRegular.copyWith(
                                             color: selectedItem==1
                                                 ?ColorResources.COLOR_WHITE: ColorResources.COLOR_BLACK,
                                           ),
                                         ),
                                       ),
                                     ),
                                      /* child:  CustomButton(
                                           btnTxt: 'Allergies',
                                           textStyle:TextStyle(color: selectedItem==1?Colors.white:Colors.black),
                                           backgroundColor: selectedItem==1?Theme.of(context).primaryColor:Color(
                                               0xfff4f7fc),
                                           //backgroundColor: selectedItem==1?Theme.of(context).primaryColor:Theme.of(context).primaryColor.withOpacity(.4),
                                           onTap: () {
                                             selectedItem=1;
                                             setState(() {

                                             });
                                           }
                                       )*/
                                   ),
                                 ],
                               ),
                             ):Container(),

                             Container(
                               height: productProvider.addOnQtyList.length>0?(ResponsiveHelper.isDesktop(context)?220:MediaQuery.of(context).size.height/4):80,
                               child: SingleChildScrollView(
                                 child: selectedItem==0? _addonsView(context, productProvider):_allergiesView(context, productProvider),
                                /* Column(
                                   children: [
                                     //allergies
                                     _allergiesView(context, productProvider),
                                     // Addons
                                     _addonsView(context, productProvider),
                                   ],
                                 ),*/
                               ),
                             ),

                             /* Row(children: [
                                Text('${getTranslated('total_amount', context)}:', style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                Text(PriceConverter.convertPrice(context, priceWithAddons),
                                    style: rubikBold.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.FONT_SIZE_LARGE,
                                    )),
                              ]),
                              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),*/
                              //Add to cart Button
                             if(ResponsiveHelper.isDesktop(context)) _cartButton(_isAvailable, context, _cartModel,priceWithAddons),
                            ]),
                          ),
                        ),

                        if(!ResponsiveHelper.isDesktop(context)) _cartButton(_isAvailable, context, _cartModel,priceWithAddons),
                      ],
                    ),
                  );
                },
              ),
            ),
            ResponsiveHelper.isMobile(context)
                ? SizedBox()
                : Positioned(
              right: 10,
              top: 5,
              child: InkWell(onTap: () => Navigator.pop(context), child: Icon(Icons.close)),
            ),
          ],
        );
      }
    );
  }

  Container multiselectItem (){
    return Container(
      child: MultiSelectDialogField(
        items: _items,
        title: Text("Allergies"),
        selectedColor: Colors.blue,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.all(Radius.circular(40)),
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
        ),
        buttonIcon: Icon(
          Icons.pets,
          color: Colors.blue,
        ),
        buttonText: Text(
          "Select Allergies Item",
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 16,
          ),
        ),
        onConfirm: (results) {
          //_selectedAnimals = results;
        },
      ),
    );
  }

 Container multiselectItem1 (){
    return  Container(
      decoration: BoxDecoration(
        //color: Theme.of(context).primaryColor.withOpacity(.4),
        /*border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),*/
      ),
      child: Column(
        children: <Widget>[
          MultiSelectBottomSheetField(
            initialChildSize: 0.4,
            listType: MultiSelectListType.LIST,
            searchable: true,
            buttonText: Text("Allergies",style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
            title: Text("Select Allergies Item",style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
            items: _items,
            searchHint: 'Search Allergies Item ',
            onConfirm: (values) {
              _selectedAllergiesItem = values;
            },
            chipDisplay: MultiSelectChipDisplay(
              onTap: (value) {
                setState(() {
                  _selectedAllergiesItem.remove(value);
                });
              },
            ),
          ),
          _selectedAllergiesItem == null || _selectedAllergiesItem.isEmpty
              ? Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: Text(
                "None selected",
                style: TextStyle(color: Colors.black54),
              ))
              : Container(),
        ],
      ),
    );
  }

  Container multiselectItem3 (){
    return  Container(
      child:  MultiSelectBottomSheetField<Allergies>(
        key: _multiSelectKey,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        title: Text("Animals"),
        buttonText: Text("Favorite Animals"),
        items: _items,
        searchable: true,
        validator: (values) {
          if (values == null || values.isEmpty) {
            return "Required";
          }
          List<String> names = values.map((e) => e.name).toList();
          if (names.contains("Frog")) {
            return "Frogs are weird!";
          }
          return null;
        },
        onConfirm: (values) {
          setState(() {
            _selectedAnimals3 = values;
          });
          _multiSelectKey.currentState.validate();
        },
        chipDisplay: MultiSelectChipDisplay(
          onTap: (item) {
            setState(() {
              _selectedAnimals3.remove(item);
            });
            _multiSelectKey.currentState.validate();
          },
        ),
      ),
    );
  }




  Widget _addonsView(BuildContext context, ProductProvider productProvider) {
    return widget.product.addOns.length > 0 ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      //Text(getTranslated('addons', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
      widget.product.addOns.length>0?GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 20,
          mainAxisSpacing: 10,
          childAspectRatio: (1 / 1.1),
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.product.addOns.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              if (!productProvider.addOnActiveList[index]) {
                productProvider.addAddOn(true, index);
              } else if (productProvider.addOnQtyList[index] == 1) {
                productProvider.addAddOn(false, index);
              }
            },

            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: productProvider.addOnActiveList[index] ? 2 : 10),
              decoration: BoxDecoration(
                color: productProvider.addOnActiveList[index]
                    ? Theme.of(context).primaryColor
                    : ColorResources.BACKGROUND_COLOR,
                borderRadius: BorderRadius.circular(5),
                boxShadow: productProvider.addOnActiveList[index]
                    ? [BoxShadow(
                  color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 300],
                  blurRadius:Provider.of<ThemeProvider>(context).darkTheme ? 2 : 5,
                  spreadRadius: Provider.of<ThemeProvider>(context).darkTheme ? 0 : 1,
                )]
                    : null,
              ),
              child: Column(children: [
                Expanded(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(widget.product.addOns[index].name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: rubikMedium.copyWith(
                            color: productProvider.addOnActiveList[index]
                                ? ColorResources.COLOR_WHITE
                                : ColorResources.COLOR_BLACK,
                            fontSize: Dimensions.FONT_SIZE_SMALL,
                          )),
                      SizedBox(height: 5),
                      Text(
                        PriceConverter.convertPrice(context, widget.product.addOns[index].price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: rubikRegular.copyWith(
                            color: productProvider.addOnActiveList[index]
                                ? ColorResources.COLOR_WHITE
                                : ColorResources.COLOR_BLACK,
                            fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL),
                      ),
                    ])),
                productProvider.addOnActiveList[index] ? Container(
                  height: 25,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(5), color: Theme.of(context).cardColor),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (productProvider.addOnQtyList[index] > 1) {
                            productProvider.setAddOnQuantity(false, index);
                          } else {
                            productProvider.addAddOn(false, index);
                          }
                        },
                        child: Center(child: Icon(Icons.remove, size: 15)),
                      ),
                    ),
                    Text(productProvider.addOnQtyList[index].toString(),
                        style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL)),
                    Expanded(
                      child: InkWell(
                        onTap: () => productProvider.setAddOnQuantity(true, index),
                        child: Center(child: Icon(Icons.add, size: 15)),
                      ),
                    ),
                  ]),
                )
                    : SizedBox(),
              ]),
            ),
          );
        },
      ):Text("No Addons Available for this Product"),
      //SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
    ]) : SizedBox();
  }

  Widget _allergiesView(BuildContext context, ProductProvider productProvider) {
    return widget.product.allergies.length > 0 ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
     // Text(getTranslated('allergies', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
      widget.product.allergies.length>0?GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 20,
          mainAxisSpacing: 10,
          childAspectRatio: (2 / 1),
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.product.allergies.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              if (!productProvider.allergiesActiveList[index]) {
                productProvider.addAllergies(true, index);
              } else if (productProvider.allergiesQtyList[index] == 1) {
                productProvider.addAllergies(false, index);
              }
            },

            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: productProvider.allergiesActiveList[index]
                    ? Theme.of(context).primaryColor
                    : ColorResources.BACKGROUND_COLOR,
                borderRadius: BorderRadius.circular(5),
                boxShadow: productProvider.allergiesActiveList[index]
                    ? [BoxShadow(
                  color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 300],
                  blurRadius:Provider.of<ThemeProvider>(context).darkTheme ? 2 : 5,
                  spreadRadius: Provider.of<ThemeProvider>(context).darkTheme ? 0 : 1,
                )]
                    : null,
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.product.allergies[index].name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: rubikMedium.copyWith(
                    color: productProvider.allergiesActiveList[index]
                        ? ColorResources.COLOR_WHITE
                        : ColorResources.COLOR_BLACK,
                    fontSize: Dimensions.FONT_SIZE_SMALL,
                  )),
              SizedBox(height: 5),
            ])
            ),
          );
        },
      ):Text("No Allergies Available for this Product"),
     // SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
    ]) : SizedBox();
  }

  Widget _quantityView(
      BuildContext context,
      CartModel _cartModel,
      ) {
    return Row(children: [
      Text(getTranslated('quantity', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
      Expanded(child: SizedBox()),
      _quantityButton(context, _cartModel),
    ]);
  }

  Widget _variationView(ProductProvider productProvider, String variationType) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.product.choiceOptions.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.product.choiceOptions[index].title, style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 5,
              childAspectRatio: (1 / 0.18),
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.product.choiceOptions[index].options.length,
            itemBuilder: (context, i) {
              return InkWell(
                onTap: () {
                  productProvider.setCartVariationIndex(index, i, widget.product, variationType, context, );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  decoration: BoxDecoration(
                    color: productProvider.variationIndex[index] != i
                        ? ColorResources.BACKGROUND_COLOR
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    widget.product.choiceOptions[index].options[i].trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: rubikRegular.copyWith(
                      color: productProvider.variationIndex[index] != i
                          ? ColorResources.COLOR_BLACK
                          : ColorResources.COLOR_WHITE,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: index != widget.product.choiceOptions.length - 1 ? Dimensions.PADDING_SIZE_LARGE : 0),
        ]);
      },
    );
  }

  Widget _description(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(getTranslated('description', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

      Align(
        alignment: Alignment.topLeft,
        child: ReadMoreText(widget.product.description ?? '',
          trimLines: 2,
          trimCollapsedText: getTranslated('show_more', context),
          trimExpandedText: getTranslated('show_less', context),
          moreStyle: robotoRegular.copyWith(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
          ),
          lessStyle: robotoRegular.copyWith(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
          ),
        ),
      ),
      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
    ]);
  }

  Widget _cartButton(bool _isAvailable, BuildContext context, CartModel _cartModel,priceWithAddons) {
    return Column(children: [
      Row(children: [
        Text('${getTranslated('total_amount', context)}:', style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
        SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        Text(PriceConverter.convertPrice(context, priceWithAddons),
            style: rubikBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.FONT_SIZE_LARGE,
            )),
      ]),
      _isAvailable ? SizedBox() :
      Container(
        alignment: Alignment.center,
       // padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        margin: EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        child: Column(children: [
          Text(getTranslated('not_available_now', context),
              style: rubikMedium.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.FONT_SIZE_DEFAULT,
              )),
          Text(
            '${getTranslated('available_will_be', context)} ${DateConverter.convertTimeToTime(widget.product.availableTimeStarts, context)} '
                '- ${DateConverter.convertTimeToTime(widget.product.availableTimeEnds, context)}',
            style: rubikRegular,
          ),
        ]),
      ),

      Row(
        children: [
            Expanded(
              flex: 1,
                child:  Container(
                  height: ResponsiveHelper.isDesktop(context)?40:33,
                  child: CustomButton(
                  btnTxt: getTranslated(
                    _cartIndex != -1
                        ? 'update_in_cart'
                        : 'add_to_cart', context,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    Provider.of<CartProvider>(context, listen: false).addToCart(_cartModel,_cartIndex);
                  }
            ),
                )),
            SizedBox(width: 3,),
            Expanded(
                flex: 1,
                  child:  Container(
                    height: ResponsiveHelper.isDesktop(context)?40:33,
                    child: CustomButton(
                    btnTxt: 'Buy Now',
                    backgroundColor: Theme.of(context).primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      Provider.of<CartProvider>(context, listen: false).buyNow(_cartModel,_cartIndex,context,0);
                    }
              ),
                  )),
        ],
      ),
    ]);
  }

  Widget _productView(
      BuildContext context, double _startingPrice, double _endingPrice, double price,
      double priceWithDiscount,
      CartModel cartModel,
      ) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage.assetNetwork(
          placeholder: Images.placeholder_rectangle,
          image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${widget.product.image}',
          width: ResponsiveHelper.isMobile(context)
              ? 100
              : ResponsiveHelper.isTab(context)
              ? 120
              : ResponsiveHelper.isDesktop(context)
              ? 120
              : null,
          height: ResponsiveHelper.isMobile(context)
              ? 100
              : ResponsiveHelper.isTab(context)
              ? 120
              : ResponsiveHelper.isDesktop(context)
              ? 120
              : null,
          fit: BoxFit.cover,
          imageErrorBuilder: (c, o, s) => Image.asset(
            Images.placeholder_rectangle,
            width: ResponsiveHelper.isMobile(context)
                ? 100
                : ResponsiveHelper.isTab(context)
                ? 120
                : ResponsiveHelper.isDesktop(context)
                ? 140
                : null,
            height: ResponsiveHelper.isMobile(context)
                ? 100
                : ResponsiveHelper.isTab(context)
                ? 120
                : ResponsiveHelper.isDesktop(context)
                ? 120
                : null,
            fit: BoxFit.cover,
          ),
        ),
      ),
      SizedBox(
        width: 3,
      ),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                ),
              ),

             if(!ResponsiveHelper.isMobile(context)) WishButton(product: widget.product),



            ],
          ),
          SizedBox(height:3),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RatingBar(rating: widget.product.rating.length > 0 ? double.parse(widget.product.rating[0].average) : 0.0, size: 15),
              widget.product.productType != null ? VegTagView(product: widget.product) : SizedBox(),
            ],
          ),
          SizedBox(height: 5),

          Row( mainAxisSize: MainAxisSize.min, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,  children: [
                FittedBox(
                  child: Text(
                    '${PriceConverter.convertPrice(context, _startingPrice, discount: widget.product.discount, discountType: widget.product.discountType)}'
                        '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(
                    context, _endingPrice, discount: widget.product.discount, discountType: widget.product.discountType,
                    )}' : ''}',

                    style: rubikMedium.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                      overflow: TextOverflow.ellipsis,
                      color: Theme.of(context).primaryColor,
                    ),
                    maxLines: 1,
                  ),
                ),


                price > priceWithDiscount ? FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text('${PriceConverter.convertPrice(context, _startingPrice)}'
                        '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(context, _endingPrice)}' : ''}',
                      style: rubikMedium.copyWith(color: ColorResources.COLOR_GREY, decoration: TextDecoration.lineThrough, overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                  ),
                ) : SizedBox(),

              ]),
            ),
           if(ResponsiveHelper.isMobile(context)) WishButton(product: widget.product),

          ]),
          if(!ResponsiveHelper.isMobile(context)) _quantityView(context, cartModel)
        ]),
      ),
    ]);
  }

  Widget _quantityButton(BuildContext context, CartModel _cartModel) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).backgroundColor, borderRadius: BorderRadius.circular(5)),
      child: Row(children: [
        InkWell(
          onTap: () => productProvider.quantity > 1 ?  productProvider.setQuantity(false) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            child: Icon(Icons.remove, size: 20),
          ),
        ),
        Text(productProvider.quantity.toString(), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE)),

        InkWell(
          onTap: () => productProvider.setQuantity(true),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            child: Icon(Icons.add, size: 20),
          ),
        ),
      ]),
    );
  }
}

class VegTagView extends StatelessWidget {
  final Product product;
  const VegTagView({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [BoxShadow(blurRadius: 5, color: Theme.of(context).backgroundColor.withOpacity(0.05))],
      ),

      child: SizedBox(height:  30,
        child: Row(
          children: [
            Padding(
              padding:  EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
              child: Image.asset(
                Images.getImageUrl('${product.productType}',
                ), fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

            Text(
              getTranslated('${product.productType}', context),
              style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
            ),
            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          ],
        ),
      ),
    );
  }
}

