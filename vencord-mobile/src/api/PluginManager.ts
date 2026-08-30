import MessageLoggerPlugin from '../plugins/MessageLogger';

export interface Plugin {
  name: string;
  version: string;
  description: string;
  author: string;
  initialize: () => Promise<void> | void;
}

export class PluginManager {
  private plugins: Map<string, Plugin> = new Map();
  private loadedPlugins: Map<string, any> = new Map();

  async loadBuiltinPlugins() {
    // MessageLogger plugin
    const messageLogger = new MessageLoggerPlugin();
    await messageLogger.initialize();

    this.plugins.set('MessageLogger', {
      name: 'MessageLogger',
      version: '1.0.0',
      description: 'Logs all messages from Discord channels',
      author: 'Vencord Mobile',
      initialize: async () => {
        await messageLogger.initialize();
        this.loadedPlugins.set('MessageLogger', messageLogger);
      }
    });
  }

  async loadPlugin(pluginName: string) {
    const plugin = this.plugins.get(pluginName);
    if (!plugin) {
      throw new Error(`Plugin ${pluginName} not found`);
    }

    if (this.loadedPlugins.has(pluginName)) {
      console.log(`[PluginManager] ${pluginName} already loaded`);
      return;
    }

    await plugin.initialize();
    console.log(`[PluginManager] Loaded plugin: ${pluginName}`);
  }

  async unloadPlugin(pluginName: string) {
    this.loadedPlugins.delete(pluginName);
    console.log(`[PluginManager] Unloaded plugin: ${pluginName}`);
  }

  getPlugin(pluginName: string) {
    return this.loadedPlugins.get(pluginName);
  }

  getAllPlugins() {
    return Array.from(this.plugins.values());
  }

  getLoadedPlugins() {
    return Array.from(this.loadedPlugins.entries());
  }
}

export const pluginManager = new PluginManager();
