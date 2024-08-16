import 'package:bloc/bloc.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

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

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const Loading());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];
  var _param = GetProductsPage(pageNumber: 1);

  Future<void> getNextPage() async {
    try {
      final totalPages = _pages.lastOrNull?.totalPages;
      if (totalPages != null && _param.pageNumber > totalPages) return;
      final newPage = await _productsRepository.getProductsPage(_param);
      _param = _param.increasePageNumber();
      _pages.add(newPage);
      emit(Loaded(pages: _pages, hasMorePages: !_isLastPage()));
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
}
