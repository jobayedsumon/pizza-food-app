import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';

class CategoryRepo {
  final DioClient dioClient;
  CategoryRepo({@required this.dioClient});

  Future<ApiResponse> getCategoryList(String languageCode) async {
    try {
      final response = await dioClient.get(AppConstants.CATEGORY_URI,
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getSubCategoryList(String parentID, String languageCode) async {
    try {
      final response = await dioClient.get('${AppConstants.SUB_CATEGORY_URI}$parentID',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getCategoryProductList(String categoryID, String languageCode, String type) async {
    try {
      print(categoryID);
      print(type);
      print(languageCode);
      final response = await dioClient.get('${AppConstants.CATEGORY_PRODUCT_URI}$categoryID?product_type=$type',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}