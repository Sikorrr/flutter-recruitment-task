import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/filter_page/filter_cubit.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeGetProductsPage extends Fake implements GetProductsPage {}
class MockFailureProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late HomeCubit homeCubit;
  late ProductsRepository productsRepository;
  late MockFailureProductsRepository failureRepository;

  setUpAll(() {
    registerFallbackValue(FakeGetProductsPage());
  });

  setUp(() async {
    productsRepository = MockedProductsRepository();
    failureRepository = MockFailureProductsRepository();
    homeCubit = HomeCubit(productsRepository);
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    homeCubit.close();
  });

  group('HomeCubit Initialization', () {
    test('initial state is Loading', () {
      expect(homeCubit.state, equals(const Loading()));
    });
  });

  group('HomeCubit Page Loading', () {
    blocTest<HomeCubit, HomeState>(
      'emits [Loaded] when getNextPage is called successfully',
      build: () => homeCubit,
      act: (cubit) => cubit.getNextPage(),
      expect: () => [isA<Loaded>()],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [Loaded] with correct data when getNextPage is called successfully',
      build: () => homeCubit,
      act: (cubit) => cubit.getNextPage(),
      expect: () => [
        isA<Loaded>().having((state) => state.pages.first.products.length, 'products length', greaterThan(0)),
      ],
      verify: (_) {
        final state = homeCubit.state as Loaded;
        expect(state.pages.first.products.length, equals(20));

        final product = state.pages.first.products.first;
        expect(product.name, isNotEmpty);
        expect(product.id, isNotEmpty);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'does not load more pages when last page is reached',
      build: () => homeCubit,
      act: (cubit) async {
        await cubit.getNextPage();
        await cubit.getNextPage();
        await cubit.getNextPage();
        await cubit.getNextPage();
      },
      expect: () => [
        isA<Loaded>(),
        isA<Loaded>(),
        isA<Loaded>(),
      ],
      verify: (_) {
        final state = homeCubit.state as Loaded;
        expect(state.pages.length, equals(3));
        expect(state.pages.last.pageNumber, equals(3));
      },
    );

    blocTest<HomeCubit, HomeState>(
      'loads next page correctly when getNextPage is called sequentially',
      build: () => homeCubit,
      act: (cubit) async {
        await cubit.getNextPage();
        await cubit.getNextPage();
      },
      expect: () => [
        isA<Loaded>(),
        isA<Loaded>(),
      ],
      verify: (_) {
        final state = homeCubit.state as Loaded;
        expect(state.pages.length, equals(2));

        expect(state.pages.first.pageNumber, equals(1));
        expect(state.pages.last.pageNumber, equals(2));

        final firstPageProducts = state.pages.first.products;
        final secondPageProducts = state.pages.last.products;

        expect(firstPageProducts, isNotEmpty);
        expect(secondPageProducts, isNotEmpty);
        expect(firstPageProducts, isNot(equals(secondPageProducts)));
      },
    );
  });

  group('HomeCubit Filtering', () {

    blocTest<HomeCubit, HomeState>(
      'filters products correctly after loading necessary pages',
      build: () => homeCubit,
      act: (cubit) async {
        await cubit.applyFilters(const FilterState(
          minPriceInput: 0,
          maxPriceInput: 100,
          selectedTags: {},
          isFavoriteOnly: false,
          isAvailableOnly: true,
          isDiscountedOnly: false,
        ));
      },
      expect: () => [
        const Loading(),
        isA<Loaded>(),
      ],
      verify: (_) {
        final state = homeCubit.state as Loaded;
        final filteredProducts = state.pages.expand((page) => page.products).toList();

        expect(filteredProducts.length, greaterThan(0));
        for (var product in filteredProducts) {
          expect(product.available, isTrue);
          expect(product.offer.regularPrice.amount, lessThanOrEqualTo(100));
        }
      },
    );

    blocTest<HomeCubit, HomeState>(
      'filters products correctly by price range',
      build: () => homeCubit,
      act: (cubit) async {
        await cubit.applyFilters(const FilterState(
          minPriceInput: 0,
          maxPriceInput: 50,
          selectedTags: {},
          isFavoriteOnly: false,
          isAvailableOnly: true,
          isDiscountedOnly: false,
        ));
      },
      expect: () => [
        const Loading(),
        isA<Loaded>().having((state) => state.pages.first.products.length, 'filtered products length', greaterThan(0)),
      ],
      verify: (_) {
        final state = homeCubit.state as Loaded;
        final filteredProducts = state.pages.first.products;

        expect(filteredProducts.length, greaterThan(0));
        for (var product in filteredProducts) {
          expect(product.available, isTrue);
          expect(product.offer.regularPrice.amount, greaterThanOrEqualTo(0));
          expect(product.offer.regularPrice.amount, lessThanOrEqualTo(50));
        }
      },
    );


    blocTest<HomeCubit, HomeState>(
      'filters products correctly by tags',
      build: () => homeCubit,
      act: (cubit) async {
        await cubit.applyFilters(const FilterState(
          minPriceInput: null,
          maxPriceInput: null,
          selectedTags: {'%', 'NOWOŚĆ'},
          isFavoriteOnly: false,
          isAvailableOnly: true,
          isDiscountedOnly: false,
        ));
      },
      expect: () => [
        const Loading(),
        isA<Loaded>().having((state) => state.pages.first.products.length, 'filtered products length', greaterThan(0)),
      ],
      verify: (_) {
        final state = homeCubit.state as Loaded;
        final filteredProducts = state.pages.first.products;

        expect(filteredProducts.length, greaterThan(0));
        for (var product in filteredProducts) {
          expect(product.available, isTrue);
          expect(product.tags.any((tag) => tag.label == '%' || tag.label == 'NOWOŚĆ'), isTrue);
        }
      },
    );


    blocTest<HomeCubit, HomeState>(
      'filters products correctly by favorites',
      build: () => homeCubit,
      act: (cubit) async {
        await cubit.applyFilters(const FilterState(
          minPriceInput: null,
          maxPriceInput: null,
          selectedTags: {},
          isFavoriteOnly: true,
          isAvailableOnly: false,
          isDiscountedOnly: false,
        ));
      },
      expect: () => [
        const Loading(),
        isA<Loaded>().having((state) => state.pages.first.products.length, 'filtered products length', greaterThan(0)),
      ],
      verify: (_) {
        final state = homeCubit.state as Loaded;
        final filteredProducts = state.pages.first.products;

        expect(filteredProducts.length, greaterThan(0));
        for (var product in filteredProducts) {
          expect(product.isFavorite, isTrue);
        }
      },
    );

    blocTest<HomeCubit, HomeState>(
      'filters products correctly by discounted status',
      build: () => homeCubit,
      act: (cubit) async {
        await cubit.applyFilters(const FilterState(
          minPriceInput: null,
          maxPriceInput: null,
          selectedTags: {},
          isFavoriteOnly: false,
          isAvailableOnly: false,
          isDiscountedOnly: true,
        ));
      },
      expect: () => [
        const Loading(),
        isA<Loaded>().having((state) => state.pages.first.products.length, 'filtered products length', greaterThan(0)),
      ],
      verify: (_) {
        final state = homeCubit.state as Loaded;
        final filteredProducts = state.pages.first.products;

        expect(filteredProducts.length, greaterThan(0));
        for (var product in filteredProducts) {
          expect(product.offer.promotionalPrice, isNotNull);
          expect(product.offer.promotionalPrice!.amount, lessThan(product.offer.regularPrice.amount));
        }
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits [NoFilteredResults] when filter matches no products',
      build: () => homeCubit,
      act: (cubit) async {
        await cubit.applyFilters(const FilterState(
          minPriceInput: 1000,
          maxPriceInput: 2000,
          selectedTags: {},
          isFavoriteOnly: false,
          isAvailableOnly: true,
          isDiscountedOnly: false,
        ));
      },
      expect: () => [
        const Loading(),
        isA<NoFilteredResults>(),
      ],
      verify: (_) {
        final state = homeCubit.state;
        expect(state, isA<NoFilteredResults>());
      },
    );



  });

  group('HomeCubit Error Handling', () {
    blocTest<HomeCubit, HomeState>(
      'emits [Error] when getNextPage fails',
      build: () {
        when(() => failureRepository.getProductsPage(any())).thenThrow(Exception('Failed to load data'));
        return HomeCubit(failureRepository);
      },
      act: (cubit) => cubit.getNextPage(),
      expect: () => [
        isA<Error>().having(
              (state) => state.error.toString(),
          'error message',
          contains('Failed to load data'),
        ),
      ],
    );
  });

  group('HomeCubit Product Index Search', () {
    test('findProductIndexById returns correct index when product is found', () async {
      await homeCubit.getNextPage();
      final index = await homeCubit.findProductIndexById('933');
      expect(index, equals(3));
    });

    test('findProductIndexById returns null when product is not found', () async {
      await homeCubit.getNextPage();
      final index = await homeCubit.findProductIndexById('non-existent-id');
      expect(index, isNull);
    });
  });

  blocTest<HomeCubit, HomeState>(
    'resets products and emits [Loaded] after resetProducts is called',
    build: () => homeCubit,
    act: (cubit) => cubit.resetProducts(),
    expect: () => [
      const Loading(),
      isA<Loaded>(),
    ],
    verify: (_) {
      final state = homeCubit.state as Loaded;
      expect(state.pages.length, equals(1));
      expect(state.pages.first.products.length, greaterThan(0));
    },
  );
}
