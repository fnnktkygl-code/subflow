// lib/pages/debug_api_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/truelayer_service.dart';
import '../models/subscription_model.dart';
import '../theme/design_system.dart';

class DebugApiPage extends StatefulWidget {
  const DebugApiPage({super.key});

  @override
  State<DebugApiPage> createState() => _DebugApiPageState();
}

class _DebugApiPageState extends State<DebugApiPage> {
  final _truelayerService = TruelayerService();
  // ✅ START in a loading state.
  bool _isLoading = true;
  String? _error;

  // Data containers
  List<Map<String, dynamic>> _accounts = [];
  final Map<String, List<dynamic>> _directDebitsByAccount = {};
  final Map<String, List<dynamic>> _standingOrdersByAccount = {};
  final Map<String, List<dynamic>> _transactionsByAccount = {};
  final Map<String, DateTime?> _oldestTransactionByAccount = {};
  final Map<String, DateTime?> _newestTransactionByAccount = {};
  List<Subscription> _detectedSubscriptions = [];
  List<String> _detectionLogs = [];

  // ✅ ADD: Fetch data immediately when the page loads.
  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueLayer API Debug'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchAllData,
              tooltip: 'Refresh',
            ),
        ],
      ),
      // ✅ UPDATE: The body logic is now simpler and more robust.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
          : _accounts.isEmpty
          ? _buildEmptyView() // This now correctly means "0 accounts found"
          : _buildDataView(),
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
            Text(_error ?? 'Unknown error', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchAllData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ UPDATE: The "empty" view now has a more accurate message.
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Accounts Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The API call succeeded, but no accounts were returned. This can happen if none were shared during authentication.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchAllData,
              child: const Text('Try Reloading'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 16),
        _buildApiLimitsCard(),
        const SizedBox(height: 16),
        _buildAccountsCard(),
        const SizedBox(height: 16),
        _buildDetectionLogsCard(),
        const SizedBox(height: 16),
        _buildDetectedSubscriptionsCard(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalDirectDebits = _directDebitsByAccount.values
        .fold(0, (sum, list) => sum + (list.length));
    final totalStandingOrders = _standingOrdersByAccount.values
        .fold(0, (sum, list) => sum + (list.length));
    final totalTransactions = _transactionsByAccount.values
        .fold(0, (sum, list) => sum + (list.length));

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spacing8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: colorScheme.primary,
                    size: DesignSystem.iconLarge,
                  ),
                ),
                const SizedBox(width: DesignSystem.spacing10),
                Text(
                  'API Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            Divider(
              height: DesignSystem.spacing12 * 2,
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
            _buildInfoRow('Connected Accounts', '${_accounts.length}'),
            _buildInfoRow(
              'Direct Debits Found',
              '$totalDirectDebits',
            ),
            _buildInfoRow(
              'Standing Orders Found',
              '$totalStandingOrders',
            ),
            _buildInfoRow(
              'Transactions Retrieved',
              '$totalTransactions',
            ),
            Padding(
              padding: const EdgeInsets.only(top: DesignSystem.spacing8),
              child: _buildInfoRow(
                'Subscriptions Detected',
                '${_detectedSubscriptions.length}',
                isHighlight: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiLimitsCard() {
    DateTime? oldestOverall;
    DateTime? newestOverall;

    for (var oldest in _oldestTransactionByAccount.values) {
      if (oldest != null &&
          (oldestOverall == null || oldest.isBefore(oldestOverall))) {
        oldestOverall = oldest;
      }
    }

    for (var newest in _newestTransactionByAccount.values) {
      if (newest != null &&
          (newestOverall == null || newest.isAfter(newestOverall))) {
        newestOverall = newest;
      }
    }

    final daysCovered = (oldestOverall != null && newestOverall != null)
        ? newestOverall.difference(oldestOverall).inDays
        : null;

    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Transaction History Limits',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (oldestOverall != null && newestOverall != null) ...[
              _buildInfoRow(
                  'Oldest Transaction', dateFormat.format(oldestOverall)),
              _buildInfoRow(
                  'Newest Transaction', dateFormat.format(newestOverall)),
              _buildInfoRow('Days of History', '${daysCovered ?? 0} days',
                  isHighlight: true),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Most French banks provide ~90 days of transaction history via TrueLayer API.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text('No transaction data available'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Account Details',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ..._accounts.map((account) {
              final accountId = (account['account_id'] ?? '').toString();
              final displayName =
                  account['display_name']?.toString() ?? 'Unknown Account';
              final accountType = account['account_type']?.toString() ?? 'N/A';
              final directDebits = _directDebitsByAccount[accountId] ?? [];
              final standingOrders = _standingOrdersByAccount[accountId] ?? [];
              final transactions = _transactionsByAccount[accountId] ?? [];
              final oldest = _oldestTransactionByAccount[accountId];
              final newest = _newestTransactionByAccount[accountId];
              final shortId =
              accountId.length > 12 ? '${accountId.substring(0, 12)}...' : accountId;

              return ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Type: $accountType • ID: $shortId'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        _buildInfoRow('Direct Debits', '${directDebits.length}'),
                        _buildInfoRow(
                            'Standing Orders', '${standingOrders.length}'),
                        _buildInfoRow('Transactions', '${transactions.length}'),
                        if (oldest != null && newest != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Transaction Period',
                            '${DateFormat('dd/MM/yy').format(oldest)} → ${DateFormat('dd/MM/yy').format(newest)}',
                          ),
                          _buildInfoRow(
                            'Coverage',
                            '${newest.difference(oldest).inDays} days',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionLogsCard() {
    if (_detectionLogs.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Detection Logs',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _detectionLogs.map((log) {
                    Color? color;
                    IconData? icon;
                    if (log.contains('✓ ADDED') || log.contains('✅')) {
                      color = Colors.green;
                      icon = Icons.check_circle_outline;
                    } else if (log.contains('⊗ SKIPPED') || log.contains('❌')) {
                      color = Colors.orange;
                      icon = Icons.cancel_outlined;
                    } else if (log.contains('🔍') || log.contains('💳')) {
                      color = Theme.of(context).colorScheme.primary;
                      icon = Icons.search;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (icon != null)
                            Icon(icon, size: 16, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: color ?? Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedSubscriptionsCard() {
    if (_detectedSubscriptions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.subscriptions,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Detected Subscriptions',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ..._detectedSubscriptions.map((sub) {
              final title = (sub.name.isNotEmpty) ? sub.name : 'Subscription';
              final firstLetter = (title.isNotEmpty) ? title[0].toUpperCase() : '?';
              final startDateStr =
              DateFormat('dd/MM/yyyy').format(sub.startDate);

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Text(firstLetter),
                ),
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${sub.amount.abs().toStringAsFixed(2)}€ / ${sub.cycle}\n'
                      'Start: $startDateStr',
                ),
                isThreeLine: true,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value, {
        bool isHighlight = false,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacing4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? colorScheme.primary : colorScheme.onSurface,
              fontSize: isHighlight ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _detectionLogs.clear();
      _accounts = [];
      _directDebitsByAccount.clear();
      _standingOrdersByAccount.clear();
      _transactionsByAccount.clear();
      _oldestTransactionByAccount.clear();
      _newestTransactionByAccount.clear();
      _detectedSubscriptions = [];
    });

    try {
      final detected = await _truelayerService.getSubscriptions();

      final accessToken = await _truelayerService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Not authenticated. Please connect a bank account in Settings.');
      }

      final accountsResponse = await _truelayerService.fetchAccounts(accessToken);

      if (mounted) {
        setState(() {
          _detectedSubscriptions = detected;
          _accounts = (accountsResponse).map((e) => e as Map<String, dynamic>).toList();
        });
      }

      for (var account in _accounts) {
        final accountId = (account['account_id'] ?? '').toString();

        final debits = await _truelayerService.fetchDirectDebitsRaw(accountId, accessToken);
        final orders = await _truelayerService.fetchStandingOrdersRaw(accountId, accessToken);
        final transactions = await _truelayerService.fetchTransactionsRaw(accountId, accessToken);

        if (mounted) {
          setState(() {
            _directDebitsByAccount[accountId] = debits;
            _standingOrdersByAccount[accountId] = orders;
            _transactionsByAccount[accountId] = transactions;
            if (transactions.isNotEmpty) {
              final parsedDates = transactions
                  .map((t) => DateTime.tryParse(t['timestamp']?.toString() ?? ''))
                  .whereType<DateTime>()
                  .toList()..sort();
              if (parsedDates.isNotEmpty) {
                _oldestTransactionByAccount[accountId] = parsedDates.first;
                _newestTransactionByAccount[accountId] = parsedDates.last;
              }
            }
          });
        }
      }

      if (mounted) {
        setState(() {
          _detectionLogs = [
            '🔍 Starting subscription detection...',
            '💳 Found ${_accounts.length} account(s)',
            '📊 Processing ${_transactionsByAccount.values.fold(0, (sum, list) => sum + list.length)} transactions',
            '✅ Detected ${_detectedSubscriptions.length} subscription(s)',
          ];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

