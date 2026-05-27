import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> createCategory(CategoryModel category) async {
    await _firestore.collection('categories').doc(category.id).set(category.toMap());
  }

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _firestore.collection('categories').doc(id).update(data);
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }

  Stream<List<CategoryModel>> streamAllCategories() {
    return _firestore.collection('categories').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList(),
    );
  }
}
