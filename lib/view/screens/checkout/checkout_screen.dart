import 'dart:collection';
import 'dart:convert'as convert;

import 'package:flutter_restaurant/data/model/response/base/delivery_address_model.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/provider/localization_provider.dart';
import 'package:flutter_restaurant/view/screens/cart/cart_screen.dart';
import 'package:flutter_restaurant/view/screens/cart/widget/delivery_option_button.dart';
import 'package:flutter_restaurant/view/screens/dashboard/dashboard_screen.dart';

import 'dart:typed_data';
import 'dart:ui';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_restaurant/data/model/body/place_order_body.dart';
import 'package:flutter_restaurant/data/model/response/address_model.dart';
import 'package:flutter_restaurant/data/model/response/cart_model.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/data/model/response/signup_model.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/coupon_provider.dart';
import 'package:flutter_restaurant/provider/location_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/product_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_divider.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/address/add_new_address_screen.dart';
import 'package:flutter_restaurant/view/screens/auth/widget/code_picker_widget.dart';
import 'package:flutter_restaurant/view/screens/auth/widget/social_login_checkout_widget.dart';
import 'package:flutter_restaurant/view/screens/checkout/order_successful_guest_screen.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/custom_check_box.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/delivery_fee_dialog.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/slot_widget.dart';
import 'package:flutter_restaurant/view/screens/home/home_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class CheckoutScreen extends StatefulWidget {
  final double amount;
  final String orderType;
  final List<CartModel> cartList;
  final bool fromCart;
  final String couponCode;
  CheckoutScreen({ @required this.amount, @required this.orderType, @required this.fromCart,
    @required this.cartList, @required this.couponCode});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}
