//
// Don't modify this file please!
//
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';

const _fakeDelay = Duration(milliseconds: 500);

abstract class ProductsRepository {
  Future<ProductsPage> getProductsPage(GetProductsPage param);

  Future<Map<String, dynamic>> getFilterOptions();

}

class MockedProductsRepository implements ProductsRepository {
  @override
  Future<ProductsPage> getProductsPage(GetProductsPage param) async {
    final path = 'assets/mocks/products_pages/${param.pageNumber}.json';
    final data = await rootBundle.loadString(path);
    final json = jsonDecode(data);
    final page = ProductsPage.fromJson(json);

    return Future.delayed(_fakeDelay, () => page);
  }

  @override
  Future<Map<String, dynamic>> getFilterOptions() async {
    Set<String> tags = {};
    int currentPage = 1;
    bool morePages = true;

    while (morePages) {
      final path = 'assets/mocks/products_pages/$currentPage.json';
      final data = await rootBundle.loadString(path);
      final json = jsonDecode(data);
      final page = ProductsPage.fromJson(json);

      for (var product in page.products) {
        for (var tag in product.tags) {
          tags.add(tag.label);
        }
      }

      currentPage++;
      morePages = currentPage <= page.totalPages;
    }

    return {
      'tags': tags.toList(),
    };
  }


}
