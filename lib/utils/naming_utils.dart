int findNextUnusedNumberForName(String newName, List<String> existingNames) {
  var matchingStartsWith = newName + " ";
  var existingNumbers = existingNames.map((e) {
    return int.tryParse(e.replaceFirst(matchingStartsWith, "")) ?? -1;
  }).toList()..removeWhere((e) => e == -1);
  
  existingNumbers = existingNumbers.toSet().toList();
  existingNumbers.sort();

  if (existingNumbers.isEmpty || existingNumbers[0] != 1) return 1;

  for (var i = 1; i < existingNumbers.length; i++)
  {
    if (existingNumbers[i] != existingNumbers[i - 1])
    {
      return existingNumbers[i - 1] + 1;
    }
  }

  return 1;
}
