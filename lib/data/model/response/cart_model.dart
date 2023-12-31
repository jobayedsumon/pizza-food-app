import 'package:flutter_restaurant/data/model/response/product_model.dart';

class CartModel {
  double _price;
  double _discountedPrice;
  List<Variation> _variation;
  double _discountAmount;
  double _quantity;
  double _taxAmount;
  List<AddOn> _addOnIds;
  List<Allerg> _allergIds;
  Product _product;

  CartModel(
        double price,
        double discountedPrice,
        List<Variation> variation,
        double discountAmount,
        double quantity,
        double taxAmount,
        List<AddOn> addOnIds,
        List<Allerg> allergIds,
        Product product) {
    this._price = price;
    this._discountedPrice = discountedPrice;
    this._variation = variation;
    this._discountAmount = discountAmount;
    this._quantity = quantity;
    this._taxAmount = taxAmount;
    this._addOnIds = addOnIds;
    this._allergIds = allergIds;
    this._product = product;
  }

  double get price => _price;
  double get discountedPrice => _discountedPrice;
  List<Variation> get variation => _variation;
  double get discountAmount => _discountAmount;
  // ignore: unnecessary_getters_setters
  double get quantity => _quantity;
  // ignore: unnecessary_getters_setters
  set quantity(double qty) => _quantity = qty;
  double get taxAmount => _taxAmount;
  List<AddOn> get addOnIds => _addOnIds;
  List<Allerg> get allergIds => _allergIds;
  Product get product => _product;

  CartModel.fromJson(Map<String, dynamic> json) {
    _price = json['price'].toDouble();
    _discountedPrice = json['discounted_price'].toDouble();
    if (json['variation'] != null) {
      _variation = [];
      json['variation'].forEach((v) {
        _variation.add(new Variation.fromJson(v));
      });
    }
    _discountAmount = json['discount_amount'].toDouble();
    _quantity = json['quantity'];
    _taxAmount = json['tax_amount'].toDouble();
    if (json['add_on_ids'] != null) {
      _addOnIds = [];
      json['add_on_ids'].forEach((v) {
        _addOnIds.add(new AddOn.fromJson(v));
      });
    }
    if (json['allerg_ids'] != null) {
      _allergIds = [];
      json['allerg_ids'].forEach((v) {
        _allergIds.add(new Allerg.fromJson(v));
      });
    }

    if (json['product'] != null) {
      _product = Product.fromJson(json['product']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this._price;
    data['discounted_price'] = this._discountedPrice;
    if (this._variation != null) {
      data['variation'] = this._variation.map((v) => v.toJson()).toList();
    }
    data['discount_amount'] = this._discountAmount;
    data['quantity'] = this._quantity;
    data['tax_amount'] = this._taxAmount;
    if (this._addOnIds != null) {
      data['add_on_ids'] = this._addOnIds.map((v) => v.toJson()).toList();
    }
    if (this._allergIds != null) {
      data['allerg_ids'] = this._allergIds.map((v) => v.toJson()).toList();
    }

    data['product'] = this._product.toJson();
    return data;
  }
}

class AddOn {
  int _id;
  int _quantity;

  AddOn({int id, int quantity}) {
    this._id = id;
    this._quantity = quantity;
  }

  int get id => _id;
  int get quantity => _quantity;

  AddOn.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['quantity'] = this._quantity;
    return data;
  }
}
class Allerg {
  int _id;
  int _quantity;

  Allerg({int id, int quantity}) {
    this._id = id;
    this._quantity = quantity;
  }

  int get id => _id;
  int get quantity => _quantity;

  Allerg.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['quantity'] = this._quantity;
    return data;
  }
}
