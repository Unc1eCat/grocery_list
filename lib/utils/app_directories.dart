import 'dart:io';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;

Directory appDocDirectory;
File groceryListsFile;
File groceryPrototypesFile;
File settingsFile;

Future<void> initDirectories() async
{
  appDocDirectory = await pp.getApplicationDocumentsDirectory();
  groceryListsFile = File(p.join(appDocDirectory.absolute.path, "grocery_lists.json"));
  groceryPrototypesFile = File(p.join(appDocDirectory.absolute.path, "grocery_prototypes.json"));
  settingsFile = File(p.join(appDocDirectory.absolute.path, "settings.json"));
}