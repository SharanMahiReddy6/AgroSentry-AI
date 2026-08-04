import 'package:mobile/l10n/app_localizations.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/core/widgets/empty_view.dart';

import 'package:mobile/features/library/presentation/providers/library_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Initialize search text from provider if it exists
    _searchController.text = ref.read(librarySearchQueryProvider);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(librarySearchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredDiseasesAsync = ref.watch(filteredLibraryDiseasesProvider);
    final cropsAsync = ref.watch(libraryAvailableCropsProvider);
    
    final selectedCrop = ref.watch(libraryCropFilterProvider);
    final selectedHealth = ref.watch(libraryHealthFilterProvider);

    return AppScaffold(
      title: (AppLocalizations.of(context)?.diseaseLibrary ?? 'Disease Library'),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Semantics(
              label: (AppLocalizations.of(context)?.searchDiseaseLibrary ?? 'Search disease library'),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: (AppLocalizations.of(context)?.searchByDiseaseScientificNameOrCrop ?? 'Search by disease, scientific name, or crop...'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          
          // Filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Health Filter
                Semantics(
                  label: (AppLocalizations.of(context)?.filterByHealthStatus ?? 'Filter by health status'),
                  child: FilterChip(
                    label: Text((AppLocalizations.of(context)?.healthy ?? 'Healthy')),
                    selected: selectedHealth == 'Healthy',
                    onSelected: (selected) {
                      ref.read(libraryHealthFilterProvider.notifier).state =
                          selected ? 'Healthy' : null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: (AppLocalizations.of(context)?.filterByDiseasedStatus ?? 'Filter by diseased status'),
                  child: FilterChip(
                    label: Text((AppLocalizations.of(context)?.diseased ?? 'Diseased')),
                    selected: selectedHealth == 'Diseased',
                    onSelected: (selected) {
                      ref.read(libraryHealthFilterProvider.notifier).state =
                          selected ? 'Diseased' : null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Crop Filters
                cropsAsync.when(
                  data: (crops) => Row(
                    children: crops.map((crop) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Semantics(
                          label: 'Filter by $crop',
                          child: FilterChip(
                            label: Text(crop),
                            selected: selectedCrop == crop,
                            onSelected: (selected) {
                              ref.read(libraryCropFilterProvider.notifier).state =
                                  selected ? crop : null;
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),

          // List of Diseases
          Expanded(
            child: filteredDiseasesAsync.when(
              data: (diseases) {
                if (diseases.isEmpty) {
                  return Semantics(
                    label: (AppLocalizations.of(context)?.noDiseasesFound ?? 'No diseases found'),
                    child: const EmptyView(
                      message: 'No Results: Try adjusting your search or filters.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: diseases.length,
                  itemBuilder: (context, index) {
                    final disease = diseases[index];
                    final isHealthy = disease.name.toLowerCase().contains('healthy');
                    
                    return Semantics(
                      label: 'Disease card: ${disease.name}',
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/library/detail', extra: disease),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isHealthy 
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.red.withValues(alpha: 0.2),
                                  child: Icon(
                                    isHealthy ? Icons.eco : Icons.coronavirus,
                                    color: isHealthy ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        disease.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Crop: ${disease.cropType}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      (AppLocalizations.of(context)?.failedToLoadLibrary ?? 'Failed to load library'),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(libraryDiseasesProvider.future),
                      child: Text((AppLocalizations.of(context)?.retry ?? 'Retry')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
