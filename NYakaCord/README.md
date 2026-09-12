# NYakaCord

A modded Discord client for Android with plugin and theme support.

## Features

- **Plugin System** - Load custom plugins to extend Discord functionality
- **Theme Engine** - Apply custom themes and CSS to Discord
- **Patch System** - Hook into Discord's React Native code
- **Settings UI** - Built-in settings panel for managing mods

## Architecture

NYakaCord works by patching the Discord APK to inject a custom loader that hooks into Discord's React Native bridge. This allows plugins to intercept and modify Discord's behavior.

```
NYakaCord/
├── app/                    # Main NYakaCord module
│   └── src/main/java/com/nyakacord/
│       ├── core/           # Core injection and hooking
│       ├── plugins/        # Plugin loader and API
│       ├── themes/         # Theme engine
│       ├── patches/        # Discord function patches
│       ├── ui/             # Settings and UI components
│       └── utils/          # Utility classes
├── patcher/                # APK patcher tool
└── plugins/                # Built-in plugins
```

## Building

### Requirements
- Android Studio / JDK 17+
- Android SDK (API 24+)
- Discord APK (target version)

### Steps
1. Clone the repository
2. Open in Android Studio
3. Build the patcher module
4. Run the patcher on a Discord APK
5. Install the patched APK

## Disclaimer

This project is for educational purposes. Using modified Discord clients may violate Discord's Terms of Service. Use at your own risk.

## License

MIT License - See [LICENSE](LICENSE)
