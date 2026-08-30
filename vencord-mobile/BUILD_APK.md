# Vencord Mobile - Building APK

## Prerequisites
- Node.js 18+
- npm or yarn
- Android SDK (for local builds) or use Expo

## Quick Start

### Option 1: Build with Expo (Recommended for first time)

```bash
npm install
npm start

# Then press 'a' to build for Android
```

### Option 2: Build Local APK

```bash
npm install

# Install expo CLI globally
npm install -g eas-cli

# Login to Expo
eas login

# Build APK
eas build -p android --local
```

### Option 3: Build with Bare React Native

```bash
npm install

# Install Android SDK tools
# Set ANDROID_SDK_ROOT env variable

# Build APK
cd android
./gradlew assembleRelease
```

## Install on Device

```bash
adb install -r app-release.apk
```

## Features

### MessageLogger Plugin

- Logs all Discord messages
- Tracks message edits and deletes
- Persistent storage (local)
- Export logs as JSON or CSV
- Filter by channel or user

## Configuration

### Plugin Settings

Edit `src/plugins/MessageLogger.ts`:

```typescript
const config = {
  enabled: true,           // Enable/disable logging
  logEdits: true,          // Log edited messages
  logDeletes: true,        // Log deleted messages
  storageKey: 'logs'       // Storage identifier
};
```

## Troubleshooting

### Token Security
- Never hardcode tokens
- Use environment variables
- Clear token after logout
- Consider using refresh tokens

### Storage Issues
If messages aren't persisting:
1. Check device storage permissions
2. Clear app data: `adb shell pm clear com.vencordmobile`
3. Check AsyncStorage configuration

## Development

### Add New Plugins

1. Create `src/plugins/YourPlugin.ts`
2. Implement the Plugin interface
3. Register in `PluginManager.ts`:

```typescript
async loadBuiltinPlugins() {
  const plugin = new YourPlugin();
  this.plugins.set('YourPlugin', {
    name: 'YourPlugin',
    initialize: async () => { ... }
  });
}
```

### Debug Messages

Enable console logging:

```bash
npm run start -- --clear
```

Then use React Native Debugger to see logs.

## Size & Performance

- APK Size: ~50-80MB
- Storage: Logs stored locally, no server sync
- Performance: ~1000 messages per MB
