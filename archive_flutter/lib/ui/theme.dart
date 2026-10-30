import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const archiveInk = Color(0xFF173C34);
const archivePaper = Color(0xFFF5F4EF);
const archiveAccent = Color(0xFFB8D7A0);

ThemeData archiveTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
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
        brightness: brightness,
      ).copyWith(
        primary: dark ? archiveAccent : archiveInk,
        onPrimary: dark ? archiveInk : Colors.white,
        secondary: dark ? archiveAccent : const Color(0xFF607A43),
        surface: dark ? const Color(0xFF202725) : Colors.white,
        onSurface: dark ? const Color(0xFFE5EAE6) : const Color(0xFF27332F),
        onSurfaceVariant: dark
            ? const Color(0xFFB8C3BE)
            : const Color(0xFF59695F),
        outlineVariant: dark
            ? const Color(0xFF46514B)
            : const Color(0xFFDDDFD7),
        error: dark ? const Color(0xFFFFB4AB) : const Color(0xFF9C392C),
        errorContainer: dark
            ? const Color(0xFF51302C)
            : const Color(0xFFFFE6DF),
        onErrorContainer: dark
            ? const Color(0xFFFFDAD4)
            : const Color(0xFF782B21),
      );
  final paper = dark ? const Color(0xFF161C1A) : archivePaper;
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: paper,
    extensions: [dark ? ArchiveColors.dark : ArchiveColors.light],
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: dark ? scheme.onSurface : archiveInk,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: paper,
      foregroundColor: scheme.onSurface,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
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
    dividerColor: scheme.outlineVariant,
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
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 38,
                color: Theme.of(context).colorScheme.primary,
              ),
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
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

@immutable
class ArchiveColors extends ThemeExtension<ArchiveColors> {
  const ArchiveColors({
    required this.panel,
    required this.subtleSurface,
    required this.warningSurface,
    required this.warningText,
  });
  final Color panel, subtleSurface, warningSurface, warningText;
  static const light = ArchiveColors(
    panel: Color(0xFFEBEBE7),
    subtleSurface: Color(0xFFF5F4EF),
    warningSurface: Color(0xFFF3EAD2),
    warningText: Color(0xFF78582D),
  );
  static const dark = ArchiveColors(
    panel: Color(0xFF2B302D),
    subtleSurface: Color(0xFF29332D),
    warningSurface: Color(0xFF3B3221),
    warningText: Color(0xFFF4D38F),
  );
  @override
  ArchiveColors copyWith({
    Color? panel,
    Color? subtleSurface,
    Color? warningSurface,
    Color? warningText,
  }) => ArchiveColors(
    panel: panel ?? this.panel,
    subtleSurface: subtleSurface ?? this.subtleSurface,
    warningSurface: warningSurface ?? this.warningSurface,
    warningText: warningText ?? this.warningText,
  );
  @override
  ArchiveColors lerp(covariant ArchiveColors? other, double t) => other == null
      ? this
      : ArchiveColors(
          panel: Color.lerp(panel, other.panel, t)!,
          subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!,
          warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
          warningText: Color.lerp(warningText, other.warningText, t)!,
        );
}

extension ArchiveThemeContext on BuildContext {
  ColorScheme get archiveScheme => Theme.of(this).colorScheme;
  ArchiveColors get archiveColors =>
      Theme.of(this).extension<ArchiveColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? ArchiveColors.dark
          : ArchiveColors.light);
}
