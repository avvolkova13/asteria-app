import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

part 'hive_box_names.dart';

class HiveService {
  static late Box<Map> _appSettingsBox;
  static late Box<Map> _contentBox;
  static late Box<Map> _attributionBox;
  static Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    _appSettingsBox = await Hive.openBox<Map>(HiveBoxNames.appSettings);
    _contentBox = await Hive.openBox<Map>(HiveBoxNames.content);
    _attributionBox = await Hive.openBox<Map>(HiveBoxNames.attribution);
  }

  static Box<Map> get appSettingsBox => _appSettingsBox;
  static Box<Map> get contentBox => _contentBox;
  static Box<Map> get attributionBox => _attributionBox;
}
