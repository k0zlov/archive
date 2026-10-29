import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const archiveInk = Color(0xFF173C34);
const archivePaper = Color(0xFFF5F4EF);
const archiveAccent = Color(0xFFB8D7A0);

ThemeData archiveTheme() {
  GoogleFonts.config.allowRuntimeFetching = false;
  final buttonText = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    textStyle: const TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );
  final scheme =
      ColorScheme.fromSeed(
        seedColor: archiveInk,
        brightness: Brightness.light,
      ).copyWith(
        primary: archiveInk,
        secondary: const Color(0xFF607A43),
        surface: Colors.white,
      );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: archivePaper,
    textTheme: GoogleFonts.manropeTextTheme().apply(
      bodyColor: const Color(0xFF27332F),
      displayColor: archiveInk,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(backgroundColor: archivePaper, elevation: 0),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDFD7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDFD7)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        alignment: Alignment.center,
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        alignment: Alignment.center,
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 48),
        alignment: Alignment.center,
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    dividerColor: const Color(0xFFE0E3DC),
  );
}

class EmptyArchive extends StatelessWidget {
  const EmptyArchive({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.icon = Icons.inventory_2_outlined,
  });
  final String title;
  final String message;
  final Widget? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: archiveInk.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 38, color: archiveInk),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF67766D), height: 1.6),
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    ),
  );
}

void showArchiveMessage(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
