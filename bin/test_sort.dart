import 'dart:io';

void main() {
  List<double?> distances = [326100.0, 1000.0, 400000.0, 900000.0, null];
  distances.sort((a, b) => (a ?? 999999999.0).compareTo(b ?? 999999999.0));
  print(distances);
}
