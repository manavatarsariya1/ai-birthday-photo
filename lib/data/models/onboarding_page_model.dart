class OnboardingPageModel {
  final String imagePath;
  final String titlePrefix;
  final String titleHighlight;
  final String titleSuffix;
  final String description;

  const OnboardingPageModel({
    required this.imagePath,
    required this.titlePrefix,
    required this.titleHighlight,
    this.titleSuffix = '',
    required this.description,
  });
}
