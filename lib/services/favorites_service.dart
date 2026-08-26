import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'eh_favorite_ids';

  Future<Set<String>> getIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  Future<void> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_key) ?? []).toSet();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await prefs.setStringList(_key, ids.toList());
  }

  Future<bool> isFavorite(String id) async {
    final ids = await getIds();
    return ids.contains(id);
  }
}
