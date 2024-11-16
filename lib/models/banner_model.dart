// lib/models/banner_model.dart

class BannerItem {
  final String imageUrl;
  final String? title; // Opcional: título do banner
  final String? link; // Opcional: link para onde o banner direciona

  BannerItem({
    required this.imageUrl,
    this.title,
    this.link,
  });

  // Método para criar uma instância de BannerItem a partir de um mapa
  factory BannerItem.fromMap(Map<String, dynamic> data) {
    return BannerItem(
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'],
      link: data['link'],
    );
  }

  // Método para converter uma instância de BannerItem em um mapa (útil para escrita no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'link': link,
    };
  }
}

class AppBanners {
  final List<BannerItem> topBanners;
  final List<BannerItem> bottomBanners;

  AppBanners({
    required this.topBanners,
    required this.bottomBanners,
  });

  // Método para criar uma instância de AppBanners a partir de um documento do Firestore
  factory AppBanners.fromDocument(Map<String, dynamic> data) {
    var top = data['topBanners'] as List<dynamic>? ?? [];
    var bottom = data['bottomBanners'] as List<dynamic>? ?? [];

    List<BannerItem> topBanners = top
        .map((item) => BannerItem.fromMap(item as Map<String, dynamic>))
        .toList();
    List<BannerItem> bottomBanners = bottom
        .map((item) => BannerItem.fromMap(item as Map<String, dynamic>))
        .toList();

    return AppBanners(
      topBanners: topBanners,
      bottomBanners: bottomBanners,
    );
  }

  // Método para converter uma instância de AppBanners em um mapa
  Map<String, dynamic> toMap() {
    return {
      'topBanners': topBanners.map((banner) => banner.toMap()).toList(),
      'bottomBanners': bottomBanners.map((banner) => banner.toMap()).toList(),
    };
  }
}
