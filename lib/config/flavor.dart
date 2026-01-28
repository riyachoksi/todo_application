enum Flavor {
  dev,
  qa,
  staging,
  prod;

  static Flavor fromString(String value) {
    return Flavor.values.firstWhere(
      (flavor) => flavor.name == value.toLowerCase(),
      orElse: () => Flavor.dev,
    );
  }

  bool get isDevelopment => this == Flavor.dev;
  bool get isQA => this == Flavor.qa;
  bool get isStaging => this == Flavor.staging;
  bool get isProduction => this == Flavor.prod;
}
