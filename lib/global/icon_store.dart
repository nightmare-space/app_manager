class IconStore {
  // 工厂模式

  factory IconStore() => _getInstance();
  IconStore._internal();

  static IconStore get instance => _getInstance();

  static IconStore _instance;

  static IconStore _getInstance() {
    _instance ??= IconStore._internal();
    return _instance;
  }

  List<int> cache(String id, List<int> bytes) {
    iconCacheMap[id] = bytes;
    return bytes;
  }

  List<int> loadCache(String id) {
    if (iconCacheMap.containsKey(id)) {
      return iconCacheMap[id];
    }
    return [];
  }

  Map<String, List<int>> iconCacheMap = {};
}
