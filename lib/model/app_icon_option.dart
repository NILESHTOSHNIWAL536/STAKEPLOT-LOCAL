class AppIconOption {
  final String label;
  final String assetPath;
  final String alias;

  const AppIconOption({
    required this.label,
    required this.assetPath,
    required this.alias,
  });
}

class AppIconOptions {
  static const String defaultAlias = "IconDefault";

  static const List<AppIconOption> all = [
    AppIconOption(
      label: "Default",
      assetPath: "assets/app_icon.png",
      alias: defaultAlias,
    ),
    AppIconOption(
      label: "Icon 1",
      assetPath: "assets/app_icons/icon1.png",
      alias: "Icon1",
    ),
    AppIconOption(
      label: "Icon 2",
      assetPath: "assets/app_icons/icon2.png",
      alias: "Icon2",
    ),
    AppIconOption(
      label: "Icon 3",
      assetPath: "assets/app_icons/icon3.png",
      alias: "Icon3",
    ),
  ];

  static bool isAllowedAlias(String alias) {
    return all.any((icon) => icon.alias == alias);
  }
}
