import 'package:bloc/bloc.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

import '../filter_page/filter_cubit.dart';

sealed class HomeState {
  const HomeState();
}

class Loading extends HomeState {
  const Loading();
}

class Loaded extends HomeState {
  const Loaded({required this.pages, required this.hasMorePages});

  final List<ProductsPage> pages;

  final bool hasMorePages;
}

class Error extends HomeState {
  const Error({required this.error});

  final dynamic error;
}

class NoFilteredResults extends HomeState {
  const NoFilteredResults();
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const Loading());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];
  var _param = GetProductsPage(pageNumber: 1);

  Future<void> getNextPage({bool emitState = true}) async {
    try {
      final totalPages = _pages.lastOrNull?.totalPages;
      if (totalPages != null && _param.pageNumber > totalPages) return;
      final newPage = await _productsRepository.getProductsPage(_param);
      _param = _param.increasePageNumber();
      _pages.add(newPage);
      if (emitState) {
        emit(Loaded(pages: _pages, hasMorePages: !_isLastPage()));
      }
    } catch (e) {
      emit(Error(error: e));
    }
  }

  Future<int?> findProductIndexById(String productId) async {
    try {
      while (true) {
        final index = _findProductIndex(productId);
        if (index != null) return index;

        if (_isLastPage()) break;
        await getNextPage();
      }
      return null;
    } catch (e) {
      emit(Error(error: e));
      return null;
    }
  }

  int? _findProductIndex(String productId) {
    final products = _pages.expand((page) => page.products).toList();
    final index = products.indexWhere((product) => product.id == productId);
    return index == -1 ? null : index;
  }

  bool _isLastPage() {
    final totalPages = _pages.lastOrNull?.totalPages;
    return totalPages != null && _param.pageNumber > totalPages;
  }

  Future<void> applyFilters(FilterState filterState) async {
    emit(const Loading());

    try {
      while (!_isLastPage()) {
        await getNextPage(emitState: false);
      }

      final products = _pages.expand((page) => page.products).toList();

      final filteredProducts = products.where((product) {
        bool matches = true;

        if (filterState.minPriceInput != null) {
          matches &= product.offer.regularPrice.amount >= filterState.minPriceInput!;
        }
        if (filterState.maxPriceInput != null) {
          matches &= product.offer.regularPrice.amount <= filterState.maxPriceInput!;
        }

        if (filterState.isAvailableOnly) {
          matches &= product.available;
        }

        if (filterState.isDiscountedOnly) {
          final promotionalPrice = product.offer.promotionalPrice?.amount;
          final regularPrice = product.offer.regularPrice.amount;
          matches &= promotionalPrice != null && promotionalPrice < regularPrice;
        }

        if (filterState.isFavoriteOnly) {
          matches &= product.isFavorite ?? false;
        }

        if (filterState.selectedTags.isNotEmpty) {
          matches &= filterState.selectedTags.every((tag) => product.tags.any((t) => t.label == tag));
        }

        return matches;
      }).toList();

      if (filteredProducts.isEmpty) {
        emit(const NoFilteredResults());
      } else {
        final filteredPage = ProductsPage(
          pageNumber: 1,
          pageSize: filteredProducts.length,
          totalPages: 1,
          products: filteredProducts,
        );
        emit(Loaded(pages: [filteredPage], hasMorePages: false));
      }
    } catch (e) {
      emit(Error(error: e));
    }
  }


  Future<void> resetProducts() async {
    try {
      emit(const Loading());
      _pages.clear();
      _param = GetProductsPage(pageNumber: 1);
      final initialPage = await _productsRepository.getProductsPage(_param);
      _pages.add(initialPage);
      emit(Loaded(pages: _pages, hasMorePages: !_isLastPage()));
    } catch (e) {
      emit(Error(error: e));
    }
  }
}
