import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .where('activo', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String categoriaId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('activo', isEqualTo: true)
        .where('categoriaId', isEqualTo: categoriaId)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
  }

  Future<ProductModel?> getProduct(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> createProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).set(product.toMap());
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _firestore.collection('products').doc(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  Stream<List<ProductModel>> streamAllProducts() {
    return _firestore.collection('products').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList(),
    );
  }
}
