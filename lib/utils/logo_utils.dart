String fetchLogo(String subscriptionName) {
  // Format the subscription name to replace spaces with dots and append ".com" if necessary
  final formattedName = subscriptionName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  final domainName = formattedName.contains('.') ? formattedName : "$formattedName.com";

  // Generate the final URL for the demo
  return 'https://img.demo.dev/$domainName?token=pk_QtDacf-LTiKOC0yHo15DDA';
}
