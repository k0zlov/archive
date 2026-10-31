# Іконка застосунку

Оригінали:

- macOS: `archive_flutter/assets/branding/app_icon.png`.
- Windows: `archive_flutter/assets/branding/app_icon_windows.png` — збільшений знак, мінімальні прозорі поля й тонка нейтральна обводка.

Конфігурація: `archive_flutter/flutter_launcher_icons.yaml`.

Щоб змінити іконку, замініть оригінал і виконайте в `archive_flutter`:

```sh
flutter pub get
dart run tool/generate_app_icons.dart
```

Збережіть у Git оригінал, конфігурацію та створені ресурси:

- Windows: `windows/runner/resources/app_icon.ico` із кадрами 16, 20, 24, 32, 40, 48, 64, 96, 128 і 256 px (використовується виконуваним файлом і установщиком Inno Setup).
- macOS: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`.

Сценарій `tool/build_windows.ps1` автоматично запускає цей генератор перед збіркою. Прямий запуск `flutter_launcher_icons` створює лише один кадр Windows; використовуйте обгортку вище, щоб зберегти всі розміри. macOS використовує готові ресурси з репозиторію. Щоб побачити зміну в Dock або у Windows, повністю перезберіть і перезапустіть застосунок. Hot reload і hot restart не оновлюють нативні іконки. Встановлені Windows-клієнти отримають іконку з наступним випуском установщика.
