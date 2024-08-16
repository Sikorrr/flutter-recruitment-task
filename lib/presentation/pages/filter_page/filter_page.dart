import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/validators/validator.dart';
import '../home_page/home_cubit.dart';
import 'filter_cubit.dart';

class FilterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
      ),
      body: BlocBuilder<FilterCubit, FilterState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: state.minPriceInput?.toString(),
                          onChanged: (text) {
                            context.read<FilterCubit>().updateMinPriceInput(text);
                          },
                          validator: (text) => validatePrice(state.minPriceInput?.toString() ?? '', text ?? ''),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            helperText: '',
                            labelText: 'from',
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          initialValue: state.maxPriceInput?.toString(),
                          onChanged: (text) {
                            context.read<FilterCubit>().updateMaxPriceInput(text);
                          },
                          validator: (text) => validatePrice(state.minPriceInput?.toString() ?? '', text ?? ''),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            helperText: '',
                            labelText: 'to',
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                            errorStyle: TextStyle(height: 1.4),
                            errorMaxLines: 2,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: state.tags.map((tag) {
                      return FilterChip(
                        label: Text(tag),
                        selected: state.selectedTags.contains(tag),
                        onSelected: (bool selected) {
                          context.read<FilterCubit>().toggleTag(tag);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Additional Options', style: TextStyle(fontWeight: FontWeight.bold)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show only favorites'),
                    value: state.isFavoriteOnly,
                    onChanged: (value) {
                      context.read<FilterCubit>().toggleFavoriteOnly();
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show only available'),
                    value: state.isAvailableOnly,
                    onChanged: (value) {
                      context.read<FilterCubit>().toggleAvailableOnly();
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show only discounted'),
                    value: state.isDiscountedOnly,
                    onChanged: (value) {
                      context.read<FilterCubit>().toggleDiscountedOnly();
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<FilterCubit>().resetFilters();
                            context.read<HomeCubit>().resetProducts();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<HomeCubit>().applyFilters(state);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Show Results'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
