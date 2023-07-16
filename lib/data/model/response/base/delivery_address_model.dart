class DeliveryAddressModel {
  String id;
  String uid;
  String address;
  String lat;
  String long;
  String deliveryType;
  String branchId;

  DeliveryAddressModel(
      {this.id,
        this.uid,
        this.address,
        this.lat,
        this.long,
        this.deliveryType,
        this.branchId});
  DeliveryAddressModel.fromJson(Map<String, dynamic> json) {

    id = json['id']??'';
    uid = json['uid']??'';
    address = json['address']??'';
    lat = json['lat']??'';
    long = json['long']??'';
    deliveryType = json['delivery_type']??'';
    branchId = json['branch_id']??'';
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
}