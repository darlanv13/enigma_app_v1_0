// lib/widgets/banner_carousel.dart
import 'package:enigma_app_v1_0/models/banner_model.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;
  final double height;

  const BannerCarousel({
    Key? key,
    required this.banners,
    this.height = 150.0,
  }) : super(key: key);

  @override
  _BannerCarouselState createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _current = 0;

  // Método para abrir URLs
  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Não foi possível abrir o link.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.height,
            autoPlay: true,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: widget.banners.map((banner) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    // Ação ao clicar no banner (se houver link)
                    if (banner.link != null && banner.link!.isNotEmpty) {
                      _launchURL(banner.link!);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: banner.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey,
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50.0,
                            ),
                          ),
                        ),
                        // Opcional: Adicionar um gradiente ou título sobre o banner
                        if (banner.title != null && banner.title!.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  banner.title!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.banners.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => {},
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
