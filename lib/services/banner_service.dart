// lib/services/banner_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';

class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para buscar os banners do documento único
  Future<AppBanners?> fetchAppBanners({String documentId = 'default'}) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('AppBanners').doc(documentId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return AppBanners.fromDocument(data);
      } else {
        print('Documento AppBanners/$documentId não encontrado.');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar AppBanners: $e');
      return null;
    }
  }
}
