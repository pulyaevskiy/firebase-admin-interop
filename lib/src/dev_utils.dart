bool _devPrintEnabled = true;

@Deprecated('Dev only')
set devPrintEnabled(bool enabled) => _devPrintEnabled = enabled;

/// Deprecated to prevent keeping the code used.
@Deprecated('Dev only')
void devPrint(Object? object) {
  if (_devPrintEnabled) {
    print(object);
  }
}
