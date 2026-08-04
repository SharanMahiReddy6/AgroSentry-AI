import 'package:mobile/l10n/app_localizations.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/core/widgets/empty_view.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';
import 'package:mobile/features/tips/presentation/providers/tips_provider.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(tipsSearchQueryProvider);
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
      ref.read(tipsSearchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTipsAsync = ref.watch(filteredTipsProvider);
    final categoriesAsync = ref.watch(tipsAvailableCategoriesProvider);
    
    final selectedCategory = ref.watch(tipsCategoryFilterProvider);

    return AppScaffold(
      title: (AppLocalizations.of(context)?.quickTips ?? 'Quick Tips'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubmitModal(context),
        icon: const Icon(Icons.add),
        label: Text((AppLocalizations.of(context)?.submitTip ?? 'Submit Tip')),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(quickTipsProvider);
          await ref.read(quickTipsProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Semantics(
                  label: (AppLocalizations.of(context)?.searchQuickTips ?? 'Search quick tips'),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: (AppLocalizations.of(context)?.searchByTitleCategory ?? 'Search by title, category...'),
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
            ),
            
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (categories) => SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Semantics(
                          label: 'Filter by $category category',
                          child: FilterChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              ref.read(tipsCategoryFilterProvider.notifier).state =
                                  selected ? category : null;
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            filteredTipsAsync.when(
              data: (tips) {
                if (tips.isEmpty) {
                  return SliverFillRemaining(
                    child: Semantics(
                      label: (AppLocalizations.of(context)?.noTipsFound ?? 'No tips found'),
                      child: const EmptyView(
                        message: 'No tips found matching your criteria.',
                      ),
                    ),
                  );
                }

                // If no search is active, show featured vs recent
                final isSearching = ref.read(tipsSearchQueryProvider).isNotEmpty || 
                                    ref.read(tipsCategoryFilterProvider) != null;

                if (!isSearching && tips.length > 3) {
                  final featured = tips.take(3).toList();
                  final recent = tips.skip(3).toList();
                  
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          (AppLocalizations.of(context)?.featuredTips ?? 'Featured Tips'),
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...featured.map((tip) => _buildTipCard(context, tip)),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          (AppLocalizations.of(context)?.recentTips ?? 'Recent Tips'),
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...recent.map((tip) => _buildTipCard(context, tip)),
                      const SizedBox(height: 24),
                    ]),
                  );
                }

                // Standard list when searching
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTipCard(context, tips[index]),
                    childCount: tips.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text((AppLocalizations.of(context)?.failedToLoadTips ?? 'Failed to load tips'), style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(quickTipsProvider.future),
                        child: Text((AppLocalizations.of(context)?.retry ?? 'Retry')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, QuickTipModel tip) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: 'Tip card: ${tip.title}',
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/tips/detail', extra: tip);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        tip.category, 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    ),
                    Text(
                      tip.readTime,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tip.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  tip.description,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      tip.author,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSubmitModal(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final detailedContentController = TextEditingController();
    String selectedCategory = 'General';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text((AppLocalizations.of(context)?.submitAQuickTip ?? 'Submit a Quick Tip'), style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.title ?? 'Title'), border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.category ?? 'Category'), border: const OutlineInputBorder()),
                      items: ['General', 'Apple', 'Tomato', 'Potato', 'Corn', 'Grape'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.briefContent ?? 'Brief Content'), border: const OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailedContentController,
                      decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.detailedExplanation ?? 'Detailed Explanation'), border: const OutlineInputBorder()),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.isEmpty || contentController.text.isEmpty) return;
                              setState(() => isSubmitting = true);
                              try {
                                final response = await ref.read(tipsRepositoryProvider).submitTip({
                                  'title': titleController.text,
                                  'category': selectedCategory,
                                  'content': contentController.text,
                                  'detailed_content': detailedContentController.text,
                                });
                                if (!context.mounted) return;
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(response['is_approved'] == true 
                                    ? 'Insight submitted! Since you are an Admin, your tip has been automatically approved and published!'
                                    : 'Insight submitted! An agronomist will review and approve your submission shortly.'),
                                  backgroundColor: Colors.green,
                                ));
                                ref.refresh(quickTipsProvider);
                              } catch (e) {
                                setState(() => isSubmitting = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text((AppLocalizations.of(context)?.failedToSubmitTipPleaseCheckAllFields ?? 'Failed to submit tip. Please check all fields.')),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            },
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                            child: Text((AppLocalizations.of(context)?.submitTip ?? 'Submit Tip'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}
