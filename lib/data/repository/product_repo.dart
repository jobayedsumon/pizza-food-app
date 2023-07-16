
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_restaurant/data/model/body/review_body_model.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';

class ProductRepo {
  final DioClient dioClient;

  ProductRepo({@required this.dioClient});


  Future<ApiResponse> getLocAddress(String uid, String languageCode,String input,String token) async {
    try {
      Map<String, String> _headers;
      _headers = {};
      _headers["x-requested-with"] = "XMLHttpRequest";
      _headers["content-type"] = "application/json";
      _headers["Accept"] = "application/json";
      _headers["Access-Control-Allow-Origin"] = "*";
      _headers["Access-Control-Allow-Methods"] = "GET,POST,OPTIONS";
      _headers["Access-Control-Allow-Credentials"] = "true";
      _headers["Access-Control-Allow-Headers"] = "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token";


      final response = await dioClient.get(
        //'${AppConstants.GOOGLE_LOCATION_URI}?input=$input&key=$uid&sessiontoken=$token',
        '${AppConstants.GOOGLE_LOCATION_URI}',
          queryParameters: {
            "input":input,
            "key":uid,
            "sessiontoken":token
          },
        options: Options(headers: _headers),
      ); print(languageCode );
      return ApiResponse.withSuccess(response);
    } catch (e) {

      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }

  }

  Future<ApiResponse> getDeliveryAddress(String uid, String languageCode) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.DELIVERY_INFO_URI}/$uid',
        //options: Options(headers: {'X-localization': languageCode}),
        options: Options(headers: {'Accept': 'application/json'}),
      ); print(languageCode );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }

  }

  Future<ApiResponse> getLatestProductList(String offset, String languageCode) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.LATEST_PRODUCT_URI}?limit=12&&offset=$offset',
        options: Options(headers: {'X-localization': languageCode}),
      ); print(languageCode );
      return ApiResponse.withSuccess(response);
    } catch (e) {

      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }

  }

  Future<ApiResponse> getPopularProductList(String offset, String type, String languageCode) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.POPULAR_PRODUCT_URI}?limit=12&&offset=$offset&product_type=$type',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {

      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }



  Future<ApiResponse> searchProduct(String productId, String languageCode) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.SEARCH_PRODUCT_URI}$productId',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {

      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> submitReview(ReviewBody reviewBody) async {
    try {
      final response = await dioClient.post(AppConstants.REVIEW_URI, data: reviewBody);
      return ApiResponse.withSuccess(response);
    } catch (e) {

      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> submitDeliveryManReview(ReviewBody reviewBody) async {
    try {
      final response = await dioClient.post(AppConstants.DELIVER_MAN_REVIEW_URI, data: reviewBody);
      return ApiResponse.withSuccess(response);
    } catch (e) {

      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
