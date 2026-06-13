import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark; // Dark mode is default for premium AI first look
});