double orderAmount = 0;
bool _isLoggedIn;
class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _noteController = TextEditingController();
  GoogleMapController _mapController;
  bool _isCashOnDeliveryActive = false;
  bool _isDigitalPaymentActive = false;
  List<Branches> _branches = [];
  bool _loading = true;
  Set<Marker> _markers = HashSet<Marker>();

  List<CartModel> _cartList;
  //String deliveryAddress = "19-21 King St, ENFIELD, 2136, NSW";
  String deliveryTime = "";

  //new added
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _countryDialCode;

  DeliveryAddressModel deliveryAddressModel;
  AddressModel addressModel;
  int _pageIndex = 0;
  PageController _pageController;

  @override
  void initState() {

    SharedPreferences.getInstance().then((prefs) => {
      _firstNameController.text = prefs.getString('first_name'),
      _lastNameController.text = prefs.getString('last_name'),
      _emailController.text = prefs.getString('email'),
      _numberController.text = prefs.getString('phone'),

      prefs.remove('first_name'),
      prefs.remove('last_name'),
      prefs.remove('email'),
      prefs.remove('phone')
    });

    _pageController = PageController(initialPage: 0);
    orderAmount = widget.amount;
    super.initState();
    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(GuestAddress.length>5){
      addressModel =  AddressModel.fromJson(convert.jsonDecode(GuestAddress));
    }


    if(_isLoggedIn) {
      Provider.of<OrderProvider>(context, listen: false).initializeTimeSlot(context).then((value) {
        Provider.of<OrderProvider>(context, listen: false).sortTime();
      });
      _branches = Provider.of<SplashProvider>(context, listen: false).configModel.branches;
      if(Provider.of<ProfileProvider>(context, listen: false).userInfoModel == null) {
        Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);
      }
      Provider.of<LocationProvider>(context, listen: false).initAddressList(context);


      Provider.of<OrderProvider>(context, listen: false).clearPrevData();
      _isCashOnDeliveryActive = Provider.of<SplashProvider>(context, listen: false).configModel.cashOnDelivery == 'true';
      _isDigitalPaymentActive = Provider.of<SplashProvider>(context, listen: false).configModel.digitalPayment == 'true';
      _cartList = [];
      widget.fromCart ? _cartList.addAll(Provider.of<CartProvider>(context, listen: false).cartList) : _cartList.addAll(widget.cartList);
    }else{
      Provider.of<OrderProvider>(context, listen: false).initializeTimeSlot(context).then((value) {
        Provider.of<OrderProvider>(context, listen: false).sortTime();
      });
      _branches = Provider.of<SplashProvider>(context, listen: false).configModel.branches;
     /* if(Provider.of<ProfileProvider>(context, listen: false).userInfoModel == null) {
        Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);
      }
      Provider.of<LocationProvider>(context, listen: false).initAddressList(context);


      Provider.of<OrderProvider>(context, listen: false).clearPrevData();*/
      _isCashOnDeliveryActive = Provider.of<SplashProvider>(context, listen: false).configModel.cashOnDelivery == 'true';
      _isDigitalPaymentActive = Provider.of<SplashProvider>(context, listen: false).configModel.digitalPayment == 'true';
      _cartList = [];
      widget.fromCart ? _cartList.addAll(Provider.of<CartProvider>(context, listen: false).cartList) : _cartList.addAll(widget.cartList);
    }

    _countryDialCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel.countryCode).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    final _configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    final _height = MediaQuery.of(context).size.height;
    bool _kmWiseCharge = _configModel.deliveryManagement.status == 1;

    return Scaffold(
      key: _scaffoldKey,
      appBar: ResponsiveHelper.isDesktop(context) ? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(100)) :
      AppBar(
       // floating: true,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).cardColor,
       // pinned: ResponsiveHelper.isTab(context) ? true : false,
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
                Icon(Icons.shopping_cart, color: Theme.of(context).textTheme.bodyText1.color),
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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) =>  SafeArea(
          child: _isLoggedIn ? Consumer<OrderProvider>(
            builder: (context, order, child) {
              double _deliveryCharge = 0;


              if(order.orderType=="delivery" && _kmWiseCharge) {
                _deliveryCharge = order.distance * _configModel.deliveryManagement.shippingPerKm;
                if(_deliveryCharge < _configModel.deliveryManagement.minShippingCharge) {
                  _deliveryCharge = _configModel.deliveryManagement.minShippingCharge;
                }
              }else if(order.orderType=="delivery" && !_kmWiseCharge) {
                _deliveryCharge = _configModel.deliveryCharge;
              }
              return Consumer<LocationProvider>(
                builder: (context, address, child) {
                  return Column(
                    children: [
                      !ResponsiveHelper.isDesktop(context)?InkWell(
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
                      ):Container(),

                      Expanded(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
                                  child: Center(
                                    child: SizedBox(
                                      width: 1170,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              margin: ResponsiveHelper.isDesktop(context) ?  EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
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
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                                _branches.length > 0 ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                    child: Text(getTranslated('select_branch', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                  ),

                                                  SizedBox(
                                                    height: 50,
                                                    child: ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                                      physics: BouncingScrollPhysics(),
                                                      itemCount: _branches.length,
                                                      itemBuilder: (context, index) {
                                                        return Padding(
                                                          padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                                                          child: InkWell(
                                                            onTap: () {
                                                              order.setBranchIndex(index);
                                                              _setMarkers(index);
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                                                              alignment: Alignment.center,
                                                              decoration: BoxDecoration(
                                                                color: index == order.branchIndex ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
                                                                borderRadius: BorderRadius.circular(5),
                                                              ),
                                                              child: Text(_branches[index].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: rubikMedium.copyWith(
                                                                color: index == order.branchIndex ? Colors.white : Theme.of(context).textTheme.bodyText1.color,
                                                              )),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ]) : SizedBox(),

                                                // Address
                                                order.orderType=="delivery" ? Column(children: [
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                                    child: Row(children: [
                                                      Text(getTranslated('delivery_address', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                      Expanded(child: SizedBox()),
                                                      TextButton.icon(
                                                        style: TextButton.styleFrom(
                                                            backgroundColor: Colors.white
                                                        ),
                                                        onPressed: () => _checkPermission(context, Routes.getAddAddressRoute('checkout', 'add', AddressModel(),'default')),
                                                        icon: Icon(Icons.add,color: Colors.black,),
                                                        label: Text(getTranslated('add', context), style: rubikRegular,),
                                                      ),
                                                    ]),
                                                  ),

                                                  SizedBox(
                                                    height: 60,
                                                    child: address.addressList != null ? address.addressList.length > 0 ? ListView.builder(
                                                      physics: BouncingScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                                                      itemCount: address.addressList.length,
                                                      itemBuilder: (context, index) {
                                                        bool _isAvailable = _branches.length == 1 && (_branches[0].latitude == null || _branches[0].latitude.isEmpty);
                                                        if(!_isAvailable) {
                                                          double _distance = Geolocator.distanceBetween(
                                                            double.parse(_branches[order.branchIndex].latitude), double.parse(_branches[order.branchIndex].longitude),
                                                            double.parse(address.addressList[index].latitude), double.parse(address.addressList[index].longitude),
                                                          ) / 1000;
                                                          _isAvailable = _distance < _branches[order.branchIndex].coverage;
                                                        }
                                                        return Padding(
                                                          padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                                                          child: InkWell(
                                                            onTap: () async {
                                                              if(_isAvailable) {
                                                                order.setAddressIndex(index);
                                                                if(_kmWiseCharge) {
                                                                  showDialog(context: context, builder: (context) => Center(child: Container(
                                                                    height: 100, width: 100, decoration: BoxDecoration(
                                                                    color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                                                                  ),
                                                                    alignment: Alignment.center,
                                                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                                                                  )), barrierDismissible: false);
                                                                  bool _isSuccess = await order.getDistanceInMeter(
                                                                    LatLng(
                                                                      double.parse(_branches[order.branchIndex].latitude),
                                                                      double.parse(_branches[order.branchIndex].longitude),
                                                                    ),
                                                                    LatLng(
                                                                      double.parse(address.addressList[index].latitude),
                                                                      double.parse(address.addressList[index].longitude),
                                                                    ),
                                                                  );
                                                                  Navigator.pop(context);
                                                                  if(_isSuccess) {
                                                                    showDialog(context: context, builder: (context) => DeliveryFeeDialog(
                                                                      amount:orderAmount, distance: order.distance,
                                                                    ));
                                                                  }else {
                                                                    showCustomSnackBar(getTranslated('failed_to_fetch_distance', context), context);
                                                                  }
                                                                }
                                                              }
                                                            },
                                                            child: Stack(children: [
                                                              Container(
                                                                height: 60,
                                                                width: 200,
                                                                decoration: BoxDecoration(
                                                                  color: index == order.addressIndex ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  border: index == order.addressIndex ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
                                                                ),
                                                                child: Row(children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                    child: Icon(
                                                                      address.addressList[index].addressType == 'Home' ? Icons.home_outlined
                                                                          : address.addressList[index].addressType == 'Workplace' ? Icons.work_outline : Icons.list_alt_outlined,
                                                                      color: index == order.addressIndex ? Theme.of(context).primaryColor
                                                                          : Theme.of(context).textTheme.bodyText1.color,
                                                                      size: 30,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                      Text(address.addressList[index].addressType, style: rubikRegular.copyWith(
                                                                        fontSize: Dimensions.FONT_SIZE_SMALL, color: ColorResources.getGreyBunkerColor(context),
                                                                      )),
                                                                      Text(address.addressList[index].address, style: rubikRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
                                                                    ]),
                                                                  ),
                                                                  index == order.addressIndex ? Align(
                                                                    alignment: Alignment.topRight,
                                                                    child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                                                                  ) : SizedBox(),
                                                                ]),
                                                              ),
                                                              !_isAvailable ? Positioned(
                                                                top: 0, left: 0, bottom: 0, right: 0,
                                                                child: Container(
                                                                  alignment: Alignment.center,
                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black.withOpacity(0.6)),
                                                                  child: Text(
                                                                    getTranslated('out_of_coverage_for_this_branch', context),
                                                                    textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                                                                    style: rubikRegular.copyWith(color: Colors.white, fontSize: 10),
                                                                  ),
                                                                ),
                                                              ) : SizedBox(),
                                                            ]),
                                                          ),
                                                        );
                                                      },
                                                    ) : Center(child: Text(getTranslated('no_address_available', context)))
                                                        : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                                                  ),
                                                  SizedBox(height: 20),
                                                ]) : SizedBox(),

                                                // Time Slot
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                                  child: Text(getTranslated('preference_time', context), style: rubikMedium),
                                                ),
                                                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                                SizedBox(
                                                  height: 50,
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    shrinkWrap: true,
                                                    physics: BouncingScrollPhysics(),
                                                    padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                                                    itemCount: 2,
                                                    itemBuilder: (context, index) {
                                                      return SlotWidget(
                                                        title: index == 0 ? getTranslated('today', context) : getTranslated('tomorrow', context),
                                                        isSelected: order.selectDateSlot == index,
                                                        onTap: () {
                                                          order.updateDateSlot(index);
                                                          DELIVERYDAY = '';
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                                SizedBox(
                                                  height: 50,
                                                  child: order.timeSlots != null ? order.timeSlots.length > 0 ? ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    shrinkWrap: true,
                                                    physics: BouncingScrollPhysics(),
                                                    padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                                                    itemCount: order.timeSlots.length,
                                                    itemBuilder: (context, index) {
                                                      /* if(DELIVERYTIME !=null){
                                                            order.updateTimeSlot(DELIVERYTIME);
                                                            order.selectTimeSlot = DELIVERYTIME;
                                                          }*/
                                                      return SlotWidget(
                                                        title: (
                                                            index == 0 && order.selectDateSlot == 0  && Provider.of<SplashProvider>(context, listen: false).isRestaurantOpenNow(context))
                                                            ? getTranslated('now', context)
                                                            : '${DateConverter.dateToTimeOnly(order.timeSlots[index].startTime, context)} '
                                                            '- ${DateConverter.dateToTimeOnly(order.timeSlots[index].endTime, context)}',
                                                        isSelected: order.selectTimeSlot == index,
                                                        onTap: () => order.updateTimeSlot(index),
                                                      );
                                                    },
                                                  ) : Center(child: Text(getTranslated('no_slot_available', context))) : Center(child: CircularProgressIndicator()),
                                                ),
                                                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                                                if (!ResponsiveHelper.isDesktop(context))  detailsWidget(authProvider,context, _kmWiseCharge, order.orderType=="delivery", order, _deliveryCharge, address),






                                              ]),
                                            ),
                                          ),
                                          if(ResponsiveHelper.isDesktop(context)) Expanded(
                                            flex: 4,
                                            child: Container(
                                              padding: ResponsiveHelper.isDesktop(context) ?   EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
                                              margin: ResponsiveHelper.isDesktop(context) ?  EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
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
                                              child: detailsWidget(
                                                  authProvider,context, _kmWiseCharge, order.orderType=="delivery", order, _deliveryCharge, address),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if(ResponsiveHelper.isDesktop(context)) SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                if(ResponsiveHelper.isDesktop(context)) FooterView(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if(!ResponsiveHelper.isDesktop(context) &&  Provider.of<CartProvider>(context, listen: false).cartList.length>0)  confirmButtonWidget(authProvider,order, address, _kmWiseCharge, _deliveryCharge, context),

                    ],
                  );
                },
              );
            },
          ) : Consumer<OrderProvider>(
            builder: (context, order, child) {

              double _deliveryCharge = 0;

              if(order.orderType=="delivery" && _kmWiseCharge) {
                _deliveryCharge = order.distance * _configModel.deliveryManagement.shippingPerKm;
                if(_deliveryCharge < _configModel.deliveryManagement.minShippingCharge) {
                  _deliveryCharge = _configModel.deliveryManagement.minShippingCharge;

                }
              }else if(order.orderType=="delivery" && !_kmWiseCharge) {
                _deliveryCharge = _configModel.deliveryCharge;

              }
              return Consumer<LocationProvider>(
                builder: (context, address, childd) {
                  return Column(
                    children: [
                      !ResponsiveHelper.isDesktop(context)?InkWell(
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
                      ):Container(),
                      Expanded(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
                                  child: Center(
                                    child: SizedBox(
                                      width: 1170,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              margin: ResponsiveHelper.isDesktop(context) ?  EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
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
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                //login via login system
                                                ResponsiveHelper.isDesktop(context) ?
                                                webUserInfo():mobileUserInfo(),
                                                _branches.length > 0 ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                    child: Text(getTranslated('select_branch', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                  ),

                                                  SizedBox(
                                                    height: 50,
                                                    child: ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                                      physics: BouncingScrollPhysics(),
                                                      itemCount: _branches.length,
                                                      itemBuilder: (context, index) {

                                                        return Padding(
                                                          padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                                                          child: InkWell(
                                                            onTap: () {
                                                              order.setBranchIndex(index);
                                                              _setMarkers(index);
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                                                              alignment: Alignment.center,
                                                              decoration: BoxDecoration(
                                                                color: index == order.branchIndex ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
                                                                borderRadius: BorderRadius.circular(5),
                                                              ),
                                                              child: Text(_branches[index].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: rubikMedium.copyWith(
                                                                color: index == order.branchIndex ? Colors.white : Theme.of(context).textTheme.bodyText1.color,
                                                              )),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ]) : SizedBox(),

                                                // Address
                                                order.orderType=="delivery" ? Column(children: [
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                                    child: Row(children: [
                                                      Text(getTranslated('delivery_address', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                                      Expanded(child: SizedBox()),
                                                      TextButton.icon(
                                                        style: TextButton.styleFrom(
                                                            backgroundColor: Colors.white
                                                        ),
                                                        onPressed: (){
                                                          TOTALDeliveryFee = orderAmount;
                                                          SharedPreferences.getInstance().then((prefs) => {
                                                            prefs.setString('first_name', _firstNameController.text),
                                                            prefs.setString('last_name', _lastNameController.text),
                                                            prefs.setString('email', _emailController.text),
                                                            prefs.setString('phone', _numberController.text),
                                                          });
                                                          _checkPermission(
                                                              context,
                                                              Routes.getAddAddressRoute('checkout', 'add', AddressModel(),'guest'));
                                                        },
                                                        icon: !(addressModel != null && addressModel.address.length<3)?Icon(
                                                          Icons.edit,color: Colors.black,
                                                        ):Icon(
                                                          Icons.add,
                                                          color: Colors.black,
                                                        ),

                                                        label: Text(!(addressModel != null && addressModel.address.length<3)?"Change":getTranslated('add', context), style: TextStyle(
                                                          fontFamily: 'Rubik',
                                                          fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                                          fontWeight: FontWeight.w400,
                                                          color: Colors.black,
                                                        )),
                                                      ),
                                                    ]),
                                                  ),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                                    alignment: Alignment.centerLeft,
                                                    child:Row(
                                                      children: [
                                                        Icon(Icons.location_on_sharp,size: 22,),
                                                        Text(DELIVERY_ADDRESS??"",style: rubikMedium),
                                                        //Text(DELIVERY_ADDRESS, style: rubikMedium),
                                                      ],
                                                    ),
                                                  ),
                                                  //address
                                                  /* SizedBox(
                                                    height: 60,
                                                    child: address.addressList != null ? address.addressList.length > 0 ? ListView.builder(
                                                      physics: BouncingScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                                                      itemCount: address.addressList.length,
                                                      itemBuilder: (context, index) {
                                                        bool _isAvailable = _branches.length == 1 && (_branches[0].latitude == null || _branches[0].latitude.isEmpty);
                                                        if(!_isAvailable) {
                                                          double _distance = Geolocator.distanceBetween(
                                                            double.parse(_branches[order.branchIndex].latitude), double.parse(_branches[order.branchIndex].longitude),
                                                            double.parse(address.addressList[index].latitude), double.parse(address.addressList[index].longitude),
                                                          ) / 1000;
                                                          _isAvailable = _distance < _branches[order.branchIndex].coverage;
                                                        }
                                                        return Padding(
                                                          padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                                                          child: InkWell(
                                                            onTap: () async {
                                                              if(_isAvailable) {
                                                                order.setAddressIndex(index);
                                                                if(_kmWiseCharge) {
                                                                  showDialog(context: context, builder: (context) => Center(child: Container(
                                                                    height: 100, width: 100, decoration: BoxDecoration(
                                                                    color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                                                                  ),
                                                                    alignment: Alignment.center,
                                                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                                                                  )), barrierDismissible: false);
                                                                  bool _isSuccess = await order.getDistanceInMeter(
                                                                    LatLng(
                                                                      double.parse(_branches[order.branchIndex].latitude),
                                                                      double.parse(_branches[order.branchIndex].longitude),
                                                                    ),
                                                                    LatLng(
                                                                      double.parse(address.addressList[index].latitude),
                                                                      double.parse(address.addressList[index].longitude),
                                                                    ),
                                                                  );
                                                                  Navigator.pop(context);
                                                                  if(_isSuccess) {
                                                                    showDialog(context: context, builder: (context) => DeliveryFeeDialog(
                                                                      amount: orderAmount, distance: order.distance,
                                                                    ));
                                                                  }else {
                                                                    showCustomSnackBar(getTranslated('failed_to_fetch_distance', context), context);
                                                                  }
                                                                }
                                                              }
                                                            },
                                                            child: Stack(children: [
                                                              Container(
                                                                height: 60,
                                                                width: 200,
                                                                decoration: BoxDecoration(
                                                                  color: index == order.addressIndex ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  border: index == order.addressIndex ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
                                                                ),
                                                                child: Row(children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                    child: Icon(
                                                                      address.addressList[index].addressType == 'Home' ? Icons.home_outlined
                                                                          : address.addressList[index].addressType == 'Workplace' ? Icons.work_outline : Icons.list_alt_outlined,
                                                                      color: index == order.addressIndex ? Theme.of(context).primaryColor
                                                                          : Theme.of(context).textTheme.bodyText1.color,
                                                                      size: 30,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                      Text(address.addressList[index].addressType, style: rubikRegular.copyWith(
                                                                        fontSize: Dimensions.FONT_SIZE_SMALL, color: ColorResources.getGreyBunkerColor(context),
                                                                      )),
                                                                      Text(address.addressList[index].address, style: rubikRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
                                                                    ]),
                                                                  ),
                                                                  index == order.addressIndex ? Align(
                                                                    alignment: Alignment.topRight,
                                                                    child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                                                                  ) : SizedBox(),
                                                                ]),
                                                              ),
                                                              !_isAvailable ? Positioned(
                                                                top: 0, left: 0, bottom: 0, right: 0,
                                                                child: Container(
                                                                  alignment: Alignment.center,
                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black.withOpacity(0.6)),
                                                                  child: Text(
                                                                    getTranslated('out_of_coverage_for_this_branch', context),
                                                                    textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                                                                    style: rubikRegular.copyWith(color: Colors.white, fontSize: 10),
                                                                  ),
                                                                ),
                                                              ) : SizedBox(),
                                                            ]),
                                                          ),
                                                        );
                                                      },
                                                    ) : Center(child: Text(getTranslated('no_address_available', context)))
                                                        : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                                                  ),*/
                                                  SizedBox(height: 20),
                                                ]) : SizedBox(),

                                                // Time Slot
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                                  child: Text(getTranslated('preference_time', context), style: rubikMedium),
                                                ),
                                                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                                SizedBox(
                                                  height: 50,
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    shrinkWrap: true,
                                                    physics: BouncingScrollPhysics(),
                                                    padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                                                    itemCount: 2,
                                                    itemBuilder: (context, index) {
                                                      /*if(DELIVERYDAY.length>2){
                                                            order.updateDateSlot(DELIVERYDAY=="Tomorrow"?1:0);
                                                            // order.updateDateSlot(DELIVERYDAY=="Today"?0:1);
                                                          }*/
                                                      return SlotWidget(
                                                        title: index == 0 ? getTranslated('today', context) : getTranslated('tomorrow', context),
                                                        isSelected: order.selectDateSlot == index,
                                                        onTap: () {
                                                          order.updateDateSlot(index);
                                                          DELIVERYDAY = '';
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                                SizedBox(
                                                  height: 50,
                                                  child: order.timeSlots != null ? order.timeSlots.length > 0 ? ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    shrinkWrap: true,
                                                    physics: BouncingScrollPhysics(),
                                                    padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                                                    itemCount: order.timeSlots.length,
                                                    itemBuilder: (context, index) {
                                                      /*if(DELIVERYTIME<5){
                                                            if(order.timeSlots.length>0){

                                                              order.updateTimeSlot(DELIVERYTIME);
                                                            }
                                                          }*/


                                                      return SlotWidget(
                                                        title: (
                                                            index == 0 && order.selectDateSlot == 0  && Provider.of<SplashProvider>(context, listen: false).isRestaurantOpenNow(context))
                                                            ? getTranslated('now', context)
                                                            : '${DateConverter.dateToTimeOnly(order.timeSlots[index].startTime, context)} '
                                                            '- ${DateConverter.dateToTimeOnly(order.timeSlots[index].endTime, context)}',
                                                        isSelected: order.selectTimeSlot == index,
                                                        onTap: () {
                                                          DELIVERYTIME = 420;
                                                          order.updateTimeSlot(index);
                                                        },
                                                      );
                                                    },
                                                  ) : Center(child: Text(getTranslated('no_slot_available', context))) : Center(child: CircularProgressIndicator()),
                                                ),
                                                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                                                if (!ResponsiveHelper.isDesktop(context))  detailsWidget(authProvider,context, _kmWiseCharge, order.orderType=="delivery", order, _deliveryCharge, address),
                                              ]),
                                            ),
                                          ),
                                          if(ResponsiveHelper.isDesktop(context)) Expanded(
                                            flex: 4,
                                            child: Container(
                                              padding: ResponsiveHelper.isDesktop(context) ?   EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
                                              margin: ResponsiveHelper.isDesktop(context) ?  EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(0),
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
                                              child: detailsWidget(
                                                  authProvider,context, _kmWiseCharge, order.orderType=="delivery", order, _deliveryCharge, address),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if(ResponsiveHelper.isDesktop(context)) SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                if(ResponsiveHelper.isDesktop(context)) FooterView(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if(!ResponsiveHelper.isDesktop(context) &&  Provider.of<CartProvider>(context, listen: false).cartList.length>0)  confirmButtonWidget(authProvider,order,  address, _kmWiseCharge, _deliveryCharge, context),

                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: ResponsiveHelper.isMobile(context) ? BottomNavigationBar(
        selectedItemColor: ColorResources.COLOR_GREY,
        unselectedItemColor: ColorResources.COLOR_GREY,
        showUnselectedLabels: true,
        currentIndex: _pageIndex,
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



  mobileUserInfo(){
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         // Center(child: SocialLoginCheckoutWidget("checkout")),
          // for first name section
          Text(
            getTranslated('first_name', context),
            style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          CustomTextField(
            hintText: 'John',
            isShowBorder: true,
            controller: _firstNameController,
            focusNode: _firstNameFocus,
            nextFocus: _lastNameFocus,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          // for last name section
          Text(
            getTranslated('last_name', context),
            style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          Provider.of<SplashProvider>(context, listen: false).configModel.emailVerification?
          CustomTextField(
            hintText: 'Doe',
            isShowBorder: true,
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            nextFocus: _numberFocus,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ):CustomTextField(
            hintText: 'Doe',
            isShowBorder: true,
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            nextFocus: _emailFocus,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          //phone section
          Text(
            getTranslated('mobile_number', context),
            style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
          ),
          Row(children: [
            CodePickerWidget(
              onChanged: (CountryCode countryCode) {
                _countryDialCode = countryCode.dialCode;
              },
              initialSelection: _countryDialCode,
              favorite: [_countryDialCode],
              countryFilter: [_countryDialCode],
              enabled: false,
              showDropDownButton: false,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
              showFlagMain: true,
              textStyle: TextStyle(color: Theme.of(context).textTheme.headline1.color),

            ),
            Container(width:5),
            Expanded(child: CustomTextField(
              hintText: getTranslated('number_hint', context),
              isShowBorder: true,
              controller: _numberController,
              focusNode: _numberFocus,
              inputType: TextInputType.phone,
              inputAction: TextInputAction.done,
              fillColor: Colors.white,
            )),
          ]),

          // for email section
          Text(
            getTranslated('email', context),
            style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
          ),
          CustomTextField(
            hintText: getTranslated('demo_gmail', context),
            isShowBorder: true,
            controller: _emailController,
            focusNode: _emailFocus,
            inputType: TextInputType.emailAddress,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
        ],
      ),
    );
  }

  webUserInfo(){
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: SocialLoginCheckoutWidget("checkout")),

          // for first name section
          Text(
            getTranslated('first_name', context),
            style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          CustomTextField(
            hintText: 'John',
            isShowBorder: true,
            controller: _firstNameController,
            focusNode: _firstNameFocus,
            nextFocus: _lastNameFocus,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          // for last name section
          Text(
            getTranslated('last_name', context),
            style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          Provider.of<SplashProvider>(context, listen: false).configModel.emailVerification?
          CustomTextField(
            hintText: 'Doe',
            isShowBorder: true,
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            nextFocus: _numberFocus,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ):CustomTextField(
            hintText: 'Doe',
            isShowBorder: true,
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            nextFocus: _emailFocus,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),


          //phone section
          Text(
            getTranslated('mobile_number', context),
            style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
          ),
          Row(children: [
            Container(
              height: 40,
              child: CodePickerWidget(
                onChanged: (CountryCode countryCode) {
                  _countryDialCode = countryCode.dialCode;
                },
                initialSelection: _countryDialCode,
                favorite: [_countryDialCode],
                countryFilter: [_countryDialCode],
                enabled: false,
                showDropDownButton: true,
                padding: EdgeInsets.zero,
                showFlagMain: true,
                textStyle: TextStyle(color: Theme.of(context).textTheme.headline1.color),
                backgroundColor: Colors.grey,

              ),
            ),
            Container(width: 5,),
            Expanded(child: CustomTextField(
              hintText: getTranslated('number_hint', context),
              isShowBorder: true,
              controller: _numberController,
              focusNode: _numberFocus,
              inputType: TextInputType.phone,
              inputAction: TextInputAction.done,
            )),
          ]),

          // for email section
          Text(
            getTranslated('email', context),
            style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
          ),
          CustomTextField(
            hintText: getTranslated('demo_gmail', context),
            isShowBorder: true,
            controller: _emailController,
            focusNode: _emailFocus,
            inputType: TextInputType.emailAddress,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),



        ],
      ),
    );
  }

  Container confirmButtonWidget(AuthProvider authProvider,OrderProvider order, LocationProvider address, bool _kmWiseCharge, double _deliveryCharge, BuildContext context) {
    String _uuid = DateFormat('yyyyMMddHHmmss').format(DateConverter.now()).toString();
    return Container(
      width: 1170,
      alignment: Alignment.center,
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      child:Builder(
        builder: (context) => CustomButton(btnTxt: getTranslated('confirm_order', context),
            onTap: () async {

          if(_isLoggedIn){
            bool _isAvailable = true;
            DateTime _scheduleStartDate = DateConverter.now();
            DateTime _scheduleEndDate = DateConverter.now();
            if(order.timeSlots == null || order.timeSlots.length == 0) {
              _isAvailable = false;
            }
            else {
              DateTime _date = order.selectDateSlot == 0 ? DateConverter.now() : DateConverter.now().add(Duration(days: 1));
              DateTime _startTime = order.timeSlots[order.selectTimeSlot].startTime;
              DateTime _endTime = order.timeSlots[order.selectTimeSlot].endTime;
              _scheduleStartDate = DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute+1);
              _scheduleEndDate = DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute+1);
              for (CartModel cart in _cartList) {
                if (!DateConverter.isAvailable(cart.product.availableTimeStarts, cart.product.availableTimeEnds, context, time: _scheduleStartDate ?? null,)
                    && !DateConverter.isAvailable(cart.product.availableTimeStarts, cart.product.availableTimeEnds, context, time: _scheduleEndDate ?? null)
                ) {
                  _isAvailable = false;
                  break;
                }
              }
            }

            if(orderAmount < Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue) {
              showCustomSnackBar('Minimum order amount is ${Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue}', context);
            }
          else if (order.timeSlots == null || order.timeSlots.length == 0) {
              showCustomSnackBar(getTranslated('select_a_time', context), context);
            }
          else if (!_isAvailable) {
              showCustomSnackBar(getTranslated('one_or_more_products_are_not_available_for_this_selected_time', context), context);
            }
          else if (order.orderType=="delivery" && _kmWiseCharge && order.distance == -1) {
              showCustomSnackBar(getTranslated('delivery_fee_not_set_yet', context), context);
            }
            else {
              List<Cart> carts = [];
              double totalQuantity = 0;
              for (int index = 0; index < _cartList.length; index++) {
                CartModel cart = _cartList[index];
                totalQuantity += cart.quantity;
                List<int> _addOnIdList = [];
                List<int> _addOnQtyList = [];
                cart.addOnIds.forEach((addOn) {
                  _addOnIdList.add(addOn.id);
                  _addOnQtyList.add(addOn.quantity);
                });
                List<int> _allergiesList = [];
                cart.allergIds.forEach((allergies) {
                  _allergiesList.add(allergies.id);
                });
                carts.add(Cart(
                  cart.product.id.toString(), cart.discountedPrice.toString(), '', cart.variation,
                  cart.discountAmount, cart.quantity, cart.taxAmount, _addOnIdList,_allergiesList, _addOnQtyList,
                ));
              }

              if(order.orderType=="delivery" && order.addressIndex == -1){
                showCustomSnackBar('Please select an address', context);
                return;
              }

              if(totalQuantity % 1 != 0.00) {
                showCustomSnackBar('Please complete the Half/Half order.', context);
                return;
              }

              PlaceOrderBody _placeOrderBody = PlaceOrderBody(
                cart: carts,
                couponDiscountAmount: Provider.of<CouponProvider>(context, listen: false).discount,
                couponDiscountTitle: widget.couponCode.isNotEmpty ? widget.couponCode : null,
                deliveryAddressId: order.orderType=="delivery" ? (Provider.of<LocationProvider>(context, listen: false).addressList[order.addressIndex].id) : 0,
                //deliveryAddressId: 0,
                orderAmount: double.parse('${(orderAmount).toStringAsFixed(2)}'),
                orderNote: _noteController.text ?? '',
                orderType: order.orderType,
                paymentMethod: _isCashOnDeliveryActive ? order.paymentMethodIndex == 0 ? 'cash_on_delivery' : null : null,
                couponCode: widget.couponCode.isNotEmpty ? widget.couponCode : null, distance: order.orderType=="delivery" ? 0 : (order.distance>0?order.distance:0),
                branchId: _branches[order.branchIndex].id,
                deliveryDate: DateFormat('yyyy-MM-dd').format(_scheduleStartDate),
                deliveryTime: (order.selectTimeSlot == 0 && order.selectDateSlot == 0) ? 'now' : DateFormat('HH:mm').format(_scheduleStartDate),
                delivery_address: order.orderType=="delivery"?convert.jsonEncode(Provider.of<LocationProvider>(context, listen: false).addressList[order.addressIndex].toJson()):"",
                order_state: 'current',
              );

              if(_isCashOnDeliveryActive && Provider.of<OrderProvider>(context, listen: false).paymentMethodIndex == 0) {
                order.placeOrder(_placeOrderBody, _callback);
              }
              else {
                String hostname = html.window.location.hostname;
                String protocol = html.window.location.protocol;
                String port = html.window.location.port;
                final String _placeOrder =  convert.base64Url.encode(convert.utf8.encode(convert.jsonEncode(_placeOrderBody.toJson())));
                String _url = "customer_id=${Provider.of<ProfileProvider>(context, listen: false).userInfoModel.id}"
                    "&&callback=${AppConstants.BASE_URL}${Routes.ORDER_SUCCESS_SCREEN}&&order_amount=${(orderAmount).toStringAsFixed(2)}";

                String _webUrl = "customer_id=${Provider.of<ProfileProvider>(context, listen: false).userInfoModel.id}"
                    "&&callback=$protocol//$hostname:$port${Routes.ORDER_WEB_PAYMENT}&&order_amount=${(orderAmount).toStringAsFixed(2)}&&status=";

                String _tokenUrl = convert.base64Encode(convert.utf8.encode(ResponsiveHelper.isWeb() ? _webUrl : _url));
                String selectedUrl = '${AppConstants.BASE_URL}/payment-mobile?token=$_tokenUrl';
                if(ResponsiveHelper.isWeb()) {
                  order.clearPlaceOrder().then((_) {
                    order.setPlaceOrder(_placeOrder).then((value) => html.window.open(selectedUrl,"_self"));
                  });

                } else{
                  Navigator.pushReplacementNamed(context, Routes.getPaymentRoute(page: 'checkout',  selectAddress: _tokenUrl, placeOrderBody: _placeOrderBody));
                }
              }
            }
          }
          else{
            String _firstName = _firstNameController.text.trim();
            String _lastName = _lastNameController.text.trim();
            String _number = _countryDialCode+_numberController.text.trim();
            String _email = _emailController.text.trim();
            if (_firstName.isEmpty &&  _firstName.length<1) {
              showCustomSnackBar(getTranslated('enter_first_name', context), context);
              return;
            }else if (_lastName.isEmpty &&  _lastName.length<1) {
              showCustomSnackBar(getTranslated('enter_last_name', context), context);
              return;
            }else if (_numberController.text.trim().isEmpty && _numberController.text.trim().length<5) {
              showCustomSnackBar(getTranslated('enter_phone_number', context), context);
              return;
            }else if (_email.isEmpty &&  _email.length<7) {
              showCustomSnackBar(getTranslated('enter_valid_email', context), context);
              return;
            }else if (!(_email.contains('@') && _email.contains('.'))) {
              showCustomSnackBar("Email is not valid", context);
              return;
            }else{
              bool _isAvailable = true;
              DateTime _scheduleStartDate = DateConverter.now();
              DateTime _scheduleEndDate = DateConverter.now();
              if(order.timeSlots == null || order.timeSlots.length == 0) {
                _isAvailable = false;
              }
              else {
                DateTime _date = order.selectDateSlot == 0 ? DateConverter.now() : DateConverter.now().add(Duration(days: 1));
                DateTime _startTime = order.timeSlots[order.selectTimeSlot].startTime;
                DateTime _endTime = order.timeSlots[order.selectTimeSlot].endTime;
                _scheduleStartDate = DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute+1);
                _scheduleEndDate = DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute+1);
                for (CartModel cart in _cartList) {
                  if (!DateConverter.isAvailable(cart.product.availableTimeStarts, cart.product.availableTimeEnds, context, time: _scheduleStartDate ?? null,)
                      && !DateConverter.isAvailable(cart.product.availableTimeStarts, cart.product.availableTimeEnds, context, time: _scheduleEndDate ?? null)
                  ) {
                    _isAvailable = false;
                    break;
                  }
                }
              }

              if(orderAmount < Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue) {
                showCustomSnackBar('Minimum order amount is ${Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue}', context);
              }
              /*else if(order.orderType=="delivery" && (address.addressList == null || address.addressList.length == 0 || order.addressIndex < 0)) {
                showCustomSnackBar(getTranslated('select_an_address', context), context);
              }*/
              else if (order.timeSlots == null || order.timeSlots.length == 0) {
                showCustomSnackBar(getTranslated('select_a_time', context), context);
              }else if (!_isAvailable) {
                showCustomSnackBar(getTranslated('one_or_more_products_are_not_available_for_this_selected_time', context), context);
              }else if (order.orderType=="delivery" && _kmWiseCharge && order.distance == -1) {
                showCustomSnackBar(getTranslated('delivery_fee_not_set_yet', context), context);
              } else {
                /* delivery information */
                if(addressModel != null && addressModel.address != null &&  order.orderType=="delivery"){
                  if(addressModel.contactPersonName.isEmpty){
                    addressModel.contactPersonName = _firstName+' '+_lastName;
                    addressModel.contactPersonNumber = _number;
                    GuestAddress = convert.jsonEncode(addressModel.toJson());

                  }
                }


                List<Cart> carts = [];
                double totalQuantity = 0;
                for (int index = 0; index < _cartList.length; index++) {
                  CartModel cart = _cartList[index];
                  totalQuantity += cart.quantity;
                  List<int> _addOnIdList = [];
                  List<int> _addOnQtyList = [];
                  cart.addOnIds.forEach((addOn) {
                    _addOnIdList.add(addOn.id);
                    _addOnQtyList.add(addOn.quantity);
                  });
                  List<int> _allergiesList = [];
                  cart.allergIds.forEach((allergies) {
                    _allergiesList.add(allergies.id);
                  });

                  carts.add(Cart(
                    cart.product.id.toString(), cart.discountedPrice.toString(), '', cart.variation,
                    cart.discountAmount, cart.quantity, cart.taxAmount, _addOnIdList,_allergiesList, _addOnQtyList,
                  ));
                }

                if(order.orderType=="delivery" && GuestAddress.isEmpty){
                  showCustomSnackBar('Please select an address', context);
                  return;
                }

                if(totalQuantity % 1 != 0.00) {
                  showCustomSnackBar('Please complete the Half/Half order.', context);
                  return;
                }

                PlaceOrderGuestBody _placeOrderBody = PlaceOrderGuestBody(
                  cart: carts,
                  couponDiscountAmount: Provider.of<CouponProvider>(context, listen: false).discount,
                  couponDiscountTitle: widget.couponCode.isNotEmpty ? widget.couponCode : null,
                  // deliveryAddressId: order.orderType=="delivery" ? Provider.of<LocationProvider>(context, listen: false).addressList[order.addressIndex].id : 0,
                  orderAmount: double.parse('${(orderAmount).toStringAsFixed(2)}'),
                  orderNote: _noteController.text ?? '',
                  orderType: order.orderType??"",
                  paymentMethod: _isCashOnDeliveryActive ? order.paymentMethodIndex == 0 ? 'cash_on_delivery' : null : null,
                  couponCode: widget.couponCode.isNotEmpty ? widget.couponCode : null,
                  distance: order.orderType=="delivery" ? 0 : order.distance,
                  branchId: (_branches[order.branchIndex].id) !=null ?_branches[order.branchIndex].id:1 ,
                  deliveryDate: (DateFormat('yyyy-MM-dd').format(_scheduleStartDate)).toString(),
                  deliveryTime: (order.selectTimeSlot == 0 && order.selectDateSlot == 0) ? 'now' : (DateFormat('HH:mm').format(_scheduleStartDate)).toString(),
                  f_name: _firstName,
                  l_name: _lastName,
                  email: _email,
                  phone: _number,
                  delivery_address: GuestAddress,
                  uuid:_uuid

                );


                if(_isCashOnDeliveryActive && Provider.of<OrderProvider>(context, listen: false).paymentMethodIndex == 0) {
                //if( Provider.of<OrderProvider>(context, listen: false).paymentMethodIndex == 0) {
                  order.placeOrderGuest(_placeOrderBody, _callbackGuest);
                }
                else {
                  String hostname = html.window.location.hostname;
                  String protocol = html.window.location.protocol;
                  String port = html.window.location.port;
                  final String _placeOrder =  convert.base64Url.encode(convert.utf8.encode(convert.jsonEncode(_placeOrderBody.toGuestJson())));
                 /* String _url = "customer_id=${Provider.of<ProfileProvider>(context, listen: false).userInfoModel.id}"
                      "&&callback=${AppConstants.BASE_URL}${Routes.ORDER_SUCCESS_SCREEN}&&order_amount=${(orderAmount+_deliveryCharge).toStringAsFixed(2)}";*/


                  String _url = "uuid=$_uuid"+"&&f_name=${_firstName}"+"&&l_name=${_lastName}"+"&&email=${_email}"+"&&phone=${_number}"+
                      "&&callback=${AppConstants.BASE_URL}${Routes.ORDER_SUCCESS_SCREEN}&&order_amount=${(orderAmount).toStringAsFixed(2)}";

                  String _webUrl ="uuid=$_uuid"+"&&f_name=${_firstName}"+"&&l_name=${_lastName}"+"&&email=${_email}"+"&&phone=${_number}"+"&&callback=$protocol//$hostname:$port${Routes.ORDER_SUCCESS_GUEST_SCREEN}&&order_amount=${(orderAmount).toStringAsFixed(2)}&&status=";

                  String _tokenUrl = convert.base64Encode(convert.utf8.encode(ResponsiveHelper.isWeb() ? _webUrl : _url));
                  String selectedUrl = '${AppConstants.BASE_URL}/payment-mobile?token=$_tokenUrl';



                  if(ResponsiveHelper.isWeb()) {
                    order.clearPlaceOrder();
                    order.clearPlaceOrder().then((_) {
                      order.setPlaceOrder(_placeOrder).then((value) => html.window.open(selectedUrl,"_self"));
                    });

                  } else{
                    //todo:user added for check
                    Navigator.pushReplacementNamed(context, Routes.getGuestPaymentRoute(page: 'checkout',user: 0,  selectAddress: _tokenUrl, placeOrderBody: _placeOrderBody));
                  }
                }
              }
            }
          }
        }),
      ), //: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
    );
  }

  bool isGmailAddress(String email) {
    // check if email is valid using email_validator package
   //if (!EmailValidator.validate(email)) {
   //  return false;
   //}
   //final RegExp regex = RegExp(r'^[a-zA-Z0-9.]+@gmail\.com$');
   //return regex.hasMatch(email);
    if (email.isEmpty) {
      return false;
    }
    if (email.contains('@') && email.contains('.')) {
      return true;
    }
    return false;
  }

  Column detailsWidget(AuthProvider authProvider,BuildContext context, bool _kmWiseCharge, bool takeAway, OrderProvider order, double _deliveryCharge, LocationProvider address) {

    return Column(
      children: [
        _isCashOnDeliveryActive ? Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
          child: Text(getTranslated('payment_method', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
        ): SizedBox(),
        _isCashOnDeliveryActive ? CustomCheckBox(title: getTranslated('cash_on_delivery', context), index: 0) : SizedBox(),
        _isDigitalPaymentActive ? CustomCheckBox(title: getTranslated('digital_payment', context), index: _isCashOnDeliveryActive ? 1 : 0)
            : SizedBox(),
        Container(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),

          child: CustomTextField(
            controller: _noteController,
            hintText: getTranslated('additional_note', context),
            maxLines: 5,
            inputType: TextInputType.multiline,
            inputAction: TextInputAction.newline,
            capitalization: TextCapitalization.sentences,
          ),
        ),
        _cartList !=null?CartListCheckoutWidget(_cartList):Container(),
       /* Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
          child: Column(children: [
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(getTranslated('subtotal', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
              Text(PriceConverter.convertPrice(context, orderAmount), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
            ]),
            SizedBox(height: 10),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                getTranslated('delivery_fee', context),
                style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
              ),
              Text(
                PriceConverter.convertPrice(context, _deliveryCharge),
                style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
              ),
            ]),

            Padding(
              padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
              child: CustomDivider(),
            ),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(getTranslated('total_amount', context), style: rubikMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor,
              )),
              Text(
                PriceConverter.convertPrice(context, orderAmount+_deliveryCharge),
                style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor),
              ),
            ]),
          ]),
        ),*/
        if(ResponsiveHelper.isDesktop(context) && Provider.of<CartProvider>(context, listen: false).cartList.length>0)  confirmButtonWidget(authProvider,order, address, _kmWiseCharge, _deliveryCharge, context),
      ],
    );

  }

  void _callback(bool isSuccess, String message, String orderID, int addressID) async {
    if(isSuccess) {
      if(widget.fromCart) {
        Provider.of<CartProvider>(context, listen: false).clearCartList();
      }
      Provider.of<OrderProvider>(context, listen: false).stopLoader();
      if(_isCashOnDeliveryActive && Provider.of<OrderProvider>(context, listen: false).paymentMethodIndex == 0) {
        Navigator.pushReplacementNamed(context, '${Routes.ORDER_SUCCESS_SCREEN}/$orderID/success');
      }
      else {
        Navigator.pushReplacementNamed(context, '${Routes.ORDER_SUCCESS_SCREEN}/$orderID/success');
      }
    }else {
      showCustomSnackBar(message, context);
    }
  }

  void _callbackGuest(bool isSuccess, String message, String _orderID, int addressID) async {

    if(isSuccess) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderSuccessfulGuestScreen(status: 1, orderID: _orderID,)));
      if(widget.fromCart) {
        Provider.of<CartProvider>(context, listen: false).clearCartList();
      }
      Provider.of<OrderProvider>(context, listen: false).stopLoader();
      if(Provider.of<OrderProvider>(context, listen: false).paymentMethodIndex == 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderSuccessfulGuestScreen(status: 1, orderID: _orderID,)));
        //Navigator.pushReplacementNamed(context, '${Routes.ORDER_SUCCESS_GUEST_SCREEN}/$orderID/success');
      }
      else {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderSuccessfulGuestScreen(status: 1, orderID: _orderID,)));
       // Navigator.pushReplacementNamed(context, '${Routes.ORDER_SUCCESS_GUEST_SCREEN}/$orderID/success');
      }
    }else {
      showCustomSnackBar(message, context);
    }
  }


  void _setMarkers(int selectedIndex) async {
    BitmapDescriptor _bitmapDescriptor;
    BitmapDescriptor _bitmapDescriptorUnSelect;
    // Uint8List activeImageData = await convertAssetToUnit8List(Images.restaurant_marker, width: ResponsiveHelper.isMobilePhone() ? 30 : 30);
    // Uint8List inactiveImageData = await convertAssetToUnit8List(Images.unselected_restaurant_marker, width: ResponsiveHelper.isMobilePhone() ? 30 : 30);
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(30, 50)), Images.restaurant_marker).then((_marker) {
      _bitmapDescriptor = _marker;
    });
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(20, 20)), Images.unselected_restaurant_marker).then((_marker) {
      _bitmapDescriptorUnSelect = _marker;
    });
    // Marker
    _markers = HashSet<Marker>();
    for(int index=0; index<_branches.length; index++) {

      _markers.add(Marker(
        markerId: MarkerId('branch_$index'),
        position: LatLng(double.parse(_branches[index].latitude), double.parse(_branches[index].longitude)),
        infoWindow: InfoWindow(title: _branches[index].name, snippet: _branches[index].address),
        icon: selectedIndex == index ? _bitmapDescriptor : _bitmapDescriptorUnSelect,
      ));
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
      double.parse(_branches[selectedIndex].latitude),
      double.parse(_branches[selectedIndex].longitude),
    ), zoom: ResponsiveHelper.isMobile(context) ? 12 : 16)));

    setState(() {});
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 30}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
  }



  void _checkPermission(BuildContext context, String navigateTo) async {
    //checkPermissionStatus();
    Navigator.pushNamed(context, navigateTo);

   /* LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar(getTranslated('you_have_to_allow', context), context);
    }
    else if(permission == LocationPermission.deniedForever) {
      Future _dialog;
      if (_dialog == null) {
        _dialog =  showDialog(context: context, barrierDismissible: false, builder: (context) => PermissionDialog());
        await _dialog;
        _dialog = null;
      } else {
        //do nothing
      }

    }else {
      Navigator.pushNamed(context, navigateTo);
    }*/
  }


  Future<bool> registration(AuthProvider authProvider){
    String _firstName = _firstNameController.text.trim();
    String _lastName = _lastNameController.text.trim();
    String _number = _countryDialCode+_numberController.text.trim();
    String _email = _emailController.text.trim();
    String _password = '12345678';
    String _confirmPassword = _password;
    if(Provider.of<SplashProvider>(context, listen: false).configModel.emailVerification){
      if (_firstName.isEmpty) {
        showCustomSnackBar(getTranslated('enter_first_name', context), context);
      }else if (_lastName.isEmpty) {
        showCustomSnackBar(getTranslated('enter_last_name', context), context);
      }else if (_number.isEmpty) {
        showCustomSnackBar(getTranslated('enter_phone_number', context), context);
      }else if (_password.isEmpty) {
        showCustomSnackBar(getTranslated('enter_password', context), context);
      }else if (_password.length < 6) {
        showCustomSnackBar(getTranslated('password_should_be', context), context);
      }else if (_confirmPassword.isEmpty) {
        showCustomSnackBar(getTranslated('enter_confirm_password', context), context);
      }else if(_password != _confirmPassword) {
        showCustomSnackBar(getTranslated('password_did_not_match', context), context);
      }else {
        SignUpModel signUpModel = SignUpModel(
            fName: _firstName,
            lName: _lastName,
            email:_email,
            password: _password,
            phone: _number
        );

        authProvider.registration(signUpModel).then((status) async {
          if (status.isSuccess) {
           return true;
            //Navigator.pushNamedAndRemoveUntil(context, Routes.getMainRoute(), (route) => false);
          }
        });
      }
    }
    else{
      if (_firstName.isEmpty) {
        showCustomSnackBar(getTranslated('enter_first_name', context), context);
      }else if (_lastName.isEmpty) {
        showCustomSnackBar(getTranslated('enter_last_name', context), context);
      }else if (_number.isEmpty) {
        showCustomSnackBar(getTranslated('enter_phone_number', context), context);
      }else if (_password.isEmpty) {
        showCustomSnackBar(getTranslated('enter_password', context), context);
      }else if (_password.length < 6) {
        showCustomSnackBar(getTranslated('password_should_be', context), context);
      }else if (_confirmPassword.isEmpty) {
        showCustomSnackBar(getTranslated('enter_confirm_password', context), context);
      }else if(_password != _confirmPassword) {
        showCustomSnackBar(getTranslated('password_did_not_match', context), context);
      }else {
        SignUpModel signUpModel = SignUpModel(
          fName: _firstName,
          lName: _lastName,
          email: _email,
          password: _password,
          phone:  _email.trim().contains('+') ? _email.trim() : '+'+_email.trim(),
        );

        authProvider.registration(signUpModel).then((status) async {
          if (status.isSuccess) {
            return true;
          }else{
            showCustomSnackBar(status.message??"Something is Wrong try after sometime", context);
            return false;
          }
        });
      }
    }
  //  return false;
  }

}

class CartListCheckoutWidget extends StatelessWidget {
  final List<CartModel> cartList;
   CartListCheckoutWidget(this.cartList);
  final TextEditingController _couponController = TextEditingController();

/*  @override
  Widget build(BuildContext context) {

    List<List<AddOns>> _addOnsList = [];
    List<bool> _availableList = [];
    double _itemPrice = 0;
    double _discount = 0;
    double _tax = 0;
    double _addOns = 0;
    cartList.forEach((cartModel) {

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

      _availableList.add(DateConverter.isAvailable(cartModel.product.availableTimeStarts, cartModel.product.availableTimeEnds, context));

      for(int index=0; index<_addOnList.length; index++) {
        _addOns = _addOns + (_addOnList[index].price * cartModel.addOnIds[index].quantity);
      }
      _itemPrice = _itemPrice + (cartModel.price * cartModel.quantity);
      _discount = _discount + (cartModel.discountAmount * cartModel.quantity);
      _tax = _tax + (cartModel.taxAmount * cartModel.quantity);
    });
    double _subTotal = _itemPrice + _tax + _addOns;
    double _total = _subTotal - _discount - Provider.of<CouponProvider>(context).discount ;
    double _totalWithoutDeliveryFee = _subTotal - _discount - Provider.of<CouponProvider>(context).discount;

    double _orderAmount = _itemPrice + _addOns;

    bool _kmWiseCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.status == 1;


    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: cartList.length,
      itemBuilder: (context, index) {
        //return CartProductWithoutActionWidget(cart: cartList[index], cartIndex: index, addOns: [], isAvailable: true);
        return CartListWidget(cart: cartList[index],addOns: _addOnsList, availableList: _availableList);
      },
    );
  }*/
  @override
  Widget build(BuildContext context) {
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

          double _addOns = 0;
          for(int index=0; index<_addOnList.length; index++) {
            _addOns = _addOns + (_addOnList[index].price * cartModel.addOnIds[index].quantity);
          }
          _itemPrice = _itemPrice + (cartModel.quantity * (cartModel.quantity == 0.5 ? HALF_HALF_PRICE : cartModel.price)) + _addOns;
          _discount = _discount + (cartModel.discountAmount * cartModel.quantity);
          _tax = _tax + (cartModel.taxAmount * cartModel.quantity);
        });
        double _subTotal = _itemPrice + _tax;
        double _total = _subTotal - _discount - Provider.of<CouponProvider>(context).discount + deliveryCharge;
        double _totalWithoutDeliveryFee = _subTotal - _discount - Provider.of<CouponProvider>(context).discount;

        double _orderAmount = _itemPrice;
        orderAmount = _total;

        bool _kmWiseCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.status == 1;

        return cart.cartList.length > 0 ? Column(
          children: [

            Container(

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
              margin: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(5),
              padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE,vertical: Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Product
              CartListWidget(cart: cart,addOns: _addOnsList, availableList: _availableList,allergies: _allergiesList,),

                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
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

                // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                //   Text(getTranslated('tax', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                //   Text('(+) ${PriceConverter.convertPrice(context, _tax)}', style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                // ]),
                // SizedBox(height: 10),

                // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                //   Text(getTranslated('addons', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                //   Text('(+) ${PriceConverter.convertPrice(context, _addOns)}', style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                // ]),
                // SizedBox(height: 10),

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


              ]),
            ),

          ],
        ) : Container();
      },
    );
  }

}
