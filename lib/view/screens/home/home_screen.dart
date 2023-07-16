
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/data/model/response/google_place_model.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/data/model/response/timeslote_model.dart';
import 'package:flutter_restaurant/data/repository/product_repo.dart';
import 'package:flutter_restaurant/helper/api_checker.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/product_type.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/banner_provider.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/category_provider.dart';
import 'package:flutter_restaurant/provider/coupon_provider.dart';
import 'package:flutter_restaurant/provider/localization_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/product_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/set_menu_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/wishlist_provider.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_divider.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/base/no_data_screen.dart';
import 'package:flutter_restaurant/view/base/title_widget.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/cart/cart_screen.dart';
import 'package:flutter_restaurant/view/screens/cart/widget/delivery_option_button.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/slot_widget.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/category_web_view.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/set_menu_view_web.dart';
import 'package:flutter_restaurant/view/screens/home/widget/banner_view.dart';
import 'package:flutter_restaurant/view/screens/home/widget/category_view.dart';
import 'package:flutter_restaurant/view/screens/home/widget/main_slider.dart';
import 'package:flutter_restaurant/view/screens/home/widget/product_view.dart';
import 'package:flutter_restaurant/view/screens/home/widget/set_menu_view.dart';
import 'package:flutter_restaurant/view/screens/menu/widget/options_view.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

int DELIVERYTIME = 0;
String DELIVERYDAY = "";

class HomeScreen extends StatefulWidget {
  final bool fromAppBar;
  HomeScreen(this.fromAppBar);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{
  final GlobalKey<ScaffoldState> drawerGlobalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  TabController tabController;

  bool _isClosedDialogOpen = false;
  bool _isDialogOpen = false;
  bool _DialogOpen = false;
  String _orderDate = "Today";
  var _orderTime ;
  bool _isLoggedIn;

  String googleApikey = "AIzaSyDeFN4A3eenCTIUYvCI7dViF-N-V5X8RgA";
  GoogleMapController mapController; //contrller for Google map
  CameraPosition cameraPosition;
  LatLng startLocation = LatLng(27.6602292, 85.308027);
  String location = "Search Location";

  String _sessionToken = '1234';
  List<TimeSlotModel> _timeSlots;
  List<TimeSlotModel> _allTimeSlots;
  int _selectDateSlot = 0;
  int _selectTimeSlot = 0;
  var kPageTitle = 'Settings';
  var kLabels = ["Edit Profile", "Accounts"];
  var kTabBgColor = Color(0xFF8F32A9);
  var kTabFgColor = Colors.white;
  int tabIndex = 0;
  List<String> locationList = ['21 King St, Mascot','22 King St, Mascot','23 King St, Mascot','24 King St, Mascot','25 King St, Mascot'];
  String selectedLocation = '';
  List<GooglePlaceModel> _googlePlaceList = [];
  final TextEditingController _couponController = TextEditingController();
  Future<void> _loadData(BuildContext context, bool reload) async {
    //Provider.of<ProductProvider>(context, listen: false).getDeliveryAddress(
    //  context,  ADDRESSID, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
    //);
    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(Provider.of<AuthProvider>(context, listen: false).isLoggedIn()){
       Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);

       await Provider.of<WishListProvider>(context, listen: false).initWishList(
         context, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
       );
    }

    if(reload) {
      Provider.of<ProductProvider>(context, listen: false).getLatestProductList(
        context, false, '1', Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      );

      Provider.of<ProductProvider>(context, listen: false).getPopularProductList(
        context, false, '1',
      );

      Provider.of<SplashProvider>(context, listen: false).getPolicyPage(context);


      Provider.of<ProductProvider>(context, listen: false).seeMoreReturn();

      Provider.of<CategoryProvider>(context, listen: false).getCategoryList(
        context, true, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      );

      Provider.of<SetMenuProvider>(context, listen: false).getSetMenuList(
        context, reload,Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      );

      Provider.of<BannerProvider>(context, listen: false).getBannerList(context, reload);

    }else{

      Provider.of<CategoryProvider>(context, listen: false).getCategoryList(
        context, true, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      );

      Provider.of<SetMenuProvider>(context, listen: false).getSetMenuList(
        context, reload,Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      );

      Provider.of<BannerProvider>(context, listen: false).getBannerList(context, reload);
    }



  }
  TextEditingController _controller = TextEditingController();
  var uuid = Uuid();
  List<dynamic> _placesList = [];
  double _dialogHeight = 400;
  double _dialogWidth = 400;
  double _dialogPadding = 0;
  bool setAddressType = false;



