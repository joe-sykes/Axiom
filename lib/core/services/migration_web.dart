import 'dart:html' as html;

import 'migration_service.dart';

/// Get the current hostname
String getCurrentHost() {
  return html.window.location.hostname ?? '';
}

/// Check if we're on an old domain that should show migration banner
bool isOnOldDomain() {
  final host = getCurrentHost();
  return MigrationService.oldDomains.contains(host);
}

/// Check if we're on the new domain
bool isOnNewDomain() {
  final host = getCurrentHost();
  return host == MigrationService.newDomain || host == 'www.${MigrationService.newDomain}';
}

/// Get migration data from URL parameter if present
String? getMigrationParam() {
  final uri = Uri.parse(html.window.location.href);
  return uri.queryParameters['migrate'];
}

/// Remove the migration parameter from URL (clean up after import)
void clearMigrationParam() {
  final uri = Uri.parse(html.window.location.href);
  if (uri.queryParameters.containsKey('migrate')) {
    final newParams = Map<String, String>.from(uri.queryParameters)
      ..remove('migrate');
    final newUri = uri.replace(queryParameters: newParams.isEmpty ? null : newParams);
    html.window.history.replaceState(null, '', newUri.toString());
  }
}

/// Redirect to the new domain with migration data
void redirectToNewDomain(String migrationUrl) {
  html.window.location.href = migrationUrl;
}
