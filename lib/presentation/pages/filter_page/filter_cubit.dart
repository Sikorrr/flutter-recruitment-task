import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

class FilterState {
  final double? minPrice;
  final double? maxPrice;
  final double? minPriceInput;
  final double? maxPriceInput;
  final List<String> tags;
  final Set<String> selectedTags;
  final bool isFavoriteOnly;
  final bool isAvailableOnly;
  final bool isDiscountedOnly;
  final bool isLoading;

  const FilterState({
    this.minPrice,
    this.maxPrice,
    this.minPriceInput,
    this.maxPriceInput,
    this.tags = const [],
    this.selectedTags = const {},
    this.isFavoriteOnly = false,
    this.isAvailableOnly = false,
    this.isDiscountedOnly = false,
    this.isLoading = true,
  });

  FilterState copyWith({
    double? minPrice,
    double? maxPrice,
    double? minPriceInput,
    double? maxPriceInput,
    List<String>? tags,
    Set<String>? selectedTags,
    bool? isFavoriteOnly,
    bool? isAvailableOnly,
    bool? isDiscountedOnly,
    bool? isLoading,
  }) {
    return FilterState(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minPriceInput: minPriceInput ?? this.minPriceInput,
      maxPriceInput: maxPriceInput ?? this.maxPriceInput,
      tags: tags ?? this.tags,
      selectedTags: selectedTags ?? this.selectedTags,
      isFavoriteOnly: isFavoriteOnly ?? this.isFavoriteOnly,
      isAvailableOnly: isAvailableOnly ?? this.isAvailableOnly,
      isDiscountedOnly: isDiscountedOnly ?? this.isDiscountedOnly,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FilterCubit extends Cubit<FilterState> {
  final ProductsRepository _repository;

  FilterCubit(this._repository) : super(const FilterState());

  Future<void> loadFilters() async {
    emit(state.copyWith(isLoading: true));

    try {
      final options = await _repository.getFilterOptions();
      emit(state.copyWith(
        tags: options['tags'],
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void updateMinPriceInput(String value) {
    double? minPrice = double.tryParse(value);
    emit(state.copyWith(minPriceInput: minPrice));
  }

  void updateMaxPriceInput(String value) {
    double? maxPrice = double.tryParse(value);
    emit(state.copyWith(maxPriceInput: maxPrice));
  }

  void toggleTag(String tag) {
    final newTags = Set<String>.from(state.selectedTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    emit(state.copyWith(selectedTags: newTags));
  }

  void toggleFavoriteOnly() {
    emit(state.copyWith(isFavoriteOnly: !state.isFavoriteOnly));
  }

  void toggleAvailableOnly() {
    emit(state.copyWith(isAvailableOnly: !state.isAvailableOnly));
  }

  void toggleDiscountedOnly() {
    emit(state.copyWith(isDiscountedOnly: !state.isDiscountedOnly));
  }

  void resetFilters() {
    final resetState = FilterState(
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      tags: state.tags,
      minPriceInput: null,
      maxPriceInput: null,
      selectedTags: {},
      isFavoriteOnly: false,
      isAvailableOnly: false,
      isDiscountedOnly: false,
      isLoading: false,
    );
    emit(resetState);
  }

}
