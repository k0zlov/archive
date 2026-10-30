import 'update_platform.dart';

bool get supported => false;
UpdatePlatform createPlatform() => throw UnsupportedError('Windows updates');
