import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filter_cubit.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late FilterCubit filterCubit;
  late ProductsRepository productsRepository;

  setUp(() {
    productsRepository = MockProductsRepository();
    filterCubit = FilterCubit(productsRepository);
  });

  tearDown(() {
    filterCubit.close();
  });

  group('FilterCubit Initialization', () {
    test('initial state is loading', () {
      expect(filterCubit.state, equals(const FilterState()));
    });
  });

  group('FilterCubit Load Filters', () {
    blocTest<FilterCubit, FilterState>(
      'emits [isLoading: true, isLoading: false] and populates filters on success',
      build: () {
        when(() => productsRepository.getFilterOptions()).thenAnswer((_) async => {
          'tags': ['NOWOŚĆ', 'VEGAN', 'VEGE'],
        });
        return filterCubit;
      },
      act: (cubit) => cubit.loadFilters(),
      expect: () => [
        isA<FilterState>().having((state) => state.isLoading, 'loading state', true),
        isA<FilterState>()
            .having((state) => state.tags, 'tags', ['NOWOŚĆ', 'VEGAN', 'VEGE'])
            .having((state) => state.isLoading, 'loading state', false),
      ],
    );

    blocTest<FilterCubit, FilterState>(
      'emits [isLoading: true, isLoading: false] on failure',
      build: () {
        when(() => productsRepository.getFilterOptions()).thenThrow(Exception('Failed to load filters'));
        return filterCubit;
      },
      act: (cubit) => cubit.loadFilters(),
      expect: () => [
        isA<FilterState>().having((state) => state.isLoading, 'loading state', true),
        isA<FilterState>().having((state) => state.isLoading, 'loading state', false),
      ],
    );
  });

  group('FilterCubit Update Inputs', () {
    blocTest<FilterCubit, FilterState>(
      'updates minPriceInput correctly',
      build: () => filterCubit,
      act: (cubit) => cubit.updateMinPriceInput('100'),
      expect: () => [
        isA<FilterState>().having((state) => state.minPriceInput, 'minPriceInput', 100.0),
      ],
    );

    blocTest<FilterCubit, FilterState>(
      'updates maxPriceInput correctly',
      build: () => filterCubit,
      act: (cubit) => cubit.updateMaxPriceInput('500'),
      expect: () => [
        isA<FilterState>().having((state) => state.maxPriceInput, 'maxPriceInput', 500.0),
      ],
    );
  });

  group('FilterCubit Toggle Options', () {
    blocTest<FilterCubit, FilterState>(
      'toggles favoriteOnly correctly',
      build: () => filterCubit,
      act: (cubit) => cubit.toggleFavoriteOnly(),
      expect: () => [
        isA<FilterState>().having((state) => state.isFavoriteOnly, 'isFavoriteOnly', true),
      ],
    );

    blocTest<FilterCubit, FilterState>(
      'toggles availableOnly correctly',
      build: () => filterCubit,
      act: (cubit) => cubit.toggleAvailableOnly(),
      expect: () => [
        isA<FilterState>().having((state) => state.isAvailableOnly, 'isAvailableOnly', true),
      ],
    );

    blocTest<FilterCubit, FilterState>(
      'toggles discountedOnly correctly',
      build: () => filterCubit,
      act: (cubit) => cubit.toggleDiscountedOnly(),
      expect: () => [
        isA<FilterState>().having((state) => state.isDiscountedOnly, 'isDiscountedOnly', true),
      ],
    );
  });

  group('FilterCubit Toggle Tags', () {
    blocTest<FilterCubit, FilterState>(
      'adds a tag when toggleTag is called with an unselected tag',
      build: () => filterCubit,
      act: (cubit) => cubit.toggleTag('tag1'),
      expect: () => [
        isA<FilterState>().having((state) => state.selectedTags, 'selectedTags', {'tag1'}),
      ],
    );

    blocTest<FilterCubit, FilterState>(
      'removes a tag when toggleTag is called with a selected tag',
      build: () {
        filterCubit.emit(filterCubit.state.copyWith(selectedTags: {'tag1'}));
        return filterCubit;
      },
      act: (cubit) => cubit.toggleTag('tag1'),
      expect: () => [
        isA<FilterState>().having((state) => state.selectedTags, 'selectedTags', <String>{}),
      ],
    );
  });

  group('FilterCubit Reset Filters', () {
    blocTest<FilterCubit, FilterState>(
      'resets all filters correctly',
      build: () => filterCubit,
      setUp: () {
        filterCubit.emit(filterCubit.state.copyWith(
          minPriceInput: 10.0,
          maxPriceInput: 50.0,
          selectedTags: {'NOWOŚĆ'},
          isFavoriteOnly: true,
          isAvailableOnly: true,
          isDiscountedOnly: true,
        ));
      },
      act: (cubit) => cubit.resetFilters(),
      expect: () => [
        isA<FilterState>().having((state) => state.minPriceInput, 'minPriceInput', null)
            .having((state) => state.maxPriceInput, 'maxPriceInput', null)
            .having((state) => state.selectedTags, 'selectedTags', <String>{})
            .having((state) => state.isFavoriteOnly, 'isFavoriteOnly', false)
            .having((state) => state.isAvailableOnly, 'isAvailableOnly', false)
            .having((state) => state.isDiscountedOnly, 'isDiscountedOnly', false),
      ],
    );
  });





}
