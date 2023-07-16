
import 'dart:convert';

import 'package:flutter_restaurant/data/model/response/address_model.dart';
import 'package:flutter_restaurant/data/model/response/base/delivery_address_model.dart';
import 'package:flutter_restaurant/data/model/response/cart_model.dart';
import 'package:flutter_restaurant/data/model/response/google_place_model.dart';
import 'package:flutter_restaurant/data/model/response/order_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/body/review_body_model.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/data/model/response/response_model.dart';
import 'package:flutter_restaurant/data/repository/product_repo.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';

import 'localization_provider.dart';


String DELIVERY_ADDRESS = "";
String DELIVERY_ADDRESS_TYPE = "1";
String GuestAddress = "";

//DeliveryAddressModel autoComplete ;


class ProductProvider extends ChangeNotifier {
  final ProductRepo productRepo;

  ProductProvider({@required this.productRepo});

  // Latest products
  List<Product> _popularProductList;
  List<Product> _latestProductList;
  List<GooglePlaceModel> _googlePlaceList;
  bool _isLoading = false;
  int _popularPageSize;
  int _latestPageSize;
  List<String> _offsetList = [];
  List<int> _variationIndex = [0];
  int _quantity = 1;
  List<bool> _addOnActiveList = [];
  List<bool> _allergiesActiveList = [];
  List<int> _addOnQtyList = [];
  List<int> _allergiesQtyList = [];
  bool _seeMoreButtonVisible= true;
  int latestOffset = 1;
  int popularOffset = 1;
  int _cartIndex = -1;
  bool _isReviewSubmitted = false;
  List<String> _productTypeList = ['all', 'veg','meat','chicken','sea_food'];

  DeliveryAddressModel _deliveryAddressModel;
  String _deliveryAddressStatus;

  DeliveryAddressModel get deliveryAddressModel => _deliveryAddressModel;
  String get deliveryAddressStatus => _deliveryAddressStatus;
  List<Product> get popularProductList => _popularProductList;
  List<Product> get latestProductList => _latestProductList;
  List<GooglePlaceModel> get googlePlaceList => _googlePlaceList;
  bool get isLoading => _isLoading;
  int get popularPageSize => _popularPageSize;
  int get latestPageSize => _latestPageSize;
  List<int> get variationIndex => _variationIndex;
  int get quantity => _quantity;
  List<bool> get addOnActiveList => _addOnActiveList;
  List<bool> get allergiesActiveList => _allergiesActiveList;
  List<int> get addOnQtyList => _addOnQtyList;
  List<int> get allergiesQtyList => _allergiesQtyList;
  bool get seeMoreButtonVisible => _seeMoreButtonVisible;
  int get cartIndex => _cartIndex;
  bool get isReviewSubmitted => _isReviewSubmitted;
  List<String> get productTypeList => _productTypeList;

