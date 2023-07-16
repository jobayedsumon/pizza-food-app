

class GooglePlaceModel {
  String _description;
  String _placeId;

  GooglePlaceModel(
      {String description, String placeId}) {
    this._description = description;
    this._placeId = placeId;
  }

  String get description => _description;
  String get placeId => _placeId;

  GooglePlaceModel.fromJson(Map<String, dynamic> json) {
    _description = json['description'];
    _placeId = json['place_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this._description;
    data['place_id'] = this._placeId;
    return data;
  }
}