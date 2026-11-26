class PaywallCarouselModel {
  final String imagePath;
  final String title;
  final bool isVideo;

  const PaywallCarouselModel({
    required this.imagePath,
    required this.title,
    this.isVideo = false,
  });
}

class PaywallPlanModel {
  final String id;
  final String title;
  final String price;
  final String period;
  final String credits;
  final String? discountBadge;

  const PaywallPlanModel({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    required this.credits,
    this.discountBadge,
  });
}
