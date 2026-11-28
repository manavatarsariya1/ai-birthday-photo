class TemplatesApiResponse {
  final bool success;
  final String message;
  final List<TemplateCategoryModel> data;

  const TemplatesApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TemplatesApiResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    return TemplatesApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(TemplateCategoryModel.fromJson)
              .toList()
          : [],
    );
  }
}

class TemplateCategoryModel {
  final String id;
  final String name;
  final List<TemplateItemModel> templates;

  const TemplateCategoryModel({
    required this.id,
    required this.name,
    required this.templates,
  });

  factory TemplateCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawTemplates = json['templates'];
    return TemplateCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      templates: rawTemplates is List
          ? rawTemplates
              .whereType<Map<String, dynamic>>()
              .map(TemplateItemModel.fromJson)
              .toList()
          : [],
    );
  }
}

class TemplateItemModel {
  final String id;
  final String name;
  final String image;
  final int credits;
  final bool isPremium;
  final int imageCount;
  final List<String> imageGenders;
  final bool singleFace;

  const TemplateItemModel({
    required this.id,
    required this.name,
    required this.image,
    this.credits = 1,
    this.isPremium = false,
    this.imageCount = 1,
    this.imageGenders = const ['any'],
    this.singleFace = true,
  });

  factory TemplateItemModel.fromJson(Map<String, dynamic> json) {
    return TemplateItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: (json['video'] ?? json['image'])?.toString() ?? '',
      credits: (json['credits'] as num?)?.toInt() ?? 1,
      isPremium: json['isPremium'] == true,
      imageCount: (json['imageCount'] as num?)?.toInt() ?? 1,
      imageGenders: json['imageGenders'] is List
          ? (json['imageGenders'] as List)
              .map((e) => e.toString())
              .toList()
          : const ['any'],
      singleFace: json['singleFace'] != false,
    );
  }
}
