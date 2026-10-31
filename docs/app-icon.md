# Іконка застосунку

Спільний оригінал: `archive_flutter/assets/branding/app_icon.png`.
Конфігурація: `archive_flutter/flutter_launcher_icons.yaml`.

Щоб змінити іконку, замініть оригінал і виконайте в `archive_flutter`:

```sh
flutter pub get
dart run flutter_launcher_icons
```

Збережіть у Git оригінал, конфігурацію та створені ресурси:

- Windows: `windows/runner/resources/app_icon.ico` (використовується виконуваним файлом і установщиком Inno Setup).
- macOS: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`.

Звичайна збірка використовує готові ресурси з репозиторію; запускати генератор під час кожної збірки не потрібно. Щоб побачити зміну в Dock або у Windows, повністю перезберіть і перезапустіть застосунок. Hot reload і hot restart не оновлюють нативні іконки. Встановлені Windows-клієнти отримають іконку з наступним випуском установщика.