  @override
  void initState() {
    _sessionToken = uuid.v4();


    Provider.of<ProductProvider>(context, listen: false).seeMoreReturn();
    if(!widget.fromAppBar || Provider.of<CategoryProvider>(context, listen: false).categoryList == null) {
      _loadData(context, false);
    }
    Provider.of<OrderProvider>(context, listen: false).initializeTimeSlot(context).then((value) {
      Provider.of<OrderProvider>(context, listen: false).sortTime();
    });
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
     // ResponsiveHelper.isDesktop(context)?webPickUPDialogFlat() : mobilePickUPDialogFlat();
      /*if(!Provider.of<SplashProvider>(context, listen: false).isRestaurantOpenNow(context)){

        AdvancedOrderButtonDialog(Provider.of<SplashProvider>(context, listen: false).configModel.restaurantScheduleTime);

      }*/

      //_isDialogOpen = true;
    });

    super.initState();
  }


  void onChange(setModalState){
      if(_sessionToken == null ){
        setModalState(() {
         _sessionToken = uuid.v4();
       });
      }

      //getSuggestion(_controller.text,setModalState);
  }

  void getLocAddress(String input,setModalState)async{
    String baseURL ='https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$googleApikey&sessiontoken=$_sessionToken';

    Map<String, String> _headers;
    _headers = {
    "x-requested-with" : "XMLHttpRequest",
    "content-type" : "application/json",
    "Accept" : "application/json",
    "Access-Control-Allow-Origin" : "*",
    "Access-Control-Allow-Methods" : "GET,POST,OPTIONS",
    "Access-Control-Allow-Credentials" : "true",
    "Access-Control-Allow-Headers" : "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",

    };

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=dh&key=AIzaSyDeFN4A3eenCTIUYvCI7dViF-N-V5X8RgA&sessiontoken=8c6ba140-285f-4c14-a02b-1dcc6a7e0e72'));


    if (response != null) {
      // Handle response
    } else {
      throw Exception('Failed to load data');
    }
  }



  getLocAddress1(String _input,setModalState)async{
    final sl = GetIt.instance;
    DioClient dioClient = DioClient(AppConstants.BASE_URL, sl(), loggingInterceptor: sl(), sharedPreferences: sl());
    ProductRepo branchRepo = ProductRepo(dioClient: dioClient);
    //String uid, String languageCode,String input,String token
    ApiResponse apiResponse = await branchRepo.getLocAddress(googleApikey,'en',_input,_sessionToken);
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      var rows = apiResponse.response.data;
      for (var row in rows) {
        _googlePlaceList.add(GooglePlaceModel.fromJson(row));
      }
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    setModalState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.isDesktop(context)?webPickUPDialogFlat() : mobilePickUPDialogFlat();
    //_isDialogOpen = true;
    final double _height = MediaQuery.of(context).size.height;
    final double xyz = MediaQuery.of(context).size.width-1170;
    final double realSpaceNeeded =xyz/2;
    final double pageWidth = MediaQuery.of(context).size.width;
    if(ResponsiveHelper.isDesktop(context)){
      _dialogHeight = _height-250;
      _dialogWidth = pageWidth*.4;
      _dialogPadding = pageWidth*.1;
    }else{
      _dialogWidth = pageWidth;
    }
    String appliedCoupon = Provider.of<CouponProvider>(context).getCoupon();
    if(appliedCoupon.isNotEmpty){
      _couponController.text = appliedCoupon;
    }
    return Scaffold(
      key: drawerGlobalKey,

      endDrawerEnableOpenDragGesture: false,
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
      drawer: ResponsiveHelper.isTab(context) ? Drawer(child: OptionsView(onTap: null)) : SizedBox(),
      appBar: ResponsiveHelper.isDesktop(context) ? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(100)) : null,
      body: SafeArea(
        child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {

              /*if(DELIVERY_ADDRESS_TYPE=="0"){
                Provider.of<OrderProvider>(context, listen: false).setOrderType('take_away',notify: true);
              }else{
                Provider.of<OrderProvider>(context, listen: false).setOrderType('delivery',notify: true);
              }*/

              if(productProvider.deliveryAddressStatus == "UID Missing" || productProvider.deliveryAddressStatus == "Error" || productProvider.deliveryAddressStatus == "No Data Found"){
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  // if(!_isDialogOpen && DELIVERYTYPE.length<2)pickup_and_delivery_dialogWeb();

                });
              }else{
               /* SchedulerBinding.instance.addPostFrameCallback((_) {
                  if(!Provider.of<SplashProvider>(context, listen: false).isRestaurantOpenNow(context)){

                    if(!_isClosedDialogOpen)
                    AdvancedOrderButtonDialog(Provider.of<SplashProvider>(context, listen: false).configModel.restaurantScheduleTime);

                  }
                });*/
              }
              return Row(
                children: [
                  Container(
                    width: ResponsiveHelper.isDesktop(context)?pageWidth*.75:pageWidth,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        Provider.of<OrderProvider>(context, listen: false).changeStatus(true, notify: true);
                        Provider.of<ProductProvider>(context, listen: false).latestOffset = 1;

                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      child: ResponsiveHelper.isDesktop(context) ? _scrollView(_scrollController, context) : Stack(
                        children: [
                          _scrollView(_scrollController, context),
                          Consumer<SplashProvider>(
                              builder: (context, splashProvider, _){
                                return !splashProvider.isRestaurantOpenNow(context) ?  Positioned(
                                  bottom: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                  left: 0,right: 0,
                                  child: Consumer<OrderProvider>(
                                    builder: (context, orderProvider, _){
                                      return orderProvider.isRestaurantCloseShow ? Container(
                                        padding: const EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                        alignment: Alignment.center,
                                        color: Theme.of(context).primaryColor.withOpacity(0.9),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                                            child: Text('${'${getTranslated('restaurant_is_close_now', context)}'}',
                                              style: rubikRegular.copyWith(fontSize: 12, color: Colors.white),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => orderProvider.changeStatus(false, notify: true),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                              child: Icon(Icons.cancel_outlined, color: Colors.white, size: Dimensions.PADDING_SIZE_LARGE),
                                            ),
                                          ),
                                        ],),
                                      ) : SizedBox();
                                    },

                                  ),
                                ) : SizedBox();
                              }
                          )

                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: _height,
                    width: ResponsiveHelper.isDesktop(context)?pageWidth*.25:0,
                    decoration: BoxDecoration(
                      boxShadow: [

                      ],
                    ),
                    child: Consumer<OrderProvider>(
                        builder: (context, order, child) {

                          /*if(!setAddressType){
                            if(DELIVERY_ADDRESS_TYPE=="0"){
                              order.setOrderType('take_away',notify: true);
                              setAddressType = true;
                            }else{
                              order.setOrderType('delivery',notify: true);
                              setAddressType = true;
                            }
                          }*/
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
                                                            // margin: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
                                                            padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(horizontal: Dimensions.FONT_SIZE_EXTRA_SMALL,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
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
                                                                ]
                                                            ),
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
                  ),
                ],
              );
            }
         ),

      ),
      endDrawer: !ResponsiveHelper.isDesktop(context)?Drawer(

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
      ):Container(),

    );
  }

  Scrollbar _scrollView(ScrollController _scrollController, BuildContext context) {
   // _isDialogOpen = true;
    return Scrollbar(
          controller: _scrollController,
          child: CustomScrollView(controller: _scrollController, slivers: [

            // AppBar
            ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(child: SizedBox()) : SliverAppBar(
                floating: true,
                elevation: 0,
                centerTitle: false,
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).cardColor,
                pinned: true,//ResponsiveHelper.isTab(context) ? true : false,
                leading: ResponsiveHelper.isTab(context) ? IconButton(
                  onPressed: () => drawerGlobalKey.currentState.openDrawer(),
                  icon: Icon(Icons.menu,color: Colors.red),
                ): null,
                title: Consumer<SplashProvider>(builder:(context, splash, child) => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ResponsiveHelper.isWeb() ? FadeInImage.assetNetwork(
                      placeholder: Images.placeholder_rectangle, height: 40, width: 40,
                      image: splash.baseUrls != null ? '${splash.baseUrls.restaurantImageUrl}/${splash.configModel.restaurantLogo}' : '',
                      imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder_rectangle, height: 40, width: 40),
                    ) : Image.asset(Images.logo, width: 40, height: 40),
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
                        Icon(Icons.shopping_cart, color: Colors.red),
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
              child: Center(
                child: Column(
                  children: [

                    SizedBox(
                      width: 1170,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        ResponsiveHelper.isDesktop(context) ? Padding(
                          padding: EdgeInsets.only(top: Dimensions.PADDING_SIZE_DEFAULT),
                          child: MainSlider(),
                        ):  SizedBox(),

                       //todo::delivery picup
                       // ResponsiveHelper.isDesktop(context)?webPickUPDialogFlat() : mobilePickUPDialogFlat(),



                        //ResponsiveHelper.isDesktop(context)? CategoryViewWeb() : CategoryView(),
                        ResponsiveHelper.isDesktop(context)? Container(padding:EdgeInsets.symmetric(horizontal: 50),child: CategoryViewWeb()) : CategoryView(),
                        ResponsiveHelper.isDesktop(context) ? Row(
                          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: Text(getTranslated('popular_item', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_OVER_LARGE)),
                            ),
                          ],
                        ) :
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                          child: TitleWidget(title: getTranslated('popular_item', context), onTap: (){
                            Navigator.pushNamed(context, Routes.getPopularItemScreen());
                          },),
                        ),
                        ProductView(productType: ProductType.POPULAR_PRODUCT,),


                        ResponsiveHelper.isDesktop(context)? SetMenuViewWeb() :  SetMenuView(),

                        ResponsiveHelper.isDesktop(context) ?  SizedBox(): BannerView(),


                        ResponsiveHelper.isDesktop(context) ? Row(
                          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: Text(getTranslated('latest_item', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_OVER_LARGE)),
                            ),
                          ],
                        ) :
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                          child: TitleWidget(title: getTranslated('latest_item', context)),
                        ),
                        ProductView(productType: ProductType.LATEST_PRODUCT, scrollController: _scrollController),

                      ]),
                    ),
                    if(ResponsiveHelper.isDesktop(context)) FooterViewForMenu(),
                  ],
                ),
              ),
            ),
          //  if(ResponsiveHelper.isDesktop(context)) FooterView(),
          ]),
        );
  }

  mobilePickUPDialogFlat(){
    return  !_isDialogOpen?Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: (){
          pickup_and_delivery_dialog();
          _isDialogOpen = true;
          setState(() {

          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height * .06),
          child: Container(
            height: 170,
            width: MediaQuery.of(context).size.height * .7,
            child: Column(
              children: [
                Container(
                  //color: const Color(0xFFe9edf5),
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(0)),
                      color: const Color(0xFFe9edf5)),
                  child: TabBar(
                    controller: tabController,
                    //padding: EdgeInsets.all(5),
                    labelStyle:
                    TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelColor:Color(0xFFE01F26),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(0)),
                        color: Colors.white),
                    labelColor:Color(0xFFE01F26),
                    onTap: (index){
                      pickup_and_delivery_dialog();
                      _isDialogOpen = true;
                      tabIndex = index;
                      setState(() {

                      });
                    },
                    tabs: [
                      Tab(
                        icon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                                Images.delivery,
                                height: 30,
                                width: 30,
                                color: tabIndex==0?
                               Color(0xFFE01F26):
                                Colors.grey
                            ),
                            SizedBox(width: 5,),
                            Text(
                              "Delivery",
                              style: TextStyle(
                                  color: tabIndex==0?
                                 Color(0xFFE01F26):
                                  Colors.grey
                              ),
                            ),
                          ],
                        ),
                        height: 45,
                      ),
                      Tab(
                        icon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                                Images.pickup,
                                height: 30,
                                width: 30,
                                color: tabIndex==1?Color(0xFFE01F26):Colors.grey
                            ),
                            SizedBox(width: 5,),
                            Text(
                              "Pickup",
                              style: TextStyle(
                                  color: tabIndex==1? Color(0xFFE01F26):Colors.grey
                              ),
                            ),
                          ],
                        ),
                        height: 35,
                      )
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: 10),
                    height: 135, //height of TabBarView
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: Colors.white,
                                width: 2))),
                    child: TabBarView(
                        controller:tabController ,
                        children: <Widget>[
                          Container(
                            //color: Colors.red,
                            height:125,
                            child:ListView(
                              children: [
                                Container(
                                  height: 35,
                                  child: Text(
                                    'Enter Your Delivery Address',
                                    style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                  ),
                                ),
                                Container(
                                  // padding: EdgeInsets.all(5),
                                  height: 70,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex:3,
                                        child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child: GestureDetector(
                                              onTap: (){
                                                pickup_and_delivery_dialog();
                                                _isDialogOpen = true;
                                                setState(() {

                                                });
                                              },
                                              child: TextField(
                                                enableInteractiveSelection: false, // will disable paste operation
                                                readOnly: true,
                                                enabled: false,
                                                decoration: InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                                style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                              ),
                                            )
                                        ),
                                      ),
                                      Expanded(
                                        flex:1,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Color(0xFFE01F26),
                                                shadowColor: Color(0xff763637),
                                                minimumSize: Size(150,75),
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                                )


                                            ),

                                            onPressed: (){
                                             // AdvancedOrderButtonDialog();
                                              if(selectedLocation == '21 King St, Mascot'){
                                                //AdvancedOrderButtonDialog();
                                              }else{

                                              }
                                            },
                                            child: Text(
                                              'Order Now',
                                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 125,
                            child: ListView(
                              children: [
                                Container(
                                  height: 35,
                                  child: Text(
                                    'Enter Your Suburb or postcode',
                                    style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                  ),
                                ),
                                Container(
                                  // padding: EdgeInsets.all(5),
                                  height: 70,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex:3,
                                        child: GestureDetector(
                                          onTap: (){
                                            pickup_and_delivery_dialog();
                                            _isDialogOpen = true;
                                            setState(() {

                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child:TextField(
                                              enableInteractiveSelection: false, // will disable paste operation
                                              readOnly: true,
                                              enabled: false,
                                              decoration: const InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex:1,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Color(0xFFE01F26),
                                                minimumSize: Size(150,75),
                                                shadowColor: Color(0xff763637),
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                                )


                                            ),

                                            onPressed: (){

                                            },
                                            child: Text(
                                              'Order Now',
                                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  child: TextButton.icon(
                                      onPressed: (){
                                        pickup_and_delivery_dialog();
                                        _isDialogOpen = true;
                                        setState(() {

                                        });

                                      },
                                      icon: Icon(
                                        Icons.my_location,
                                        color: Color(0xFFE01F26),
                                      ),
                                      label: Text(
                                        'Find my nearest Pizza Corner',
                                        style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Color(0xFFE01F26),
                                          decoration: TextDecoration.underline,),
                                      )),
                                  alignment: Alignment.topLeft,
                                )
                              ],
                            ),
                          )
                        ])),
              ],
            ),
          ),
        ),
      ),
    ):Container();
  }

  webPickUPDialogFlat(){
    return  !_isDialogOpen?Container(
      width: MediaQuery.of(context).size.width-MediaQuery.of(context).size.width*.25,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: (){
          pickup_and_delivery_dialogWeb();
          _isDialogOpen = true;
          setState(() {

          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height * .06),
          child: Container(
            height: 185,
            width: MediaQuery.of(context).size.height * .7,
            child: Column(
              children: [
                Container(
                  //color: const Color(0xFFe9edf5),
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(0)),
                      color: const Color(0xFFe9edf5)),
                  child: TabBar(
                    controller: tabController,
                    //padding: EdgeInsets.all(5),
                    labelStyle:
                    TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelColor: Color(0xFFE01F26),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(0)),
                        color: Colors.white),
                    labelColor: Color(0xFFE01F26),
                    onTap: (index){
                      pickup_and_delivery_dialogWeb();
                      _isDialogOpen = true;
                      tabIndex = index;
                      setState(() {

                      });
                    },
                    tabs: [
                      Tab(
                        icon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                                Images.delivery,
                                height: 30,
                                width: 30,
                                color: tabIndex==0?
                                Color(0xFFE01F26):
                                Colors.grey
                            ),
                            SizedBox(width: 5,),
                            Text(
                              "Delivery",
                              style: TextStyle(
                                  color: tabIndex==0?
                                  Color(0xFFE01F26):
                                  Colors.grey
                              ),
                            ),
                          ],
                        ),
                        height: 45,
                      ),
                      Tab(
                        icon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                                Images.pickup,
                                height: 30,
                                width: 30,
                                color: tabIndex==1? Color(0xFFE01F26):Colors.grey
                            ),
                            SizedBox(width: 5,),
                            Text(
                              "Pickup",
                              style: TextStyle(
                                  color: tabIndex==1? Color(0xFFE01F26):Colors.grey
                              ),
                            ),
                          ],
                        ),
                        height: 35,
                      )
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: 10),
                    height: 135, //height of TabBarView
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: Colors.white,
                                width: 2))),
                    child: TabBarView(
                        controller:tabController ,
                        children: <Widget>[
                          Container(
                            //color: Colors.red,
                            height:125,
                            child:ListView(
                              children: [
                                Container(
                                  height: 35,
                                  child: Text(
                                    'Enter Your Delivery Address',
                                    style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                  ),
                                ),
                                Container(
                                  // padding: EdgeInsets.all(5),
                                  height: 70,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex:3,
                                        child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child: GestureDetector(
                                              onTap: (){
                                                pickup_and_delivery_dialogWeb();
                                                _isDialogOpen = true;
                                                setState(() {

                                                });
                                              },
                                              child: TextField(
                                                enableInteractiveSelection: false, // will disable paste operation
                                                readOnly: true,
                                                enabled: false,
                                                decoration: InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                                style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                              ),
                                            )
                                        ),
                                      ),
                                      Expanded(
                                        flex:1,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Color(0xFFE01F26),
                                                shadowColor: Color(0xff763637),
                                                minimumSize: Size(150,75),
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                                )


                                            ),

                                            onPressed: (){
                                              if(selectedLocation == '21 King St, Mascot'){
                                                //AdvancedOrderButtonDialog();
                                              }else{

                                              }
                                            },
                                            child: Text(
                                              'Order Now',
                                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 125,
                            child: ListView(
                              children: [
                                Container(
                                  height: 35,
                                  child: Text(
                                    'Enter Your Suburb or postcode',
                                    style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                  ),
                                ),
                                Container(
                                  // padding: EdgeInsets.all(5),
                                  height: 70,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex:3,
                                        child: GestureDetector(
                                          onTap: (){
                                            pickup_and_delivery_dialogWeb();
                                            _isDialogOpen = true;
                                            setState(() {

                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child:TextField(
                                              enableInteractiveSelection: false, // will disable paste operation
                                              readOnly: true,
                                              enabled: false,
                                              decoration: const InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex:1,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Color(0xFFE01F26),
                                                minimumSize: Size(150,75),
                                                shadowColor: Color(0xff763637),
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                                )


                                            ),

                                            onPressed: (){
                                              if(selectedLocation == '21 King St, Mascot'){
                                                //AdvancedOrderButtonDialog();
                                              }else{

                                              }
                                            },
                                            child: Text(
                                              'Order Now',
                                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  child: TextButton.icon(
                                      onPressed: (){
                                        pickup_and_delivery_dialogWeb();
                                        _isDialogOpen = true;
                                        setState(() {

                                        });

                                      },
                                      icon: Icon(
                                        Icons.my_location,
                                        color: Color(0xFFE01F26),
                                      ),
                                      label: Text(
                                        'Find my nearest Pizza Corner',
                                        style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Color(0xFFE01F26),
                                          decoration: TextDecoration.underline,),
                                      )),
                                  alignment: Alignment.topLeft,
                                )
                              ],
                            ),
                          )
                        ])),
              ],
            ),
          ),
        ),
      ),
    ):Container();
  }

  pickup_and_delivery_dialog1() {
    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
           // onChange(setModalState);
            return AlertDialog(
              content: Container(
                height: 450,
                width: MediaQuery.of(context).size.height * .7,
                child: Column(
                  children: [
                    Container(
                      //color: const Color(0xFFe9edf5),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(0)),
                          color: const Color(0xFFe9edf5)),
                      child: TabBar(
                        controller: tabController,
                        //padding: EdgeInsets.all(5),
                        labelStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelColor: Color(0xFFE01F26),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(0)),
                            color: Colors.white),
                        labelColor:Color(0xFFE01F26),
                        onTap: (index){
                          tabIndex = index;
                          setModalState(() {

                          });
                        },
                        tabs: [
                          Tab(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  Images.delivery,
                                  height: 30,
                                  width: 30,
                                    color: tabIndex==0?
                                    Color(0xFFE01F26):
                                    Colors.grey
                                ),
                                SizedBox(width: 5,),
                                Text(
                                    "Delivery",
                                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL,color: tabIndex==0?
                                  Color(0xFFE01F26):
                                  Colors.grey),
                                ),
                              ],
                            ),
                            height: 45,
                          ),
                          Tab(
                              icon: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    Images.pickup,
                                    height: 30,
                                    width: 30,
                                      color: tabIndex==1? Color(0xFFE01F26):Colors.grey
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                      "Pickup",
                                    style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                  ),
                                ],
                              ),
                            height: 35,
                          )
                        ],
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        height: 135, //height of TabBarView
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.white,
                                    width: 2))),
                        child: TabBarView(
                          controller:tabController ,
                            children: <Widget>[
                          Container(
                            //color: Colors.red,
                            height:125,
                            child:ListView(
                               children: [
                              Container(
                              height: 35,
                              child: Text(
                                  'Enter Your Delivery Address',
                                style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                              ),
                            ),
                            Container(
                                   // padding: EdgeInsets.all(5),
                                   height: 70,
                                   decoration: BoxDecoration(
                                     border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                     borderRadius: BorderRadius.all(Radius.circular(10))
                                   ),
                                   child: Row(
                                     children: [
                                       Expanded(
                                         flex:3,
                                         child: Padding(
                                             padding: EdgeInsets.all(15.0),
                                             child: Column(
                                               children: [
                                                 TextField(
                                                   onChanged: (val){
                                                     //getSuggestion(val,setModalState);
                                                     getLocAddress(val,setModalState);
                                                   },
                                                   controller: _controller,
                                                   decoration: const InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                                   style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                                 ),
                                                 Expanded(
                                                     child: ListView.builder(
                                                         itemCount: _placesList.length,
                                                         itemBuilder: (context,index){
                                                           return ListTile(
                                                             onTap: ()async{

                                                             },
                                                             title: Text(_placesList[index]['description']),
                                                             leading: Icon(Icons.location_on_sharp),
                                                           );
                                                         }
                                                     )
                                                 )
                                               ],
                                             )
                                         ),
                                       ),
                                       Expanded(
                                         flex:1,
                                         child: ElevatedButton(
                                           style: ElevatedButton.styleFrom(
                                             primary: Color(0xFFE01F26),
                                               shadowColor: Color(0xff763637),
                                             minimumSize: Size(150,75),
                                             padding: EdgeInsets.zero,
                                               shape: RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                               )


                                           ),

                                             onPressed: (){
                                               if(selectedLocation == '21 King St, Mascot'){
                                                 //AdvancedOrderButtonDialog();
                                               }else{

                                               }
                                             },
                                             child: Text(
                                                 'Order Now',
                                               style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                             )
                                         ),
                                       )
                                     ],
                                   ),
                                 ),
                           ],
                          ),
                          ),
                          Container(
                            height: 240,
                            child: Column(
                              children: [
                                Container(
                                  height: 35,
                                  child: Text(
                                      'Enter Your Suburb or postcode',
                                    style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                  ),
                                ),
                                Container(
                                  // padding: EdgeInsets.all(5),
                                  height: 70,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex:3,
                                        child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child: Column(
                                              children: [
                                                TextField(
                                                  controller: _controller,
                                                  decoration: const InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                                  onChanged: (val){
                                                    //getSuggestion(val,setModalState);
                                                    getLocAddress(val,setModalState);
                                                  },
                                                ),
                                              ],
                                            )
                                        ),
                                      ),
                                      Expanded(
                                        flex:1,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Color(0xFFE01F26),
                                                minimumSize: Size(150,75),
                                                shadowColor: Color(0xff763637),

                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                                )


                                            ),

                                            onPressed: (){
                                              if(selectedLocation == '21 King St, Mascot'){
                                               // AdvancedOrderButtonDialog();
                                              }else{

                                              }
                                            },
                                            child: Text(
                                                'Order Now',
                                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 30,
                                    child: TextButton.icon(
                                        onPressed: (){

                                    },
                                    icon: Icon(
                                        Icons.my_location,
                                      color: Color(0xFFE01F26),
                                    ),
                                    label: Text(
                                        'Find my nearest Pizza Corner',

                                      style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL,color: Color(0xFFE01F26),
                                        decoration: TextDecoration.underline,),
                                    )),
                                  alignment: Alignment.topLeft,
                                ),
                                Container(
                                  color: Colors.red,
                                  height: 100,
                                  child: Expanded(
                                      child: ListView.builder(
                                          itemCount: _placesList.length,
                                          itemBuilder: (context,index){
                                            return ListTile(
                                              onTap: ()async{

                                              },
                                              title: Text(_placesList[index]['description']),
                                              leading: Icon(Icons.location_on_sharp),
                                            );
                                          }
                                      )
                                  ),
                                ),
                              ],
                            ),
                          )
                        ])),
                  ],
                ),
              ),
              actions: [],
            );
          },
        );
      },
    ).then((_) {
      _isDialogOpen = false;
      setState(() {

      });
    } );
  }
  pickup_and_delivery_dialog() {
    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // onChange(setModalState);
            return AlertDialog(
              content: Container(
                height: 450,
                width: MediaQuery.of(context).size.height * .7,
                child: Column(
                  children: [
                    Container(
                      //color: const Color(0xFFe9edf5),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(0)),
                          color: const Color(0xFFe9edf5)),
                      child: TabBar(
                        controller: tabController,
                        //padding: EdgeInsets.all(5),
                        labelStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelColor: Color(0xFFE01F26),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(0)),
                            color: Colors.white),
                        labelColor: Color(0xFFE01F26),
                        onTap: (index){
                          tabIndex = index;
                          setModalState(() {

                          });
                        },
                        tabs: [
                          Tab(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    Images.delivery,
                                    height: 30,
                                    width: 30,
                                    color: tabIndex==0?
                                    Color(0xFFE01F26):
                                    Colors.grey
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  "Delivery",
                                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL,color: tabIndex==0?
                                  Color(0xFFE01F26):
                                  Colors.grey),
                                ),
                              ],
                            ),
                            height: 45,
                          ),
                          Tab(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    Images.pickup,
                                    height: 30,
                                    width: 30,
                                    color: tabIndex==1? Color(0xFFE01F26):Colors.grey
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  "Pickup",
                                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                ),
                              ],
                            ),
                            height: 35,
                          )
                        ],
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        height: 135, //height of TabBarView
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.white,
                                    width: 2))),
                        child: TabBarView(
                            controller:tabController ,
                            children: <Widget>[
                              Container(
                                //color: Colors.red,
                                height:125,
                                child:ListView(
                                  children: [
                                    Container(
                                      height: 35,
                                      child: Text(
                                        'Enter Your Delivery Address',
                                        style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                      ),
                                    ),
                                    Container(
                                      // padding: EdgeInsets.all(5),
                                      height: 70,
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex:3,
                                            child: Padding(
                                                padding: EdgeInsets.all(15.0),
                                                child: Column(
                                                  children: [
                                                    TextField(
                                                      onChanged: (val){
                                                        //getSuggestion(val,setModalState);
                                                        getLocAddress(val,setModalState);
                                                      },
                                                      controller: _controller,
                                                      decoration: const InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                                      style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                                    ),
                                                    Expanded(
                                                        child: ListView.builder(
                                                            itemCount: _placesList.length,
                                                            itemBuilder: (context,index){
                                                              return ListTile(
                                                                onTap: ()async{

                                                                },
                                                                title: Text(_placesList[index]['description']),
                                                                leading: Icon(Icons.location_on_sharp),
                                                              );
                                                            }
                                                        )
                                                    )
                                                  ],
                                                )
                                            ),
                                          ),
                                          Expanded(
                                            flex:1,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: Color(0xFFE01F26),
                                                    shadowColor: Color(0xff763637),
                                                    minimumSize: Size(150,75),
                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                                    )


                                                ),

                                                onPressed: (){
                                                  if(selectedLocation == '21 King St, Mascot'){
                                                    //AdvancedOrderButtonDialog();
                                                  }else{

                                                  }
                                                },
                                                child: Text(
                                                  'Order Now',
                                                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 240,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 35,
                                      child: Text(
                                        'Enter Your Suburb or postcode',
                                        style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                      ),
                                    ),
                                    Container(
                                      // padding: EdgeInsets.all(5),
                                      height: 70,
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex:3,
                                            child: Padding(
                                                padding: EdgeInsets.all(15.0),
                                                child: Column(
                                                  children: [
                                                    TextField(
                                                      controller: _controller,
                                                      decoration: const InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                                      style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                                      onChanged: (val){
                                                        //getSuggestion(val,setModalState);
                                                        getLocAddress(val,setModalState);
                                                      },
                                                    ),
                                                  ],
                                                )
                                            ),
                                          ),
                                          Expanded(
                                            flex:1,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: Color(0xFFE01F26),
                                                    minimumSize: Size(150,75),
                                                    shadowColor: Color(0xff763637),

                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                                    )


                                                ),

                                                onPressed: (){
                                                  if(selectedLocation == '21 King St, Mascot'){
                                                    //AdvancedOrderButtonDialog();
                                                  }else{

                                                  }
                                                },
                                                child: Text(
                                                  'Order Now',
                                                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      child: TextButton.icon(
                                          onPressed: (){

                                          },
                                          icon: Icon(
                                            Icons.my_location,
                                            color: Color(0xFFE01F26),
                                          ),
                                          label: Text(
                                            'Find my nearest Pizza Corner',

                                            style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL,color: Color(0xFFE01F26),
                                              decoration: TextDecoration.underline,),
                                          )),
                                      alignment: Alignment.topLeft,
                                    ),
                                    Container(
                                      color: Colors.red,
                                      height: 100,
                                      child: Expanded(
                                          child: ListView.builder(
                                              itemCount: _placesList.length,
                                              itemBuilder: (context,index){
                                                return ListTile(
                                                  onTap: ()async{

                                                  },
                                                  title: Text(_placesList[index]['description']),
                                                  leading: Icon(Icons.location_on_sharp),
                                                );
                                              }
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ])),
                  ],
                ),
              ),
              actions: [],
            );
          },
        );
      },
    ).then((_) {
      _isDialogOpen = false;
      setState(() {

      });
    } );
  }

  pickup_and_delivery_dialogWeb1() {
    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              content: Container(
                height: 185,
                width: MediaQuery.of(context).size.height * .7,
                child: Column(
                  children: [
                    Container(
                      //color: const Color(0xFFe9edf5),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(0)),
                          color: const Color(0xFFe9edf5)),
                      child: TabBar(
                        controller: tabController,
                        //padding: EdgeInsets.all(5),
                        labelStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelColor: Color(0xFFE01F26),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(0)),
                            color: Colors.white),
                        labelColor: Color(0xFFE01F26),
                        onTap: (index){
                          tabIndex = index;
                          setModalState(() {

                          });
                        },
                        tabs: [
                          Tab(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    Images.delivery,
                                    height: 30,
                                    width: 30,
                                    color: tabIndex==0?
                                    Color(0xFFE01F26):
                                    Colors.grey
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  "Delivery",
                                    maxLines: 1,
                                     style: rubikMedium.copyWith(color:  tabIndex==0?Color(0xFFE01F26): Colors.grey, overflow: TextOverflow.ellipsis)
                                  //style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL,color: tabIndex==0?Color(0xfffbaa24):Colors.grey),
                                ),
                              ],
                            ),
                            height: 45,
                          ),
                          Tab(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    Images.pickup,
                                    height: 30,
                                    width: 30,
                                    color: tabIndex==1? Color(0xFFE01F26):Colors.grey
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  "Pickup",
                                    style: rubikMedium.copyWith(color:  tabIndex==1? Color(0xFFE01F26): Colors.grey, overflow: TextOverflow.ellipsis)
                                ),
                              ],
                            ),
                            height: 35,
                          )
                        ],
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        height: 135, //height of TabBarView
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.white,
                                    width: 2))),
                        child: TabBarView(
                            controller:tabController ,
                            children: <Widget>[
                              Container(
                                //color: Colors.red,
                                height:125,
                                child:Column(
                                  children: [
                                    Container(
                                      height: 35,
                                      child: Text(
                                        'Enter Your Delivery Address',
                                        style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                      ),
                                    ),
                                    Container(
                                      // padding: EdgeInsets.all(5),
                                      height: 70,
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex:3,
                                            child: Padding(
                                              padding: EdgeInsets.all(15.0),
                                              child: Column(
                                                children: [
                                                  TextField(
                                                    onChanged: (val){
                                                      getLocAddress(val,setModalState);
                                                    },
                                                    controller: _controller,
                                                    decoration: const InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                                    style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                                  ),
                                                  Expanded(
                                                      child: ListView.builder(
                                                          itemCount: _placesList.length,
                                                          itemBuilder: (context,index){
                                                            return ListTile(
                                                              onTap: ()async{

                                                              },
                                                              title: Text(_placesList[index]['description']),
                                                              leading: Icon(Icons.location_on_sharp),
                                                            );
                                                         }
                                                      )
                                                  )
                                                ],
                                              )
                                            ),
                                          ),
                                          Expanded(
                                            flex:1,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: Color(0xFFE01F26),
                                                    shadowColor: Color(0xff763637),
                                                    minimumSize: Size(150,75),
                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                                    )


                                                ),

                                                onPressed: (){

                                                },
                                                child: Text(
                                                  'Order Now',
                                                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 150,
                                child: Column(
                                  children: [
                                    Container(
                                      color: Color(0xFFE01F26),
                                      height: 35,
                                      child: Text(
                                        'Enter Your Suburb or postcode',
                                        style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                      ),
                                    ),
                                    Container(

                                      // padding: EdgeInsets.all(5),
                                      height: 70,
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          border: Border.all(width: 2,color: Colors.black.withOpacity(.5)),
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex:3,
                                            child: Padding(
                                              padding: EdgeInsets.all(15.0),
                                              child: Autocomplete<GooglePlaceModel>(
                                                optionsBuilder: (TextEditingValue textEditingValue) {
                                                  return _googlePlaceList.where((GooglePlaceModel model) => model.description.toLowerCase().startsWith(textEditingValue.text.toLowerCase())
                                                  ).toList();
                                                },
                                                displayStringForOption: (GooglePlaceModel option) => option.description,
                                                fieldViewBuilder: (
                                                    BuildContext context,
                                                    TextEditingController fieldTextEditingController,
                                                    FocusNode fieldFocusNode,
                                                    VoidCallback onFieldSubmitted
                                                    ) {
                                                  return TextField(

                                                    onChanged: (val){
                                                      getLocAddress(val,setModalState);
                                                    },
                                                    controller: fieldTextEditingController,
                                                    focusNode: fieldFocusNode,
                                                    decoration: const InputDecoration(hintText: 'e.g 21 King St, Mascot', border: InputBorder.none,),
                                                    style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                                  );
                                                },
                                                onSelected: (GooglePlaceModel selection) {
                                                  selectedLocation = selection.description;


                                                },
                                                optionsViewBuilder: (
                                                    BuildContext context,
                                                    AutocompleteOnSelected<GooglePlaceModel> onSelected,
                                                    Iterable<GooglePlaceModel> options
                                                    ) {
                                                  return Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Material(
                                                      child: Container(
                                                        width: 300,
                                                        child: ListView.builder(
                                                          padding: EdgeInsets.all(10.0),
                                                          itemCount: options.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            final GooglePlaceModel option = options.elementAt(index);

                                                            return GestureDetector(
                                                              onTap: () {
                                                                onSelected(option);
                                                              },
                                                              child: ListTile(
                                                                title: Text(option.description, style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex:1,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: Color(0xFFE01F26),
                                                    minimumSize: Size(150,75),
                                                    shadowColor: Color(0xff763637),

                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(9),topRight: Radius.circular(9)),
                                                    )


                                                ),

                                                onPressed: (){

                                                },
                                                child: Text(
                                                  'Order Now',
                                                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      color: Colors.red,
                                      height: 30,
                                      child: TextButton.icon(
                                          onPressed: (){

                                          },
                                          icon: Icon(
                                            Icons.my_location,
                                            color: Color(0xFFE01F26),
                                          ),
                                          label: Text(
                                            'Find my nearest Pizza Corner',

                                            style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT,color:Color(0xFFE01F26),
                                              decoration: TextDecoration.underline,),
                                          )),
                                      alignment: Alignment.topLeft,
                                    )
                                  ],
                                ),
                              )
                            ])),
                  ],
                ),
              ),
              actions: [],
            );
          },
        );
      },
    ).then((_) {
      _isDialogOpen = false;
      setState(() {

      });
    } );
  }

  pickup_and_delivery_dialogWeb() {
    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {

            return Consumer<OrderProvider>(
              builder: (context, order, child) {
                return AlertDialog(
                  content: Container(
                    height: 250,
                    width: MediaQuery.of(context).size.height * .5,
                    child: Column(
                      children: [
                        Text("START YOUR ORDER"),
                        SizedBox(height: 10,),
                        Text("Let's start with some quick details"),
                        SizedBox(height: 10,),
                        Text("Select an option:"),
                        SizedBox(height: 20,),
                        Container(
                            child:Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: (){
                                      DeliveryStatus = 1;
                                      setModalState(() {

                                      });
                                    },
                                    child: Container(
                                      padding:EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: DeliveryStatus==1?Color(0xFFE01F26):Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(color:Color(0xFFE01F26)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              Images.delivery,
                                              height: 30,
                                              width: 30,
                                              color:DeliveryStatus==1?Colors.white:Color(0xFFE01F26)// Colors.grey
                                          ),
                                          SizedBox(width: 5,),
                                          Text(
                                              "Delivery",
                                              maxLines: 1,
                                              style: rubikMedium.copyWith(color:  DeliveryStatus==1?Colors.white:Color(0xFFE01F26), overflow: TextOverflow.ellipsis)
                                            //style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL,color: tabIndex==0?Color(0xfffbaa24):Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Expanded(
                                  child: InkWell(
                                    onTap: (){
                                      DeliveryStatus = 0;
                                      setModalState(() {

                                      });

                                    },
                                    child: Container(
                                      padding:EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: DeliveryStatus==0?Color(0xFFE01F26):Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(color:Color(0xFFE01F26)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              Images.pickup,
                                              height: 30,
                                              width: 30,
                                              color: DeliveryStatus==0?Colors.white:Color(0xFFE01F26)
                                          ),
                                          SizedBox(width: 5,),
                                          Text(
                                              "Pickup",
                                              style: rubikMedium.copyWith(color:  DeliveryStatus==0?
                                              Colors.white:Color(0xFFE01F26), overflow: TextOverflow.ellipsis)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            )
                        ),

                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){
                            DELIVERYTYPE = DeliveryStatus==0 ? "take_away" : "delivery" ;
                            order.setOrderType(DeliveryStatus==0 ? "take_away" : "delivery" , notify: true);
                            Navigator.pop(context);

                            if(!Provider.of<SplashProvider>(context, listen: false).isRestaurantOpenNow(context)){

                              AdvancedOrderButtonDialog(Provider.of<SplashProvider>(context, listen: false).configModel.restaurantScheduleTime);

                            }

                            setState(() {

                            });

                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFE01F26)),
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Continue",
                                  style: TextStyle(
                                    color: Color(0xFFE01F26),
                                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFFE01F26),
                                ),

                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  actions: [],
                );
              },
            );

          },
        );
      },
    ).then((_) {
      _isDialogOpen = false;
      setState(() {

      });
    } );
  }

  shopClosed_dialog() {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              content: Container(
                height: MediaQuery.of(context).size.height * .4,
                width: MediaQuery.of(context).size.height * .9,
                child: ListView(
                  children: [
                    Container(
                      //color: const Color(0xFFe9edf5),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(5)),
                          color: const Color(0xFFe9edf5)),
                      child: TabBar(
                        controller: tabController,
                        padding: EdgeInsets.all(5),
                        labelStyle:
                        TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelColor: Colors.green,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(10)),
                            color: Colors.white),
                        labelColor: Colors.green,
                        onTap: (index){
                          tabIndex = index;
                          setModalState(() {

                          });
                        },
                        tabs: [
                          Tab(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  Images.delivery,
                                  height: 30,
                                  width: 30,

                                ),
                                SizedBox(width: 5,),
                                Text(
                                  "Delivery",
                                  style: TextStyle(
                                      color: tabIndex==0?Color(0xFFE01F26):Colors.grey
                                  ),
                                ),
                              ],
                            ),
                            height: 35,
                          ),
                          Tab(

                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  Images.pickup,
                                  height: 30,
                                  width: 30,

                                ),
                                SizedBox(width: 5,),
                                Text(
                                  "Pickup",
                                  style: TextStyle(
                                      color: tabIndex==1?
                                      Color(0xFFE01F26):
                                      Colors.grey
                                  ),
                                ),
                              ],
                            ),
                            height: 35,
                          )
                        ],
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        height: 550, //height of TabBarView
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.white,
                                    width: 2))),
                        child: TabBarView(
                            controller:tabController ,
                            children: <Widget>[
                              Container(
                                //color: Colors.red,
                                height: 225,
                                child:ListView(
                                  children: [
                                    Container(
                                      height: 35,
                                      child: Text('Enter Your Delivery Address'),
                                    ),
                                    Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2,color: Colors.red.withAlpha(5))
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex:3,
                                            /* child: TextField(
                                           decoration: InputDecoration(
                                             hintText: 'e.g 21 King St, Mascot',

                                           ),
                                         ),*/
                                            child: Padding(
                                              padding: EdgeInsets.all(15.0),
                                              child: Autocomplete<String>(
                                                optionsBuilder: (TextEditingValue textEditingValue) {
                                                  return locationList
                                                      .where((String product) => product.toLowerCase()
                                                      .startsWith(textEditingValue.text.toLowerCase())
                                                  )
                                                      .toList();
                                                },
                                                displayStringForOption: (String option) => option,
                                                fieldViewBuilder: (
                                                    BuildContext context,
                                                    TextEditingController fieldTextEditingController,
                                                    FocusNode fieldFocusNode,
                                                    VoidCallback onFieldSubmitted
                                                    ) {
                                                  return TextField(
                                                    controller: fieldTextEditingController,
                                                    focusNode: fieldFocusNode,
                                                    decoration: const InputDecoration(hintText: 'e.g 21 King St, Mascot'),
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  );
                                                },
                                                onSelected: (String selection) {
                                                  //selectedProduct = selection;


                                                },
                                                optionsViewBuilder: (
                                                    BuildContext context,
                                                    AutocompleteOnSelected<String> onSelected,
                                                    Iterable<String> options
                                                    ) {
                                                  return Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Material(
                                                      child: Container(
                                                        width: 300,
                                                        child: ListView.builder(
                                                          padding: EdgeInsets.all(10.0),
                                                          itemCount: options.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            final String option = options.elementAt(index);

                                                            return GestureDetector(
                                                              onTap: () {
                                                                onSelected(option);
                                                              },
                                                              child: ListTile(
                                                                title: Text('21 King St, Mascot', style: const TextStyle(color: Colors.black)),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex:1,
                                            child: ElevatedButton(
                                                onPressed: (){},
                                                child: Text('Order Now')
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 225,
                                child: ListView(
                                  children: [
                                    Container(
                                      height: 35,
                                      child: Text('Enter Your Suburb or postcode'),
                                    ),
                                    Container(
                                      height: 100,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex:3,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                  hintText: 'e.g 21 King St, Mascot'
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex:1,
                                            child: ElevatedButton(
                                                onPressed: (){

                                                },
                                                child: Text('Order Now')
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: TextButton.icon(
                                          onPressed: (){

                                          },
                                          icon: Icon(
                                            Icons.my_location,
                                            color: Colors.blue,
                                          ),
                                          label: Text(
                                            'Find my nearest Pizza Corner',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          )),
                                      alignment: Alignment.topLeft,
                                    )
                                  ],
                                ),
                              )
                            ])),

                  ],
                ),
              ),
              actions: [],
            );
          },
        );
      },
    );
  }


  void updateTimeSlot(int index) {
    _selectTimeSlot = index;
   setState(() {

   });
  }

  void updateDateSlot(int index) {
    _selectDateSlot = index;
    if(_allTimeSlots != null) {
      Provider.of<OrderProvider>(context, listen: false).updateDateSlot(index);
      Provider.of<OrderProvider>(context, listen: false).updateDate(index);
      validateSlot(_allTimeSlots, index);
    }
    setState(() {

    });
  }

  void validateSlot(List<TimeSlotModel> slots, int dateIndex, {bool notify = true}) {
    _timeSlots = [];
    int _day = 0;
    if(dateIndex == 0) {
      _day = DateTime.now().weekday;
    }else {
      _day = DateTime.now().add(Duration(days: 1)).weekday;
    }
    if(_day == 7) {
      _day = 0;
    }
    slots.forEach((slot) {
      if (_day == slot.day && (dateIndex == 0 ? slot.endTime.isAfter(DateTime.now()) : true)) {
        _timeSlots.add(slot);
      }
    });

    if(_timeSlots.length>0){
      _orderTime = _timeSlots[0];
    }



    if(notify) {
     setState(() {

     });
    }
  }

  AdvancedOrderButtonDialog(List<RestaurantScheduleTime> _timeList) {
    _timeSlots = [];
    _allTimeSlots = [];
    DateTime _start ;
    DateTime _end ;

    DateTime _now = DateTime.now();
    int _minutes = 0;

    int _duration = Provider.of<SplashProvider>(context, listen: false).configModel.scheduleOrderSlotDuration;
    final timeList =  Provider.of<SplashProvider>(context, listen: false).configModel.restaurantScheduleTime;

    for(int index = 0; index < timeList.length; index++) {
      DateTime _openTime = DateTime(
        _now.year,
        _now.month,
        _now.day,
        DateConverter.convertStringTimeToDate(timeList[index].openingTime).hour,
        DateConverter.convertStringTimeToDate(timeList[index].openingTime).minute,
      );

      DateTime _closeTime = DateTime(
        _now.year,
        _now.month,
        _now.day,
        DateConverter.convertStringTimeToDate(timeList[index].closingTime).hour,
        DateConverter.convertStringTimeToDate(timeList[index].closingTime).minute,
      );

      if(_closeTime.difference(_openTime).isNegative) {
        _minutes = _openTime.difference(_closeTime).inMinutes;
      }else {
        _minutes = _closeTime.difference(_openTime).inMinutes;
      }
      if(_duration > 0 && _minutes > _duration) {
        DateTime _time = _openTime;
        for(;;) {
          if(_time.isBefore(_closeTime)) {
            DateTime _start = _time;
            DateTime _end = _start.add(Duration(minutes: _duration));
            if(_end.isAfter(_closeTime)) {
              _end = _closeTime;
            }
            _timeSlots.add(TimeSlotModel(day: int.tryParse(timeList[index].day), startTime: _start, endTime: _end));
            _allTimeSlots.add(TimeSlotModel(day: int.tryParse(timeList[index].day), startTime: _start, endTime: _end));
            _time = _time.add(Duration(minutes: _duration));
          }else {
            break;
          }
        }
      }else {
        _timeSlots.add(TimeSlotModel(day: int.tryParse(timeList[index].day), startTime: _openTime, endTime: _closeTime));
        _allTimeSlots.add(TimeSlotModel(day: int.tryParse(timeList[index].day), startTime: _openTime, endTime: _closeTime));
      }
    }



    validateSlot(_allTimeSlots, 0, notify: false);

    /*for(var item in timeList){

      _start = DateConverter.convertStringTimeToDate(item.openingTime).hour as DateTime;
      _end = DateConverter.convertStringTimeToDate(item.closingTime).minute as DateTime;
      _timeSlots.add(TimeSlotModel(day: int.tryParse(item.day), startTime: _start, endTime: _end));
    }*/
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      //transitionDuration: Duration(milliseconds: 500),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              backgroundColor: Colors.black38,

              content: Container(
                alignment: Alignment.center,
                height: _dialogHeight,
                width: _dialogWidth,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   // Container(height: MediaQuery.of(context).size.height*.2,),
                    Container(
                     // width: MediaQuery.of(context).size.height * .9,
                      alignment: Alignment.center,
                      child: Text(

                          "We're Sorry, Pizza Corner Belfied in not currently\n open for Delivery and Pickup. You Can place\n and advance order for Today!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17
                        ),
                      ),
                    ),
                    Container(height: 10,),
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                        AdvancedOrderDialog(_dialogWidth);

                        setState(() {

                        });

                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        decoration: BoxDecoration(
                            color:Color(0xFFE01F26),
                            border: Border.all(color: Color(0xFFFFFFFF)),
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Advance Order Now",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  /*  Container(
                      width: MediaQuery.of(context).size.width*.3,
                      height: 50,
                      //color: Colors.,
                      //padding: const EdgeInsets.symmetric(horizontal: 60.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color(0xFFE01F26),
                              minimumSize: Size(MediaQuery.of(context).size.width*.3, 50),
                              maximumSize: Size(MediaQuery.of(context).size.width*.3, 50),
                              shadowColor: Color(0xff763637),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(9)),
                              )


                          ),
                          onPressed: (){
                            Navigator.pop(context);
                            AdvancedOrderDialog();
                          }, child: Text('Advance Order Now')),
                    ),*/

                    Container(height: 10,),
                    Container(
                      width: MediaQuery.of(context).size.height * .9,
                      alignment: Alignment.center,
                      child: Text(
                        "Current Date & Time "+DateTime.now().toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15
                    ),),),

                    /*Container(
                      width: MediaQuery.of(context).size.height * .9,
                      alignment: Alignment.center,
                      child: Text("\n----Opening Hours----",style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17
                    ),),),
                    Container(
                      width: MediaQuery.of(context).size.height * .9,
                      alignment: Alignment.center,
                      child: Text(
                        '${DateConverter.dateToTimeOnly(_timeSlots[0].startTime, context)} '
                          '- ${DateConverter.dateToTimeOnly(_timeSlots[0].endTime, context)}',
                        style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17
                    ),),),*/

                   /* SizedBox(
                      height: 280,
                      child: _timeSlots != null ? _timeSlots.length > 0 ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                        itemCount: _timeSlots.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.height * .9,
                            alignment: Alignment.center,
                            child: Text(
                              '${_timeSlots[index].day}\n'
                                '${DateConverter.dateToTimeOnly(_timeSlots[index].startTime, context)} '
                                    '- ${DateConverter.dateToTimeOnly(_timeSlots[index].endTime, context)}',
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                          );
                            SlotWidget(
                            title: (
                              '${DateConverter.dateToTimeOnly(_timeSlots[index].startTime, context)} '
                                  '- ${DateConverter.dateToTimeOnly(_timeSlots[index].endTime, context)}'),
                            isSelected: false,
                            onTap: () {
                             // order.updateTimeSlot(index),
                            }
                          );
                        },
                      ) : Center(child: Text(getTranslated('no_slot_available', context))) : Center(child: CircularProgressIndicator()),
                    ),*/
                  ],
                ),
              ),
              actions: [],
            );
          },
        );
      },
    ).then((value) {
      setState(() {

      });
    });
  }

  AdvancedOrderDialog(double width) {
    _dialogWidth = MediaQuery.of(context).size.width*.4;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Consumer<OrderProvider>(
              builder: (context, order, child) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(_dialogPadding),
                  backgroundColor: Color(0x84000000),
                  content: Container(
                    //padding: EdgeInsets.symmetric(horizontal: _dialogPadding),
                      height: _dialogHeight,
                      width: width,
                      child:Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(

                              height: 120,
                              width: width * .98,
                              alignment: Alignment.center ,
                              child: Text(
                                "What time would like your Order?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                /*Expanded(
                                  flex: 1,
                                  child: Container(

                                  ),
                                ),*/
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: EdgeInsets.zero,
                                    //width: MediaQuery.of(context).size.width*.3,
                                    child: DropdownButton<String>(
                                      value: _orderDate,
                                      items: <String>['Today', 'Tomorrow'].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,style: TextStyle(fontSize:14,color: Color(0xFFE01F26),),),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        _orderDate = value;
                                        updateDateSlot(value=="Today"?0:1);
                                       // order.selectDateSlot == (value=="Today"?0:1);
                                       // order.updateDateSlot(value=="Today"?0:1);

                                         setModalState(() {
                                           DELIVERYDAY = value;
                                         });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4,),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding: EdgeInsets.zero,
                                    child:_timeSlots.length>0?DropdownButton<TimeSlotModel>(
                                      value: _orderTime,
                                      items:  _timeSlots.map((TimeSlotModel value) {
                                        return DropdownMenuItem<TimeSlotModel>(
                                          value: value,
                                          child: Text(
                                            '${DateConverter.dateToTimeOnly(value.startTime, context)} '
                                              '- ${DateConverter.dateToTimeOnly(value.endTime, context)}',style: TextStyle(fontSize:14,color: Color(0xFFE01F26,),),

                                          ),

                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        _orderTime = value;

                                        setModalState(() {
                                          DELIVERYTIME = _timeSlots.indexOf(value);
                                        });
                                      },
                                    ):Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Restaurant is close "+_orderDate,
                                        style: TextStyle(color: Color(0xffffffff)),
                                      ),
                                    ),
                                  ),
                                ),
                               /* Expanded(
                                  flex: 1,
                                  child: Container(

                                  ),
                                ),*/
                              ],
                            ),
                            Container(height: 10,),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Color(0xFFE01F26),
                                    minimumSize: Size(250,75),
                                    shadowColor: Color(0xff763637),

                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(9)),
                                    )


                                ),
                                onPressed: (){
                                  if(_timeSlots.length>0){
                                    DELIVERYTIME = _timeSlots.indexOf(_orderTime);
                                    DELIVERYDAY = _orderDate;
                                    order.updateTimeSlot(_timeSlots.indexOf(_orderTime));
                                    order.updateDateSlot(_orderDate=="Today"?0:1);
                                    order.selectDateSlot = (_orderDate=="Today"?0:1);
                                    order.selectTimeSlot = (_timeSlots.indexOf(_orderTime));
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delivery time not selected"),
                                        backgroundColor: Colors.red));
                                  }


                                  Navigator.pop(context);

                                }, child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Text('Continue Your Order Details'),
                            )),
                          ],
                        ),
                      )
                  ),
                  actions: [],
                );
              },
            );


          }
        );
      },
    );
  }


}
//ResponsiveHelper
class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 60 || oldDelegate.minExtent != 60 || child != oldDelegate.child;
  }
}
