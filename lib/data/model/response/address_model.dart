import 'package:flutter_restaurant/utill/app_constants.dart';

class AddressModel {
  int id;
  String addressType;
  String contactPersonNumber;
  String address;
  String latitude;
  String longitude;
  String createdAt;
  String updatedAt;
  int userId;
  String method;
  String contactPersonName;
  String streetNumber;
  String floorNumber;
  String houseNumber;
  String branchId;
  String uuId;

  AddressModel({
    this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.method,
    this.contactPersonName,
    this.houseNumber,
    this.floorNumber,
    this.streetNumber,
    this.branchId,
    this.uuId,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    if(json['id'] !=null && json['id'].toString().isNotEmpty){
      id = int.parse(json['id'].toString());
    }

    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    method = json['_method'];
    contactPersonName = json['contact_person_name'];
    streetNumber = json['road'];
    floorNumber = json['floor'];
    houseNumber = json['house'];
   /* branchId = json['branchId']??"";
    uuId = json['uuId']??"";*/
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address_type'] = this.addressType;
    data['contact_person_number'] = this.contactPersonNumber;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_id'] = this.userId;
    data['_method'] = this.method;
    data['contact_person_name'] = this.contactPersonName;
    data['road'] = this.streetNumber;
    data['floor'] = this.floorNumber;
    data['house'] = this.houseNumber;
    //data['branchId'] = this.branchId??'';
    //data['uuId'] = this.uuId??'';
    return data;
  }
}

/*class AddressAutoComplete {
  String id;
  String uid;
  String address;
  String lat;
  String long;
  String deliveryType;
  String branchId;

  AddressAutoComplete(
      {this.id,
        this.uid,
        this.address,
        this.lat,
        this.long,
        this.deliveryType,
        this.branchId});

  AddressAutoComplete.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid']??"";
    address = json['address'];
    lat = json['lat'];
    long = json['long'];
    deliveryType = json['delivery_type'];
    branchId = json['branch_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['delivery_type'] = this.deliveryType;
    data['branch_id'] = this.branchId;
    return data;
  }
}*/
