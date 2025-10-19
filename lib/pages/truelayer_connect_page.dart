// lib/pages/truelayer_connect_page.dart

import 'package:aada_app/widgets/shared/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/subscription_model.dart';
import '../provider/simplified_subscription_provider.dart';
import '../services/truelayer_service.dart';
import '../theme/design_system.dart';
import '../widgets/subscription_popup.dart'; // Import the popup

class TruelayerConnectPage extends StatefulWidget {
  final String countryCode;
  final String? providerId;

  const TruelayerConnectPage({
    super.key,
    required this.countryCode,
    this.providerId,
  });

  @override
  State<TruelayerConnectPage> createState() => _TruelayerConnectPageState();
}

class _TruelayerConnectPageState extends State<TruelayerConnectPage> {
  final _truelayerService = TruelayerService();
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _connectionFinished = false;
  List<Subscription> _foundSubscriptions = [];
  String? _errorMessage;

  final Set<String> _selectedSubscriptionIds = {};

  @override
  void initState() {
    super.initState();
    _connectToTruelayer();
  }

  void _connectToTruelayer() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.startsWith(_truelayerService.redirectUri)) {
              setState(() => _isLoading = true);
              final uri = Uri.parse(url);
              final code = uri.queryParameters['code'];
              final error = uri.queryParameters['error'];
              if (error != null) {
                setState(() {
                  _errorMessage = "Authentication failed: $error";
                  _connectionFinished = true;
                  _isLoading = false;
                });
              } else if (code != null) {
                _getSubscriptionData(code);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_truelayerService.getAuthenticationUrl(
        widget.countryCode,
        providerId: widget.providerId,
      )));
    setState(() {});
  }

  Future<void> _getSubscriptionData(String code) async {
    try {
      final accessToken = await _truelayerService.exchangeCodeForAccessToken(code);
      if (accessToken == null) throw Exception("Failed to get access token");

      final subscriptions = await _truelayerService.getSubscriptions();
      if (mounted) {
        setState(() {
          _foundSubscriptions = subscriptions;
          _selectedSubscriptionIds.addAll(subscriptions.map((s) => s.id));
          _isLoading = false;
          _connectionFinished = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _connectionFinished = true;
        });
      }
    }
  }

  void _toggleSubscriptionSelection(String subId) {
    setState(() {
      if (_selectedSubscriptionIds.contains(subId)) {
        _selectedSubscriptionIds.remove(subId);
      } else {
        _selectedSubscriptionIds.add(subId);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedSubscriptionIds.length == _foundSubscriptions.length) {
        _selectedSubscriptionIds.clear();
      } else {
        _selectedSubscriptionIds.addAll(_foundSubscriptions.map((s) => s.id));
      }
    });
  }

  void _editSubscription(Subscription subToEdit) {
    showAddSubscriptionPopup(
      context,
          (editedSub) {
        setState(() {
          final index = _foundSubscriptions.indexWhere((s) => s.id == subToEdit.id);
          if (index != -1) {
            _foundSubscriptions[index] = editedSub;
          }
        });
      },
      subscriptionToEdit: subToEdit,
    );
  }

  void _addSelectedSubscriptions() {
    final provider = Provider.of<SimplifiedSubscriptionProvider>(context, listen: false);
    for (final subId in _selectedSubscriptionIds) {
      final subToAdd = _foundSubscriptions.firstWhere((s) => s.id == subId);
      provider.addSubscription(subToAdd);
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionFinished) {
      if (_errorMessage != null) {
        return _buildErrorScaffold();
      } else if (_foundSubscriptions.isNotEmpty) {
        return _buildResultsView();
      } else {
        return _buildNoResultsScaffold();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connecting to Bank...'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Scaffold _buildErrorScaffold() {
    return Scaffold(
        appBar: AppBar(title: const Text('Connection Failed')),
        body: _buildErrorView());
  }

  Scaffold _buildNoResultsScaffold() {
    return Scaffold(
        appBar: AppBar(title: const Text('Connection Complete')),
        body: _buildNoResultsView());
  }

  Widget _buildResultsView() {
    final bool allSelected = _selectedSubscriptionIds.length == _foundSubscriptions.length;

    return Scaffold(
      bottomNavigationBar: _buildBottomActionBar(),
      body: PageLayout(
        addTopPadding: false,
        onRefresh: () async {},
        slivers: [
          SliverAppBar(
            title: const Text('Review Subscriptions'),
            pinned: true,
            floating: true,
            actions: [
              TextButton.icon(
                onPressed: _toggleSelectAll,
                icon: Icon(allSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded),
                label: Text(allSelected ? 'Deselect All' : 'Select All'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(DesignSystem.spacing12),
              margin: const EdgeInsets.all(DesignSystem.spacing8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We found ${_foundSubscriptions.length} recurring payments.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select the subscriptions you want to track and edit any details if needed.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final sub = _foundSubscriptions[index];
                  final isSelected = _selectedSubscriptionIds.contains(sub.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DesignSystem.spacing6),
                    child: _buildSelectableSubscriptionCard(sub, isSelected),
                  );
                },
                childCount: _foundSubscriptions.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing10).copyWith(bottom: DesignSystem.spacing10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          icon: const Icon(Icons.add_task_rounded),
          onPressed: _selectedSubscriptionIds.isNotEmpty ? _addSelectedSubscriptions : null,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            ),
          ),
          label: Text(
            _selectedSubscriptionIds.isNotEmpty
                ? 'Add Selected (${_selectedSubscriptionIds.length})'
                : 'Select Subscriptions to Add',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableSubscriptionCard(Subscription sub, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withOpacity(0.5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      color: isSelected ? colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08) : colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spacing10,
          vertical: DesignSystem.spacing4,
        ),
        leading: Checkbox(
          value: isSelected,
          onChanged: (_) => _toggleSubscriptionSelection(sub.id),
          activeColor: colorScheme.primary,
        ),
        title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${sub.amount.abs().toStringAsFixed(2)}€ / ${sub.cycle}',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit_outlined, color: colorScheme.primary, size: DesignSystem.iconMedium),
          onPressed: () => _editSubscription(sub),
        ),
        onTap: () => _toggleSubscriptionSelection(sub.id),
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
            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('Connection Failed', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'An unknown error occurred.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No Subscriptions Found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t detect any recurring payments in your accounts. You can still add them manually.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
