import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/category_model.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/category_provider.dart';
import 'package:flutter_restaurant/provider/coupon_provider.dart';
import 'package:flutter_restaurant/provider/localization_provider.dart';
import 'package:flutter_restaurant/provider/product_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/theme_provider.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_divider.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/filter_button_widget.dart';
import 'package:flutter_restaurant/view/base/no_data_screen.dart';
import 'package:flutter_restaurant/view/base/product_shimmer.dart';
import 'package:flutter_restaurant/view/base/product_widget.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/screens/cart/cart_screen.dart';
import 'package:flutter_restaurant/view/screens/cart/widget/delivery_option_button.dart';
import 'package:flutter_restaurant/view/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_restaurant/view/screens/home/home_screen.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/category_web_view.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/product_web_card_shimmer.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/product_widget_web.dart';
import 'package:flutter_restaurant/view/screens/home/widget/banner_view.dart';
import 'package:flutter_restaurant/view/screens/home/widget/category_view.dart';
import 'package:flutter_restaurant/view/screens/order/order_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../provider/order_provider.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryModel categoryModel;
  CategoryScreen({@required this.categoryModel});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with TickerProviderStateMixin {
  int _tabIndex = 0;
  CategoryModel _categoryModel;
  String _type = 'all';
  final TextEditingController _couponController = TextEditingController();
  int _pageIndex = 0;
  bool _isLoggedIn;
  PageController _pageController;
 @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 6);
    _loadData();
  }

  void _loadData() async {
    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    _categoryModel = widget.categoryModel;
    Provider.of<CategoryProvider>(context, listen: false).getCategoryList(context,false,Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,);
    Provider.of<CategoryProvider>(context, listen: false).getSubCategoryList(context, _categoryModel.id.toString(),Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,);
      }

  @override
  Widget build(BuildContext context) {
   final double _height = MediaQuery.of(context).size.height;
   final double xyz = MediaQuery.of(context).size.width-1170;
   final double realSpaceNeeded =xyz/2;
   final double pageWidth = MediaQuery.of(context).size.width;

   //Scaffold.of(context).openEndDrawer();
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(100)) : null,
      body: Consumer<CategoryProvider>(
        builder: (context, category, child) {
          return category.isLoading || category.categoryList == null ?
          categoryShimmer(context, _height, category) :
          Row(
            children: [
              Container(
                height: _height,
                width: ResponsiveHelper.isDesktop(context)?pageWidth*.75:pageWidth,
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: [

                    // AppBar
                    ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(child: SizedBox()) : SliverAppBar(
                      floating: true,
                      elevation: 0,
                      centerTitle: false,
                      automaticallyImplyLeading: false,
                      backgroundColor: Theme.of(context).cardColor,
                      pinned: true,//ResponsiveHelper.isTab(context) ? true : false,
                      title: Consumer<SplashProvider>(builder:(context, splash, child) => Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ResponsiveHelper.isWeb() ? InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen(pageIndex: 0,)));
                            },
                            child: FadeInImage.assetNetwork(
                              placeholder: Images.placeholder_rectangle, height: 40, width: 40,
                              image: splash.baseUrls != null ? '${splash.baseUrls.restaurantImageUrl}/${splash.configModel.restaurantLogo}' : '',
                              imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder_rectangle, height: 40, width: 40),
                            ),
                          ) : InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen(pageIndex: 0,)));
                            },
                              child: Image.asset(Images.logo, width: 40, height: 40)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ResponsiveHelper.isWeb() ? splash.configModel.restaurantName : AppConstants.APP_NAME,
                              style: rubikBold.copyWith(color: Theme.of(context).primaryColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )),
                      actions: [
                        Provider.of<AuthProvider>(context, listen: false).isLoggedIn()?Container():InkWell(
                          onTap: (){
                            Navigator.pushReplacementNamed(context, Routes.getSignUpRoute());
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 20,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.all(Radius.circular(3))
                            ),
                            margin: const EdgeInsets.only(top:15,right: 10,bottom: 15),
                            padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ),
                        Provider.of<AuthProvider>(context, listen: false).isLoggedIn()?Container():InkWell(
                          onTap: (){
                            Navigator.pushReplacementNamed(context, Routes.getLoginRoute());
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 20,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.all(Radius.circular(3))
                            ),
                            margin: const EdgeInsets.only(top:15,right: 10,bottom: 15),
                            padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pushNamed(context, Routes.getNotificationRoute()),
                          icon: Icon(Icons.notifications, color: Colors.red),
                        ),
                        ResponsiveHelper.isTab(context) ? IconButton(
                          onPressed: () => Navigator.pushNamed(context, Routes.getDashboardRoute('cart')),
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(Icons.shopping_cart, color:  Colors.red),
                              Positioned(
                                top: -10, right: -10,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                  child: Center(
                                    child: Text(
                                      Provider.of<CartProvider>(context).cartList.length.toString(),
                                      style: rubikMedium.copyWith(color: Colors.white, fontSize: 8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) : SizedBox(),
                      ],
                    ),

                    // Search Button
                    if(!ResponsiveHelper.isDesktop(context))  SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverDelegate(child: Center(
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, Routes.getSearchRoute()),
                          child: Container(
                            height: 60, width: 1170,
                            color: Theme.of(context).cardColor,
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: 5),
                            child: Container(
                              decoration: BoxDecoration(color: ColorResources.getSearchBg(context), borderRadius: BorderRadius.circular(10)),
                              child: Row(children: [
                                Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL), child: Icon(Icons.search, size: 25)),
                                Expanded(child: Text(getTranslated('search_items_here', context), style: rubikRegular.copyWith(fontSize: 12))),
                              ]),
                            ),
                          ),
                        ),
                      )),
                    ),

                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if( ResponsiveHelper.isDesktop(context))Container(
                            width: 1160,
                            margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL,left: Dimensions.PADDING_SIZE_SMALL),
                            decoration: BoxDecoration(
                              boxShadow: [BoxShadow(
                                color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 300],
                                blurRadius:Provider.of<ThemeProvider>(context).darkTheme ? 2 : 5,
                                spreadRadius: Provider.of<ThemeProvider>(context).darkTheme ? 0 : 1,
                              )],
                              color: ColorResources.COLOR_WHITE,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FadeInImage.assetNetwork(
                                placeholder: Images.placeholder_banner, width: 1160, height: 300, fit: BoxFit.cover,
                                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.categoryBannerImageUrl}/${_categoryModel.bannerImage.isNotEmpty ? _categoryModel.bannerImage : ''}',
                                imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder_banner, width: 1160, height: 300, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          ResponsiveHelper.isDesktop(context)? Container(padding:EdgeInsets.symmetric(horizontal: 50),child: CategoryViewWeb()) : CategoryView(),
                          FilterButtonWidget(
                            type: _type,
                            items: Provider.of<ProductProvider>(context).productTypeList,
                            onSelected: (selected) {
                              _type = selected;
                             category.getCategoryProductList(
                               context, category.selectedSubCategoryId,
                               Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                               type: _type,
                             );
                            },
                          ),
                          ConstrainedBox(
                            constraints: new BoxConstraints(
                              minHeight: _height < 600 ?  _height : _height - 600,
                            ),
                            child: SizedBox(
                              width: 1170,
                              child: category.categoryProductList != null ? category.categoryProductList.length > 0 ?
                              GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 13,
                                    mainAxisSpacing: 13,
                                    childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.7 : 4,
                                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 2 : 1),
                                itemCount: category.categoryProductList.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                itemBuilder: (context, index) {
                                  return ResponsiveHelper.isDesktop(context) ? ProductWidgetWeb(product: category.categoryProductList[index]): ProductWidget(product: category.categoryProductList[index]);
                                },
                              ) : NoDataScreen(isFooter: false) :
                              GridView.builder(
                                shrinkWrap: true,
                                itemCount: 10,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.7: 4,
                                  crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 2 : 1,
                                ),
                                itemBuilder: (context, index) {
                                  return ResponsiveHelper.isDesktop(context)? ProductWidgetWebShimmer ():ProductShimmer(isEnabled: category.categoryProductList == null);
                                },
                              ),
                            ),
                          ),
                          if(ResponsiveHelper.isDesktop(context)) FooterViewForMenu(),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                height: _height,
                width: ResponsiveHelper.isDesktop(context)?pageWidth*.25:0,
                child: Consumer<OrderProvider>(
                    builder: (context, order, child) {
                      String appliedCoupon = Provider.of<CouponProvider>(context).getCoupon();
                      if(appliedCoupon.isNotEmpty){
                        _couponController.text = appliedCoupon;
                      }
                      return Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          double deliveryCharge = 0;
                          (Provider.of<OrderProvider>(context, listen: false).orderType == 'delivery'
                              && Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.status == 0)
                              ? deliveryCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryCharge : deliveryCharge = 0;
                          List<List<AddOns>> _addOnsList = [];
                          List<List<Allergies>> _allergiesList = [];
                          List<bool> _availableList = [];
                          double _itemPrice = 0;
                          double _discount = 0;
                          double _tax = 0;
                          double _addOns = 0;

                          double totalQuantity = 0;

                          cart.cartList.forEach((cartModel) {

                            totalQuantity += cartModel.quantity;

                            List<AddOns> _addOnList = [];
                            cartModel.addOnIds.forEach((addOnId) {
                              for(AddOns addOns in cartModel.product.addOns) {
                                if(addOns.id == addOnId.id) {
                                  _addOnList.add(addOns);
                                  break;
                                }
                              }
                            });
                            _addOnsList.add(_addOnList);


                            List<Allergies> _allergieList = [];
                            cartModel.allergIds.forEach((addOnId) {
                              for(Allergies addOns in cartModel.product.allergies) {
                                if(addOns.id == addOnId.id) {
                                  _allergieList.add(addOns);
                                  break;
                                }
                              }
                            });
                            _allergiesList.add(_allergieList);

                            _availableList.add(DateConverter.isAvailable(cartModel.product.availableTimeStarts, cartModel.product.availableTimeEnds, context));

                            for(int index=0; index<_addOnList.length; index++) {
                              _addOns = _addOns + (_addOnList[index].price * cartModel.addOnIds[index].quantity);
                            }
                            _itemPrice = _itemPrice + (cartModel.price * cartModel.quantity);
                            _discount = _discount + (cartModel.discountAmount * cartModel.quantity);
                            _tax = _tax + (cartModel.taxAmount * cartModel.quantity);
                          });
                          double _subTotal = _itemPrice + _tax + _addOns;
                          double _total = _subTotal - _discount - Provider.of<CouponProvider>(context).discount + deliveryCharge;
                          double _totalWithoutDeliveryFee = _subTotal - _discount - Provider.of<CouponProvider>(context).discount;

                          double _orderAmount = _itemPrice + _addOns;

                          bool _kmWiseCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.status == 1;

                          return cart.cartList.length > 0 ? Column(
                            children: [

                              Expanded(
                                child: Scrollbar(
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                          child: Center(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
                                              child: SizedBox(
                                                width: 1170,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Expanded(
                                                      child: Container(
                                                        decoration:ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                                            color: Theme.of(context).cardColor,
                                                            borderRadius: BorderRadius.circular(10),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color:ColorResources.CARD_SHADOW_COLOR.withOpacity(0.2),
                                                                blurRadius: 10,
                                                              )
                                                            ]
                                                        ) : BoxDecoration(),
                                                      //  margin: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
                                                        padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
                                                        child: Column(
                                                            //crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets.all(5),
                                                                child: Text(
                                                                  " Your Cart ",
                                                                textAlign: TextAlign.center,
                                                                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                                                                ),
                                                              ),
                                                          // Product
                                                            CartListMenuWidget(cart: cart,addOns: _addOnsList, availableList: _availableList,allergies: _allergiesList,),

                                                          // Coupon
                                                          Consumer<CouponProvider>(
                                                            builder: (context, coupon, child) {
                                                              return Row(children: [
                                                                Expanded(
                                                                  child: TextField(
                                                                    controller: _couponController,
                                                                    style: rubikRegular,
                                                                    decoration: InputDecoration(
                                                                      hintText: getTranslated('enter_promo_code', context),
                                                                      hintStyle: rubikRegular.copyWith(color: ColorResources.getHintColor(context)),
                                                                      isDense: true,
                                                                      filled: true,
                                                                      enabled: coupon.discount == 0,
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
                                                                    if(_isLoggedIn){
                                                                      if(_couponController.text.isNotEmpty && !coupon.isLoading) {
                                                                        if(coupon.discount < 1) {
                                                                          coupon.applyCoupon(_couponController.text, _total).then((discount) {
                                                                            if (discount > 0) {
                                                                              showCustomSnackBar('You got ${PriceConverter.convertPrice(context, discount)} discount', context, isError: false);
                                                                            } else {
                                                                              showCustomSnackBar(getTranslated('invalid_code_or', context), context, isError: true);
                                                                            }
                                                                          });
                                                                        } else {
                                                                          coupon.removeCouponData(true);
                                                                        }
                                                                      } else if(_couponController.text.isEmpty) {
                                                                        showCustomSnackBar(getTranslated('enter_a_Coupon_code', context), context);
                                                                      }
                                                                    }else{
                                                                      showCustomSnackBar("To Use Promo Code Please Login first", context);
                                                                    }
                                                                   /* if(_couponController.text.isNotEmpty && !coupon.isLoading) {
                                                                      if(coupon.discount < 1) {
                                                                        coupon.applyCoupon(_couponController.text, _total).then((discount) {
                                                                          if (discount > 0) {
                                                                            showCustomSnackBar('You got ${PriceConverter.convertPrice(context, discount)} discount', context, isError: false);
                                                                          } else {
                                                                            showCustomSnackBar(getTranslated('invalid_code_or', context), context, isError: true);
                                                                          }
                                                                        });
                                                                      } else {
                                                                        coupon.removeCouponData(true);
                                                                      }
                                                                    } else if(_couponController.text.isEmpty) {
                                                                      showCustomSnackBar(getTranslated('enter_a_Coupon_code', context), context);
                                                                    }*/
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
                                                                    child: coupon.discount <= 0 ? !coupon.isLoading ? Text(
                                                                      getTranslated('apply', context),
                                                                      style: rubikMedium.copyWith(color: Colors.white),
                                                                    ) : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Icon(Icons.clear, color: Colors.white),
                                                                  ),
                                                                ),
                                                              ]);
                                                            },
                                                          ),
                                                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                                                          // Order type
                                                          Text(getTranslated('delivery_option', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                          Provider.of<SplashProvider>(context, listen: false).configModel.homeDelivery?
                                                          DeliveryOptionButton(value: 'delivery', title: getTranslated('delivery', context), kmWiseFee: _kmWiseCharge):
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL,top: Dimensions.PADDING_SIZE_LARGE),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.remove_circle_outline_sharp,color: Theme.of(context).hintColor,),
                                                                SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                                                                Text(getTranslated('home_delivery_not_available', context),style: TextStyle(fontSize: Dimensions.FONT_SIZE_DEFAULT,color: Theme.of(context).primaryColor)),
                                                              ],
                                                            ),
                                                          ),
                                                          Provider.of<SplashProvider>(context, listen: false).configModel.selfPickup?
                                                          DeliveryOptionButton(value: 'take_away', title: getTranslated('take_away', context), kmWiseFee: _kmWiseCharge):
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL,bottom: Dimensions.PADDING_SIZE_LARGE),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.remove_circle_outline_sharp,color: Theme.of(context).hintColor,),
                                                                SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                                                                Text(getTranslated('self_pickup_not_available', context),style: TextStyle(fontSize: Dimensions.FONT_SIZE_DEFAULT,color: Theme.of(context).primaryColor)),
                                                              ],
                                                            ),
                                                          ),


                                                          // Total
                                                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                            Text(getTranslated('items_price', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                            Text(PriceConverter.convertPrice(context, _itemPrice), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                          ]),
                                                          SizedBox(height: 10),

                                                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                            Text(getTranslated('tax', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                            Text('(+) ${PriceConverter.convertPrice(context, _tax)}', style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                          ]),
                                                          SizedBox(height: 10),

                                                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                            Text(getTranslated('addons', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                            Text('(+) ${PriceConverter.convertPrice(context, _addOns)}', style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                          ]),
                                                          SizedBox(height: 10),

                                                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                            Text(getTranslated('discount', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                            Text('(-) ${PriceConverter.convertPrice(context, _discount)}', style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                          ]),
                                                          SizedBox(height: 10),

                                                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                            Text(getTranslated('coupon_discount', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                            Text(
                                                              '(-) ${PriceConverter.convertPrice(context, Provider.of<CouponProvider>(context).discount)}',
                                                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                                                            ),
                                                          ]),
                                                          SizedBox(height: 10),

                                                          _kmWiseCharge ? SizedBox() : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                            Text(
                                                              getTranslated('delivery_fee', context),
                                                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                                                            ),
                                                            Text(
                                                              '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
                                                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                                                            ),
                                                          ]),

                                                          Padding(
                                                            padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                                                            child: CustomDivider(),
                                                          ),

                                                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                            Text(getTranslated(_kmWiseCharge ? 'subtotal' : 'total_amount', context), style: rubikMedium.copyWith(
                                                              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor,
                                                            )),
                                                            Text(
                                                              PriceConverter.convertPrice(context, _total),
                                                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor),
                                                            ),
                                                          ]),
                                                          if(ResponsiveHelper.isDesktop(context)) SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                                                          if(ResponsiveHelper.isDesktop(context)) Container(
                                                            width: 1170,
                                                            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                                            child: CustomButton(btnTxt: getTranslated('continue_checkout', context), onTap: () {
                                                              if(totalQuantity % 1 != 0.00) {
                                                                showCustomSnackBar('Please complete the Half/Half order.', context);
                                                              }
                                                              else if(_orderAmount < Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue) {
                                                                showCustomSnackBar('Minimum order amount is ${PriceConverter.convertPrice(context, Provider.of<SplashProvider>(context, listen: false).configModel
                                                                    .minimumOrderValue)}, you have ${PriceConverter.convertPrice(context, _orderAmount)} in your cart, please add more item.', context);
                                                              } else {
                                                                Navigator.pushNamed(context, Routes.getCheckoutRoute(
                                                                  _totalWithoutDeliveryFee, 'cart', Provider.of<OrderProvider>(context, listen: false).orderType,
                                                                  Provider.of<CouponProvider>(context, listen: false).code,
                                                                ));
                                                              }
                                                            }),
                                                          ),

                                                        ]),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        //if(ResponsiveHelper.isDesktop(context))  FooterView(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              if(!ResponsiveHelper.isDesktop(context)) Container(
                                width: 1170,
                                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                child: CustomButton(btnTxt: getTranslated('continue_checkout', context), onTap: () {
                                  if(totalQuantity % 1 != 0.00) {
                                    showCustomSnackBar('Please complete the Half/Half order.', context);
                                  }
                                  else if(_orderAmount < Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue) {
                                    showCustomSnackBar('Minimum order amount is ${PriceConverter.convertPrice(context, Provider.of<SplashProvider>(context, listen: false).configModel
                                        .minimumOrderValue)}, you have ${PriceConverter.convertPrice(context, _orderAmount)} in your cart, please add more item.', context);
                                  } else {
                                    Navigator.pushNamed(context, Routes.getCheckoutRoute(
                                      _totalWithoutDeliveryFee, 'cart', Provider.of<OrderProvider>(context, listen: false).orderType,
                                      Provider.of<CouponProvider>(context, listen: false).code,
                                    ));
                                  }
                                }),
                              ),

                            ],
                          ) : NoDataMenuScreen(isCart: true);
                        },
                      );
                    }
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: ResponsiveHelper.isMobile(context) ? BottomNavigationBar(
        selectedItemColor: ColorResources.COLOR_GREY,
        unselectedItemColor: ColorResources.COLOR_GREY,
        showUnselectedLabels: true,
        //currentIndex: _pageIndex,
        type: BottomNavigationBarType.fixed,

        items: [
          _barItem(Icons.home, getTranslated('home', context), 0),
          _barItem(Icons.shopping_cart, getTranslated('cart', context), 1),
          _barItem(Icons.shopping_bag, getTranslated('order', context), 2),
          _barItem(Icons.favorite, getTranslated('favourite', context), 3),
          _barItem(Icons.person, getTranslated('account', context), 4)
        ],
        onTap: (int index) {
          _setPage(index);
        },
      ) : SizedBox(),
      //endDrawerEnableOpenDragGesture: false,
      drawerEnableOpenDragGesture: true,
      //if(ResponsiveHelper.isDesktop(context)) ()
    /*  endDrawer: !ResponsiveHelper.isDesktop(context)?Drawer(
        child: Consumer<OrderProvider>(
            builder: (context, order, child) {
              return Consumer<CartProvider>(
                builder: (context, cart, child) {
                  double deliveryCharge = 0;
                  (Provider.of<OrderProvider>(context, listen: false).orderType == 'delivery'
                      && Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.status == 0)
                      ? deliveryCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryCharge : deliveryCharge = 0;
                  List<List<AddOns>> _addOnsList = [];
                  List<List<Allergies>> _allergiesList = [];
                  List<bool> _availableList = [];
                  double _itemPrice = 0;
                  double _discount = 0;
                  double _tax = 0;
                  double _addOns = 0;
                  cart.cartList.forEach((cartModel) {

                    List<AddOns> _addOnList = [];
                    cartModel.addOnIds.forEach((addOnId) {
                      for(AddOns addOns in cartModel.product.addOns) {
                        if(addOns.id == addOnId.id) {
                          _addOnList.add(addOns);
                          break;
                        }
                      }
                    });
                    _addOnsList.add(_addOnList);

                    List<Allergies> _allergieList = [];
                    cartModel.allergIds.forEach((addOnId) {
                      for(Allergies addOns in cartModel.product.allergies) {
                        if(addOns.id == addOnId.id) {
                          _allergieList.add(addOns);
                          break;
                        }
                      }
                    });
                    _allergiesList.add(_allergieList);

                    _availableList.add(DateConverter.isAvailable(cartModel.product.availableTimeStarts, cartModel.product.availableTimeEnds, context));

                    for(int index=0; index<_addOnList.length; index++) {
                      _addOns = _addOns + (_addOnList[index].price * cartModel.addOnIds[index].quantity);
                    }
                    _itemPrice = _itemPrice + (cartModel.price * cartModel.quantity);
                    _discount = _discount + (cartModel.discountAmount * cartModel.quantity);
                    _tax = _tax + (cartModel.taxAmount * cartModel.quantity);
                  });
                  double _subTotal = _itemPrice + _tax + _addOns;
                  double _total = _subTotal - _discount - Provider.of<CouponProvider>(context).discount + deliveryCharge;
                  double _totalWithoutDeliveryFee = _subTotal - _discount - Provider.of<CouponProvider>(context).discount;

                  double _orderAmount = _itemPrice + _addOns;

                  bool _kmWiseCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.status == 1;

                  return cart.cartList.length > 0 ? Column(
                    children: [

                      Expanded(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
                                      child: SizedBox(
                                        width: 1170,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Expanded(
                                              child: Container(
                                                decoration:ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                                    color: Theme.of(context).cardColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:ColorResources.CARD_SHADOW_COLOR.withOpacity(0.2),
                                                        blurRadius: 10,
                                                      )
                                                    ]
                                                ) : BoxDecoration(),
                                                margin: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
                                                padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
                                                child: Column(
                                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [

                                                      // Product
                                                      CartListMenuWidget(cart: cart,addOns: _addOnsList, availableList: _availableList,allergies: _allergiesList,),

                                                      // Coupon
                                                      Consumer<CouponProvider>(
                                                        builder: (context, coupon, child) {
                                                          return Row(children: [
                                                            Expanded(
                                                              child: TextField(
                                                                controller: _couponController,
                                                                style: rubikRegular,
                                                                decoration: InputDecoration(
                                                                  hintText: getTranslated('enter_promo_code', context),
                                                                  hintStyle: rubikRegular.copyWith(color: ColorResources.getHintColor(context)),
                                                                  isDense: true,
                                                                  filled: true,
                                                                  enabled: coupon.discount == 0,
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
                                                                if(_couponController.text.isNotEmpty && !coupon.isLoading) {
                                                                  if(coupon.discount < 1) {
                                                                    coupon.applyCoupon(_couponController.text, _total).then((discount) {
                                                                      if (discount > 0) {
                                                                        showCustomSnackBar('You got ${PriceConverter.convertPrice(context, discount)} discount', context, isError: false);
                                                                      } else {
                                                                        showCustomSnackBar(getTranslated('invalid_code_or', context), context, isError: true);
                                                                      }
                                                                    });
                                                                  } else {
                                                                    coupon.removeCouponData(true);
                                                                  }
                                                                } else if(_couponController.text.isEmpty) {
                                                                  showCustomSnackBar(getTranslated('enter_a_Coupon_code', context), context);
                                                                }
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
                                                                child: coupon.discount <= 0 ? !coupon.isLoading ? Text(
                                                                  getTranslated('apply', context),
                                                                  style: rubikMedium.copyWith(color: Colors.white),
                                                                ) : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Icon(Icons.clear, color: Colors.white),
                                                              ),
                                                            ),
                                                          ]);
                                                        },
                                                      ),
                                                      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                                                      // Order type
                                                      Text(getTranslated('delivery_option', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                      Provider.of<SplashProvider>(context, listen: false).configModel.homeDelivery?
                                                      DeliveryOptionButton(value: 'delivery', title: getTranslated('delivery', context), kmWiseFee: _kmWiseCharge):
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL,top: Dimensions.PADDING_SIZE_LARGE),
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.remove_circle_outline_sharp,color: Theme.of(context).hintColor,),
                                                            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                                                            Text(getTranslated('home_delivery_not_available', context),style: TextStyle(fontSize: Dimensions.FONT_SIZE_DEFAULT,color: Theme.of(context).primaryColor)),
                                                          ],
                                                        ),
                                                      ),
                                                      Provider.of<SplashProvider>(context, listen: false).configModel.selfPickup?
                                                      DeliveryOptionButton(value: 'take_away', title: getTranslated('take_away', context), kmWiseFee: _kmWiseCharge):
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL,bottom: Dimensions.PADDING_SIZE_LARGE),
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.remove_circle_outline_sharp,color: Theme.of(context).hintColor,),
                                                            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                                                            Text(getTranslated('self_pickup_not_available', context),style: TextStyle(fontSize: Dimensions.FONT_SIZE_DEFAULT,color: Theme.of(context).primaryColor)),
                                                          ],
                                                        ),
                                                      ),


                                                      // Total
                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Text(getTranslated('items_price', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                        Text(PriceConverter.convertPrice(context, _itemPrice), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                      ]),
                                                      SizedBox(height: 10),

                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Text(getTranslated('tax', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                        Text('(+) ${PriceConverter.convertPrice(context, _tax)}', style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                      ]),
                                                      SizedBox(height: 10),

                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Text(getTranslated('addons', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                        Text('(+) ${PriceConverter.convertPrice(context, _addOns)}', style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                      ]),
                                                      SizedBox(height: 10),

                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Text(getTranslated('discount', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                        Text('(-) ${PriceConverter.convertPrice(context, _discount)}', style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                      ]),
                                                      SizedBox(height: 10),

                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Text(getTranslated('coupon_discount', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                        Text(
                                                          '(-) ${PriceConverter.convertPrice(context, Provider.of<CouponProvider>(context).discount)}',
                                                          style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                                                        ),
                                                      ]),
                                                      SizedBox(height: 10),

                                                      _kmWiseCharge ? SizedBox() : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Text(
                                                          getTranslated('delivery_fee', context),
                                                          style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                                                        ),
                                                        Text(
                                                          '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
                                                          style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                                                        ),
                                                      ]),

                                                      Padding(
                                                        padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                                                        child: CustomDivider(),
                                                      ),

                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Text(getTranslated(_kmWiseCharge ? 'subtotal' : 'total_amount', context), style: rubikMedium.copyWith(
                                                          fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor,
                                                        )),
                                                        Text(
                                                          PriceConverter.convertPrice(context, _total),
                                                          style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor),
                                                        ),
                                                      ]),
                                                      if(ResponsiveHelper.isDesktop(context)) SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                                                      if(ResponsiveHelper.isDesktop(context)) Container(
                                                        width: 1170,
                                                        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                                        child: CustomButton(btnTxt: getTranslated('continue_checkout', context), onTap: () {
                                                          if(_orderAmount < Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue) {
                                                            showCustomSnackBar('Minimum order amount is ${PriceConverter.convertPrice(context, Provider.of<SplashProvider>(context, listen: false).configModel
                                                                .minimumOrderValue)}, you have ${PriceConverter.convertPrice(context, _orderAmount)} in your cart, please add more item.', context);
                                                          } else {
                                                            Navigator.pushNamed(context, Routes.getCheckoutRoute(
                                                              _totalWithoutDeliveryFee, 'cart', Provider.of<OrderProvider>(context, listen: false).orderType,
                                                              Provider.of<CouponProvider>(context, listen: false).code,
                                                            ));
                                                          }
                                                        }),
                                                      ),

                                                    ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                               // if(ResponsiveHelper.isDesktop(context))  FooterView(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if(!ResponsiveHelper.isDesktop(context)) Container(
                        width: 1170,
                        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: CustomButton(btnTxt: getTranslated('continue_checkout', context), onTap: () {
                          if(_orderAmount < Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue) {
                            showCustomSnackBar('Minimum order amount is ${PriceConverter.convertPrice(context, Provider.of<SplashProvider>(context, listen: false).configModel
                                .minimumOrderValue)}, you have ${PriceConverter.convertPrice(context, _orderAmount)} in your cart, please add more item.', context);
                          } else {
                            Navigator.pushNamed(context, Routes.getCheckoutRoute(
                              _totalWithoutDeliveryFee, 'cart', Provider.of<OrderProvider>(context, listen: false).orderType,
                              Provider.of<CouponProvider>(context, listen: false).code,
                            ));
                          }
                        }),
                      ),

                    ],
                  ) : NoDataMenuScreen(isCart: true);
                },
              );
            }
        ),
      ):Container(),*/
    );

  }
  BottomNavigationBarItem _barItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      backgroundColor: Colors.grey,
      icon: Stack(
        clipBehavior: Clip.none, children: [
        Icon(icon, color: ColorResources.COLOR_GREY, size: 25),
        index == 1 ? Positioned(
          top: -7, right: -7,
          child: Container(
            padding: EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            child: Text(
              Provider.of<CartProvider>(context).cartList.length.toString(),
              style: rubikMedium.copyWith(color: ColorResources.COLOR_WHITE, fontSize: 8),
            ),
          ),
        ) : SizedBox(),
      ],
      ),
      label: label,
    );
  }
  void _setPage(int pageIndex) {
    setState(() {
      switch(pageIndex){
        case 0:
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen(pageIndex: 0,)));
          break;
        case 1:
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen(pageIndex: 1,)));
          break;
        case 2:
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen(pageIndex: 2,)));
          break;
        case 3:
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen(pageIndex: 3,)));
          break;
        case 4:
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen(pageIndex: 4,)));
          break;


      }
    });
  }

  SingleChildScrollView categoryShimmer(BuildContext context, double _height, CategoryProvider category) {
    return SingleChildScrollView(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
                child: Center(
                  child: SizedBox(
                    width: 1170,
                    child: Column(
                      children: [
                        Shimmer(
                            duration: Duration(seconds: 2),
                            enabled: true,
                            child: Container(height: 200,width: double.infinity,color: Colors.grey[300])),
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: 10,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.7: 4,
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 2 : 1,
                          ),
                          itemBuilder: (context, index) {
                            return ResponsiveHelper.isDesktop(context)? ProductWidgetWebShimmer ():ProductShimmer(isEnabled: category.categoryProductList == null);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if(ResponsiveHelper.isDesktop(context)) FooterView(),
            ],
          ),
        );
  }

  List<Tab> _tabs(CategoryProvider category) {
    List<Tab> tabList = [];
    tabList.add(Tab(text: ''));
    category.subCategoryList.forEach((subCategory) => tabList.add(Tab(text: subCategory.name)));
    return tabList;
  }
}