  Future<void> getLocationAddress(BuildContext context ,String uid, String languageCode,String inpur,String devToken) async {
    if (uid != null) {
      ApiResponse apiResponse = await productRepo.getLocAddress(uid, languageCode,inpur,devToken);
      if (apiResponse.response != null && apiResponse.response.statusCode == 200) {

        String data  = apiResponse.response.data.toString();
        var listData = apiResponse.response.data.Rows;
        for (var element in listData) {
          _googlePlaceList.add(GooglePlaceModel.fromJson(element));
        }
        _isLoading = false;
        notifyListeners();
      } else {
        showCustomSnackBar(apiResponse.error.toString(), context);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> getDeliveryAddress(BuildContext context ,String uid, String languageCode) async {
    if (uid != null) {
      ApiResponse apiResponse = await productRepo.getDeliveryAddress(uid, languageCode);
      if (apiResponse.response != null && apiResponse.response.statusCode == 200) {

        String data  = apiResponse.response.data.toString();
        if(data.length>4){
          String subData = data.substring(2, data.length-2);


          AddressModel addressModel = AddressModel(
            addressType: "",
            contactPersonName: '',
            contactPersonNumber: '',
            address: json.decode(subData)['address']??"",
            latitude: json.decode(subData)['lat']??"",
            longitude: json.decode(subData)['long']??"",
            floorNumber: '',
            houseNumber: '',
            streetNumber:'',
            branchId: json.decode(subData)['branch_id']??"",
            uuId:json.decode(subData)['uid']??"",
          );





          _deliveryAddressModel = DeliveryAddressModel(
            id:json.decode(subData)['branch_id']??"",
            uid:json.decode(subData)['uid']??"",
            address:json.decode(subData)['address']??"",
            lat:json.decode(subData)['lat']??"",
            long:json.decode(subData)['long']??"",
            deliveryType:json.decode(subData)['delivery_type']??"",
            branchId:json.decode(subData)['branch_id']??"",
          );



          if(json.decode(subData)['delivery_type'] !=null){
            String addressType = json.decode(subData)['delivery_type'];
            DELIVERY_ADDRESS_TYPE = addressType;
            if(addressType=="0"){
              //Provider.of<OrderProvider>(context, listen: false).orderType = "take_away";
              Provider.of<OrderProvider>(context, listen: false).setOrderType('take_away',notify: true);
             // print(Provider.of<OrderProvider>(context, listen: false).orderType)
              notifyListeners();
            }else{
             // Provider.of<OrderProvider>(context, listen: false).orderType = "delivery";
              Provider.of<OrderProvider>(context, listen: false).setOrderType('delivery',notify: true);
              notifyListeners();
            }

          }

          GuestAddress = jsonEncode(addressModel.toJson());
          String subdata = data.substring(2, data.length-2);
          DELIVERY_ADDRESS =  data.substring(data.indexOf('address')+10, data.indexOf('lat')-4);
          _deliveryAddressStatus="Success";

        }else{
          _deliveryAddressStatus="No Data Found";

          _deliveryAddressModel = DeliveryAddressModel(
            id:"",
            uid:"",
            address:"",
            lat:"",
            long:"",
            deliveryType:"",
            branchId:"",
          );
          GuestAddress = jsonEncode(_deliveryAddressModel.toJson());
        }
        _isLoading = false;
        notifyListeners();
      } else {

        _deliveryAddressStatus="Error";

        showCustomSnackBar(apiResponse.error.toString(), context);
      }
    }
    else {
      _deliveryAddressStatus="UID Missing";

      if(isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> getLatestProductList(BuildContext context , bool reload, String _offset, String languageCode) async {
    if(reload || _offset == '1') {
      latestOffset = 1 ;
      _offsetList = [];
    }
    if (!_offsetList.contains(_offset)) {
      _offsetList = [];
      _offsetList.add(_offset);
      ApiResponse apiResponse = await productRepo.getLatestProductList(_offset, languageCode);
      if (apiResponse.response != null && apiResponse.response.statusCode == 200) {

        if (reload || _offset == '1') {
          _latestProductList = [];
        }
        _latestProductList.addAll(ProductModel.fromJson(apiResponse.response.data).products);
        _latestPageSize = ProductModel.fromJson(apiResponse.response.data).totalSize;
        _isLoading = false;
        notifyListeners();
      } else {
        showCustomSnackBar(apiResponse.error.toString(), context);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> getPopularProductList(BuildContext context , bool reload, String _offset, {String type = 'all',bool isUpdate = false}) async {
    bool _apiSuccess = false;
    if(reload || _offset == '1') {
      popularOffset = 1 ;
      _offsetList = [];
      _popularProductList = null;
    }
    if(isUpdate) {
      notifyListeners();
    }

    if (!_offsetList.contains(_offset)) {
      _offsetList = [];
      _offsetList.add(_offset);
      ApiResponse apiResponse = await productRepo.getPopularProductList(
        _offset, type, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      );

      if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
        _apiSuccess = true;
        if (reload || _offset == '1') {
          _popularProductList = [];
        }
        _popularProductList.addAll(ProductModel.fromJson(apiResponse.response.data).products);
        _popularPageSize = ProductModel.fromJson(apiResponse.response.data).totalSize;
        _isLoading = false;
        notifyListeners();
      } else {
        showCustomSnackBar(apiResponse.error.toString(), context);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
    return _apiSuccess;
  }

  void showBottomLoader() {
    _isLoading = true;
    notifyListeners();
  }

  void initData(Product product, CartModel cart, BuildContext context) {
    _variationIndex = [];
    _addOnQtyList = [];
    _addOnActiveList = [];

    _allergiesQtyList = [];
    _allergiesActiveList = [];


    if(cart != null) {
      _quantity = cart.quantity;
      List<String> _variationTypes = [];
      if(cart.variation.length != null && cart.variation.length > 0 && cart.variation[0].type != null) {
        _variationTypes.addAll(cart.variation[0].type.split('-'));
      }
      int _varIndex = 0;
      product.choiceOptions.forEach((choiceOption) {
        for(int index=0; index<choiceOption.options.length; index++) {
          if(choiceOption.options[index].trim().replaceAll(' ', '') == _variationTypes[_varIndex].trim()) {
            _variationIndex.add(index);
            break;
          }
        }
        _varIndex++;
      });
      List<int> _addOnIdList = [];

      cart.addOnIds.forEach((addOnId) => _addOnIdList.add(addOnId.id));
      product.addOns.forEach((addOn) {
        if(_addOnIdList.contains(addOn.id)) {
          _addOnActiveList.add(true);
          _addOnQtyList.add(cart.addOnIds[_addOnIdList.indexOf(addOn.id)].quantity);
        }else {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      });
      List<int> _allergiesIdList = [];
      cart.allergIds.forEach((allergId) => _allergiesIdList.add(allergId.id));
      product.allergies.forEach((allergies) {
        if(_allergiesIdList.contains(allergies.id)) {
          _allergiesActiveList.add(true);
          _allergiesQtyList.add(cart.allergIds[_allergiesIdList.indexOf(allergies.id)].quantity);
        }else {
          _allergiesActiveList.add(false);
          _allergiesQtyList.add(1);
        }
      });

    }else {
      _quantity = 1;
      product.choiceOptions.forEach((element) => _variationIndex.add(0));
      product.addOns.forEach((addOn) {
        _addOnActiveList.add(false);
        _addOnQtyList.add(1);
      });
      product.allergies.forEach((addOn) {
        _allergiesActiveList.add(false);
        _allergiesQtyList.add(1);
      });

      setExistInCart(product, context, notify: false);
    }
  }

  void setAddOnQuantity(bool isIncrement, int index) {
    if (isIncrement) {
      _addOnQtyList[index] = _addOnQtyList[index] + 1;
    } else {
      _addOnQtyList[index] = _addOnQtyList[index] - 1;
    }
    notifyListeners();
  }
  void setAllergiesQuantity(bool isIncrement, int index) {
    if (isIncrement) {
      _allergiesQtyList[index] = _allergiesQtyList[index] + 1;
    } else {
      _allergiesQtyList[index] = _allergiesQtyList[index] - 1;
    }
    notifyListeners();
  }

  void setQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = _quantity + 1;
    } else {
      _quantity = _quantity - 1;
    }
    notifyListeners();
  }

  void setCartVariationIndex(int index, int i, Product product, String variationType, BuildContext context) {
    _variationIndex[index] = i;
    _quantity = 1;
    setExistInCart(product, context);
    notifyListeners();
  }

  int setExistInCart(Product product, BuildContext context,{bool notify = true}) {
    List<String> _variationList = [];
    for (int index = 0; index < product.choiceOptions.length; index++) {
      _variationList.add(product.choiceOptions[index].options[_variationIndex[index]].replaceAll(' ', ''));
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
    final _cartProvider =  Provider.of<CartProvider>(context, listen: false);
    _cartIndex = _cartProvider.isExistInCart(product.id, variationType, false, null);
    if(_cartIndex != -1) {
      _quantity = _cartProvider.cartList[_cartIndex].quantity;
      _addOnActiveList = [];
      _addOnQtyList = [];
      List<int> _addOnIdList = [];

      _cartProvider.cartList[_cartIndex].addOnIds.forEach((addOnId) => _addOnIdList.add(addOnId.id));
      product.addOns.forEach((addOn) {
        if(_addOnIdList.contains(addOn.id)) {
          _addOnActiveList.add(true);
          _addOnQtyList.add(_cartProvider.cartList[_cartIndex].addOnIds[_addOnIdList.indexOf(addOn.id)].quantity);
        }else {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      });
      _allergiesActiveList = [];
      _allergiesQtyList = [];
      List<int> _allergiesIdList = [];
      _cartProvider.cartList[_cartIndex].allergIds.forEach((allergId) => _allergiesIdList.add(allergId.id));
      product.allergies.forEach((allerg) {
        if(_allergiesIdList.contains(allerg.id)) {
          _allergiesActiveList.add(true);
          _allergiesQtyList.add(_cartProvider.cartList[_cartIndex].allergIds[_allergiesIdList.indexOf(allerg.id)].quantity);
        }else {
          _allergiesActiveList.add(false);
          _allergiesQtyList.add(1);
        }
      });
    }
    return _cartIndex;
  }

  void addAddOn(bool isAdd, int index) {
    _addOnActiveList[index] = isAdd;
    notifyListeners();
  }
void addAllergies(bool isAdd, int index) {
    _allergiesActiveList[index] = isAdd;
    notifyListeners();
  }

  List<int> _ratingList = [];
  List<String> _reviewList = [];
  List<bool> _loadingList = [];
  List<bool> _submitList = [];
  int _deliveryManRating = 0;

  List<int> get ratingList => _ratingList;
  List<String> get reviewList => _reviewList;
  List<bool> get loadingList => _loadingList;
  List<bool> get submitList => _submitList;
  int get deliveryManRating => _deliveryManRating;

  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    orderDetailsList.forEach((orderDetails) {
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
    });
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    notifyListeners();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    notifyListeners();
  }

  Future<ResponseModel> submitReview(int index, ReviewBody reviewBody) async {
    _loadingList[index] = true;
    notifyListeners();

    ApiResponse response = await productRepo.submitReview(reviewBody);
    ResponseModel responseModel;
    if (response.response != null && response.response.statusCode == 200) {
      _submitList[index] = true;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      notifyListeners();
    } else {
      String errorMessage;
      if(response.error is String) {
        errorMessage = response.error.toString();
      }else {
        errorMessage = response.error.errors[0].message;
      }
      responseModel = ResponseModel(false, errorMessage);
    }
    _loadingList[index] = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBody reviewBody, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse response = await productRepo.submitDeliveryManReview(reviewBody);
    ResponseModel responseModel;
    if (response.response != null && response.response.statusCode == 200) {
      responseModel = ResponseModel(true, getTranslated('review_submitted_successfully', context));
      updateSubmitted(true);

      notifyListeners();
    } else {
      String errorMessage;
      if(response.error is String) {
        errorMessage = response.error.toString();
      }else {
        errorMessage = response.error.errors[0].message;
      }
      responseModel = ResponseModel(false, errorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  void moreProduct(BuildContext context) {
    int pageSize;
    pageSize =(latestPageSize / 10).ceil();

    if (latestOffset < pageSize) {
      latestOffset++;
      showBottomLoader();
      getLatestProductList(
        context, false, latestOffset.toString(),
        Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      );
    }
  }


  void seeMoreReturn(){
    latestOffset = 1;
    _seeMoreButtonVisible = true;
  }
  updateSubmitted(bool value) {
    _isReviewSubmitted = value;
  }

}
