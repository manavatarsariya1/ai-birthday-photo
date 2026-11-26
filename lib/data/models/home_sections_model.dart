class HomeSectionsResponse {
  final bool success;
  final String message;
  final List<HomeSectionModel> data;

  const HomeSectionsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HomeSectionsResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    return HomeSectionsResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(HomeSectionModel.fromJson)
              .toList()
          : [],
    );
  }
}

class HomeSectionModel {
  final String id;
  final String title;
  final String categoryId;
  final List<HomeSectionItemModel> items;

  const HomeSectionModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.items,
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return HomeSectionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(HomeSectionItemModel.fromJson)
              .toList()
          : [],
    );
  }
}

class HomeSectionItemModel {
  final String id;
  final String? categoryId;
  final String name;
  final String? imgSquare;
  final String? imgRectangle;
  final String? videoSquare;
  final String? videoRectangle;
  final bool isPremium;
  final bool hasSubcategory;

  const HomeSectionItemModel({
    required this.id,
    this.categoryId,
    required this.name,
    this.imgSquare,
    this.imgRectangle,
    this.videoSquare,
    this.videoRectangle,
    this.isPremium = false,
    this.hasSubcategory = false,
  });

  factory HomeSectionItemModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionItemModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      name: json['name']?.toString() ?? '',
      imgSquare: json['imgSquare']?.toString(),
      imgRectangle: json['imgRectangle']?.toString(),
      videoSquare: json['videoSquare']?.toString(),
      videoRectangle: json['videoRectangle']?.toString(),
      isPremium: json['isPremium'] == true,
      hasSubcategory: json['hasSubcategory'] == true,
    );
  }
}
