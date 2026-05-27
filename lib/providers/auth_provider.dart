import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cred = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));
      await _loadUser(cred.user!.uid);
    } on TimeoutException {
      _error = 'Error de conexión: el servidor no responde';
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Error al iniciar sesión';
    } catch (e) {
      _error = 'Error de conexión: verifica Firebase';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cred = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));
      final newUser = UserModel(
        id: cred.user!.uid,
        nombre: name,
        email: email,
      );
      await _firestore
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toMap())
          .timeout(const Duration(seconds: 15));
      _user = newUser;
    } on TimeoutException {
      _error = 'Error de conexión: el servidor no responde';
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Error al registrarse';
    } catch (e) {
      _error = 'Error de conexión: verifica Firebase';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUser(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(const Duration(seconds: 15));
    if (doc.exists) {
      _user = UserModel.fromMap(doc.data()!);
    }
  }

  Future<void> checkAuth() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _loadUser(currentUser.uid);
        notifyListeners();
      }
    } catch (_) {
      // Firebase no configurado
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut().timeout(const Duration(seconds: 15));
    } catch (_) {
      // Ignorar error al cerrar sesión
    }
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? nombre, String? telefono, String? fotoUrl}) async {
    if (_user == null) return;

    final data = <String, dynamic>{};
    if (nombre != null) data['nombre'] = nombre;
    if (telefono != null) data['telefono'] = telefono;
    if (fotoUrl != null) data['fotoUrl'] = fotoUrl;

    try {
      await _firestore.collection('users').doc(_user!.id).update(data);
      _user = UserModel(
        id: _user!.id,
        nombre: nombre ?? _user!.nombre,
        email: _user!.email,
        telefono: telefono ?? _user!.telefono,
        fotoUrl: fotoUrl ?? _user!.fotoUrl,
        isAdmin: _user!.isAdmin,
        fechaCreacion: _user!.fechaCreacion,
      );
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
