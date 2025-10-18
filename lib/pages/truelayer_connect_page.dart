// lib/pages/truelayer_connect_page.dart

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

  // ✅ NEW: State to manage user selections
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
          // ✅ NEW: Select all found subscriptions by default
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

  // ✅ NEW: Toggle selection for a single subscription
  void _toggleSubscriptionSelection(String subId) {
    setState(() {
      if (_selectedSubscriptionIds.contains(subId)) {
        _selectedSubscriptionIds.remove(subId);
      } else {
        _selectedSubscriptionIds.add(subId);
      }
    });
  }

  // ✅ NEW: Toggle selection for all subscriptions
  void _toggleSelectAll() {
    setState(() {
      if (_selectedSubscriptionIds.length == _foundSubscriptions.length) {
        _selectedSubscriptionIds.clear(); // Deselect all
      } else {
        _selectedSubscriptionIds.addAll(_foundSubscriptions.map((s) => s.id)); // Select all
      }
    });
  }

  // ✅ NEW: Handle editing a subscription *before* it's added
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

  // ✅ UPDATED: Only add the selected subscriptions
  void _addSelectedSubscriptions() {
    final provider = Provider.of<SimplifiedSubscriptionProvider>(context, listen: false);
    for (final subId in _selectedSubscriptionIds) {
      final subToAdd = _foundSubscriptions.firstWhere((s) => s.id == subId);
      provider.addSubscription(subToAdd);
    }
    // Pop twice to go back to the original screen
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Bank'),
        automaticallyImplyLeading: _connectionFinished,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_connectionFinished) {
      if (_errorMessage != null) {
        return _buildErrorView();
      } else if (_foundSubscriptions.isNotEmpty) {
        return _buildResultsView();
      } else {
        return _buildNoResultsView();
      }
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  // ✅ --- MAJOR UI OVERHAUL FOR THE RESULTS VIEW ---
  Widget _buildResultsView() {
    final bool allSelected = _selectedSubscriptionIds.length == _foundSubscriptions.length;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(DesignSystem.spacing12),
          margin: EdgeInsets.all(DesignSystem.spacing8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                colorScheme.primaryContainer.withOpacity(0.2),
                colorScheme.primaryContainer.withOpacity(0.1),
              ]
                  : [
                colorScheme.primaryContainer.withOpacity(0.1),
                colorScheme.primaryContainer.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Your Subscriptions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We found ${_foundSubscriptions.length} recurring payments. Select which ones you\'d like to add.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        // "Select All" button
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacing8,
            vertical: DesignSystem.spacing6,
          ),
          child: OutlinedButton.icon(
            icon: Icon(
              allSelected ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            label: Text(allSelected ? 'Deselect All' : 'Select All'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSystem.spacing12,
                vertical: DesignSystem.spacing8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              side: BorderSide(
                color: colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
            ),
            onPressed: _toggleSelectAll,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing6),
        // List of selectable subscriptions
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
            itemCount: _foundSubscriptions.length,
            separatorBuilder: (_, __) => SizedBox(height: DesignSystem.spacing6),
            itemBuilder: (context, index) {
              final sub = _foundSubscriptions[index];
              final isSelected = _selectedSubscriptionIds.contains(sub.id);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? colorScheme.primary.withOpacity(isDark ? 0.12 : 0.08)
                      : colorScheme.surface,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacing10,
                    vertical: DesignSystem.spacing4,
                  ),
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSubscriptionSelection(sub.id),
                    activeColor: colorScheme.primary,
                  ),
                  title: Text(
                    sub.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${sub.amount.abs().toStringAsFixed(2)}€ / ${sub.cycle}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: colorScheme.primary,
                      size: DesignSystem.iconMedium,
                    ),
                    onPressed: () => _editSubscription(sub),
                  ),
                  onTap: () => _toggleSubscriptionSelection(sub.id),
                ),
              );
            },
          ),
        ),
        // Bottom "Add Selected" button
        Container(
          padding: EdgeInsets.all(DesignSystem.spacing10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _selectedSubscriptionIds.isNotEmpty
                    ? _addSelectedSubscriptions
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor:
                  colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusMedium,
                    ),
                  ),
                ),
                child: Text(
                  _selectedSubscriptionIds.isNotEmpty
                      ? 'Add Selected (${_selectedSubscriptionIds.length})'
                      : 'Select a Subscription',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Other build methods remain the same ---
  Widget _buildErrorView() { /* ... */ return Container(); }
  Widget _buildNoResultsView() { /* ... */ return Container(); }
}

