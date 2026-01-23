/// Stub implementations for non-web platforms

String getCurrentHost() => '';

bool isOnOldDomain() => false;

bool isOnNewDomain() => false;

String? getMigrationParam() => null;

void clearMigrationParam() {}

void redirectToNewDomain(String migrationUrl) {}
