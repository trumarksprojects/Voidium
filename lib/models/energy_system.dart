// Simple Energy System for Mini Games
class EnergySystem {
  final int maxEnergy;
  final int currentEnergy;
  final DateTime lastRegenTime;
  final int regenRateMinutes;

  EnergySystem({
    this.maxEnergy = 100,
    this.currentEnergy = 100,
    required this.lastRegenTime,
    this.regenRateMinutes = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'maxEnergy': maxEnergy,
      'currentEnergy': currentEnergy,
      'lastRegenTime': lastRegenTime.toIso8601String(),
      'regenRateMinutes': regenRateMinutes,
    };
  }

  factory EnergySystem.fromJson(Map<String, dynamic> json) {
    return EnergySystem(
      maxEnergy: json['maxEnergy'] ?? 100,
      currentEnergy: json['currentEnergy'] ?? 100,
      lastRegenTime: DateTime.parse(json['lastRegenTime']),
      regenRateMinutes: json['regenRateMinutes'] ?? 5,
    );
  }
}
