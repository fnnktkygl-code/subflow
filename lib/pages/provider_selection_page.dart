// lib/pages/provider_selection_page.dart

import 'package:flutter/material.dart';
import '../widgets/shared/page_layout.dart';
import '../models/truelayer_provider.dart';
import '../services/truelayer_service.dart';
import '../theme/design_system.dart';
import 'truelayer_connect_page.dart';

class ProviderSelectionPage extends StatefulWidget {
  final String countryCode;

  const ProviderSelectionPage({super.key, required this.countryCode});

  @override
  State<ProviderSelectionPage> createState() => _ProviderSelectionPageState();
}

class _ProviderSelectionPageState extends State<ProviderSelectionPage> {
  final _truelayerService = TruelayerService();
  List<TruelayerProvider> _providers = [];
  List<TruelayerProvider> _filteredProviders = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProviders();
    _searchController.addListener(_filterProviders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProviders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProviders = query.isEmpty
          ? _providers
          : _providers
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final providers = await _truelayerService.getProviders(widget.countryCode);
      if (mounted) {
        setState(() {
          _providers = providers;
          _filteredProviders = providers;
          if (providers.isEmpty) {
            _error = 'No banks are currently available for this country.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load banks. Please check your connection.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectProvider(TruelayerProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TruelayerConnectPage(
          countryCode: widget.countryCode,
          providerId: provider.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageLayout(
        addTopPadding: false,
        onRefresh: _loadProviders,
        slivers: [
          SliverAppBar(
            title: Text('Select Bank in ${widget.countryCode}'),
            pinned: true,
            floating: true,
            bottom: _isLoading
                ? const PreferredSize(
              preferredSize: Size.fromHeight(4.0),
              child: LinearProgressIndicator(),
            )
                : PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: _buildSearchField(),
            ),
          ),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for your bank...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () => _searchController.clear(),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      // The SliverAppBar shows a LinearProgressIndicator
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (_error != null) {
      return SliverFillRemaining(child: _buildErrorView());
    }
    if (_providers.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyView());
    }
    if (_filteredProviders.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text('No banks found for "${_searchController.text}"'),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(DesignSystem.spacing8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final provider = _filteredProviders[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignSystem.spacing6),
              child: _buildProviderCard(provider),
            );
          },
          childCount: _filteredProviders.length,
        ),
      ),
    );
  }

  Widget _buildProviderCard(TruelayerProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spacing10,
          vertical: DesignSystem.spacing6,
        ),
        leading: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall - 2),
            child: provider.logoUrl.isNotEmpty
                ? Image.network(
              provider.logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.account_balance,
                color: colorScheme.primary,
              ),
            )
                : Icon(Icons.account_balance, color: colorScheme.primary),
          ),
        ),
        title: Text(
          provider.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () => _selectProvider(provider),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadProviders,
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No banks available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'There are no banks available for this country at the moment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
