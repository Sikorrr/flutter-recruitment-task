import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../utils/extensions/color_extension.dart';
import '../filter_page/filter_page.dart';

const _mainPadding = EdgeInsets.all(16.0);

class HomePage extends StatelessWidget {
  HomePage({super.key, this.productId});

  final String? productId;

  final ItemScrollController itemScrollController = ItemScrollController();

  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BigText('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _navigateToFilterPage(context),
          ),
        ],
      ),
      body: Padding(
        padding: _mainPadding,
        child: BlocConsumer<HomeCubit, HomeState>(
          listener: (context, state) async {
            if (state is Loaded && productId != null) {
              await scrollToProduct(context);
            }
          },
          builder: (context, state) {
            return switch (state) {
              Error() => BigText('Error: ${state.error}'),
              Loading() => const BigText('Loading...'),
              NoFilteredResults() => const BigText('No products found'),
              Loaded() => _LoadedWidget(state: state, itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,),
            };
          },
        ),
      ),
    );
  }

  Future<void> scrollToProduct(BuildContext context) async {
    final cubit = context.read<HomeCubit>();
    final index = await cubit.findProductIndexById(productId!);
    if (index != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _navigateToFilterPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(),
      ),
    );
  }

}

class _LoadedWidget extends StatelessWidget {
  const _LoadedWidget({
    required this.state, required this.itemScrollController, required this.itemPositionsListener,
  });

  final Loaded state;

  final ItemScrollController itemScrollController;

  final ItemPositionsListener itemPositionsListener;

  @override
  Widget build(BuildContext context) {
    final products = state.pages
        .map((page) => page.products)
        .expand((product) => product)
        .toList();

    return ScrollablePositionedList.builder(
      itemCount: products.length + (state.hasMorePages ? 1 : 0),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemBuilder: (context, index) {
        if (index < products.length) {
          final product = products[index];
          return _ProductCard( product);
        } else {
          return const _GetNextPageButton();
        }
      },
    );
  }
}


class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigText(product.name),
          _Tags(product: product),
        ],
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: product.tags.map(_TagWidget.new).toList(),
    );
  }
}

class _TagWidget extends StatelessWidget {
  const _TagWidget(this.tag);

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        color: MaterialStateProperty.all(HexColor.fromHex(tag.color)),
        label: Text(tag.label),
      ),
    );
  }
}

class _GetNextPageButton extends StatelessWidget {
  const _GetNextPageButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: context.read<HomeCubit>().getNextPage,
      child: const BigText('Get next page'),
    );
  }
}
