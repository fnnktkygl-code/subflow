// lib/pages/provider_selection_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      if (query.isEmpty) {
        _filteredProviders = _providers;
      } else {
        _filteredProviders = _providers
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadProviders() async {
    if (kDebugMode) {
      print("=== LOADING PROVIDERS FOR: ${widget.countryCode} ===");
    }
    try {
      final providers = await _truelayerService.getProviders(widget.countryCode);
      if (kDebugMode) {
        print("=== RECEIVED ${providers.length} PROVIDERS ===");
      }

      if (mounted) {
        setState(() {
          _providers = providers;
          _filteredProviders = providers;
          _isLoading = false;
          if (providers.isEmpty) {
            _error = 'No banks are currently available for this country in the live environment.';
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("=== ERROR LOADING PROVIDERS: $e ===");
      }
      if (mounted) {
        setState(() {
          _error = 'Failed to load banks. Please check your connection and try again.';
          _isLoading = false;
        });
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
      appBar: AppBar(
        title: Text('Banks in ${widget.countryCode}'),
        bottom: _isLoading || _error != null
            ? null
            : PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for your bank...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacing12,
                  vertical: DesignSystem.spacing10,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorView();
    }

    if (_providers.isEmpty) {
      return _buildEmptyView();
    }

    if (_filteredProviders.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Text('No banks found for "${_searchController.text}"'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProviders.length,
      itemBuilder: (context, index) {
        final provider = _filteredProviders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          elevation: 0,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spacing10,
              vertical: DesignSystem.spacing8,
            ),
            leading: provider.logoUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
              child: Image.network(
                provider.logoUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.account_balance,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
                : Icon(
              Icons.account_balance,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              provider.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onTap: () => _selectProvider(provider),
          ),
        );
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadProviders();
              },
              child: const Text('Retry'),
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
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No banks are available for this country at the moment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This can happen if you are in Live mode and the banks for this region are in Private Beta.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
