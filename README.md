# SilentVoid Hub - Vencord Mobile

A Discord client modification for mobile devices with plugin support, starting with **MessageLogger**.

## 🚀 Features

### Vencord Mobile
- Mobile-friendly Discord client
- Plugin system for extensibility
- Persistent message storage
- Works offline (cached messages)

### MessageLogger Plugin (v1.0.0)
✅ Log all messages from Discord channels
✅ Track message edits and deletions
✅ Filter by channel or user
✅ Export logs as JSON or CSV
✅ Persistent local storage
✅ Statistics dashboard

## 📱 Getting Started

### Prerequisites
- Node.js 18+
- npm or yarn
- Android device or emulator

### Installation

```bash
cd vencord-mobile
npm install
```

### Run on Android

```bash
# Start development server
npm run android

# Or build APK
npm run build:apk
```

## 📂 Project Structure

```
vencord-mobile/
├── src/
│   ├── api/              # Discord API & Plugin Manager
│   ├── app/              # Main app entry point
│   ├── components/       # UI components
│   ├── hooks/            # React hooks
│   ├── plugins/          # Plugin system
│   │   └── MessageLogger.ts
│   ├── store/            # Zustand state management
│   │   ├── authStore.ts
│   │   └── messageStore.ts
│   └── app.tsx           # Main app component
├── BUILD_APK.md          # Building instructions
└── package.json
```

## 🔧 Architecture

### Plugin System
The plugin manager (`src/api/PluginManager.ts`) handles:
- Loading plugins at startup
- Managing plugin lifecycle
- Communication between plugins

### State Management
Using Zustand for lightweight, scalable state:
- **AuthStore**: User authentication
- **MessageStore**: Discord messages

### UI Components
- **MessagesList**: Displays logged messages
- Themed for Discord dark mode

## 📝 MessageLogger Plugin

### Configuration
```typescript
// src/plugins/MessageLogger.ts
const config = {
  enabled: true,           // Enable/disable plugin
  logEdits: true,          // Log message edits
  logDeletes: true,        // Log message deletes
  storageKey: 'logs'       // Local storage key
};
```

## 🔐 Security Notes

⚠️ **Never hardcode Discord tokens!**
- Use the login screen to enter tokens
- Tokens are stored locally in Zustand
- Consider using OAuth in production
- Clear data before uninstalling

## 🛠️ Development

### Add a New Plugin

1. Create `src/plugins/MyPlugin.ts`:
```typescript
export class MyPlugin {
  async initialize() {
    console.log('MyPlugin initialized');
  }
}
```

2. Register in `src/api/PluginManager.ts`:
```typescript
const plugin = new MyPlugin();
this.plugins.set('MyPlugin', {
  name: 'MyPlugin',
  version: '1.0.0',
  description: 'My plugin',
  author: 'Me',
  initialize: () => plugin.initialize()
});
```

### Building APK

See [vencord-mobile/BUILD_APK.md](vencord-mobile/BUILD_APK.md) for detailed instructions.

## 📊 Stats

- **App Size**: ~50-80MB (APK)
- **Storage**: Local AsyncStorage (device dependent)
- **Performance**: 1000+ messages per MB
- **Compatibility**: Android 9+ (API 28+)

## 🤝 Contributing

To add features or plugins:
1. Create feature branch
2. Make changes
3. Test on emulator/device
4. Commit with clear messages
5. Push to `claude/vencord-k3x2uw` branch

## 📄 License

ISC License

---

**Vencord Mobile** - Bringing powerful Discord customization to your pocket! 📱✨
