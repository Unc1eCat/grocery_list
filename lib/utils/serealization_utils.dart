import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:trotter/trotter.dart' as tr;

abstract class ToJson {
  Object toJson();

  static Object toEncodable(Object value) {
    if (value is Iterable) {
      return value.toList();
    } else if (value is ToJson) {
      return value.toJson();
    } else if (value is num || value is bool || value is String || value == null || value is Map<String, dynamic>) {
      return value;
    } else {
      throw UnsupportedError(
          'The object "$value" of type "${value.runtimeType}" can\'t be converted to List-Map Json representation. Only primitives, "ToJson" implementors, "String"-keyed maps and iterables can be converted to List-Map Json representation.');
    }
  }
}

/// This class is base class for classes, used to convert models of one version to a higher one
abstract class ModelUpgrader with EquatableMixin {
  Set<int> get inputVersions;
  int get outputVersion;

  /// Upgrades text model with any version, being in the [[inputVersions]] to the [[outputVersion]]
  String upgrade(String inputModelText);

  @override
  List<Object> get props => [inputVersions, outputVersion];
}

var currentModelsVersion = 0;

var _jsonEncoder = JsonEncoder.withIndent('    ', ToJson.toEncodable);

var modelUpgraders = Map<Object, Set<ModelUpgrader>>();

/// Returns a list of model upgraders from the [[modelUpgraders]]. Every input versions set of upgrader n contains output version of upgrader n - 1, this does
/// not apply to the first upgrader. Input versions set of first upgrader contains [[fromVersion]]; output version of the last upgrader equals to [[toVersion]].
///
/// If such list can't be formed from the model upgraders in the set [[modelUpgraders]] then null is returned.
// TODO: Make it not O(n!) for god
List<ModelUpgrader> getShortestModelUpgradersChain(int fromVersion, int toVersion, Set<ModelUpgrader> modelUpgraders) {
  var perms = tr.Permutations(modelUpgraders.length, modelUpgraders.toList());
  var matchingChains = <List<ModelUpgrader>>{};

  perms().forEach((e) {
    if (!e.first.inputVersions.contains(fromVersion)) return;

    var possibleChain = [e.first];

    for (var i = 1; i < e.length && possibleChain.last.outputVersion < toVersion; i++) {
      if (e[i].inputVersions.contains(e[i - 1].outputVersion) && e[i].outputVersion <= toVersion) {
        possibleChain.add(e[i]);
      } else {
        return;
      }
    }

    if (possibleChain.last.outputVersion == toVersion)
    {
      matchingChains.add(possibleChain);
    }
  });

  return matchingChains.fold(<ModelUpgrader>[], (s, e) => e.length < s.length ? e : s);
}

/// Returns ModelUpgrader from the given set with its input versions containing the [[fromVersion]] and its
/// output version, being the closest to [[toVersion]] among all model upgraders output versions in the set and being lower than the [[toVersion]].
///
/// If there is no model upgrader that's input versions contain the [[fromVersion]] and that's output version is lower than the [[toVersion]], it returns null
ModelUpgrader getClosestModelUpgrader(int fromVersion, int toVersion, Set<ModelUpgrader> modelUpgraders) {
  var ret = modelUpgraders.firstWhere((e) => e.inputVersions.contains(fromVersion) && e.outputVersion <= toVersion, orElse: () => null);

  if (ret == null) return null;

  modelUpgraders.forEach((e) => ret = e.inputVersions.contains(fromVersion) && e.outputVersion > ret.outputVersion && e.outputVersion <= toVersion ? e : ret);

  return ret;
}

String jsonEncodeModel(Object jsonModel) => _jsonEncoder.convert(
      {
        "version": currentModelsVersion,
        "model": jsonModel,
      },
    );
