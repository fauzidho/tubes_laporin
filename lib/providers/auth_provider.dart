import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _status = AuthStatus.loading;
    notifyListeners();
    
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        await _fetchUserDetails(user.uid);
      }
    });
  }

  Future<void> _fetchUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
        await _auth.signOut();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat profil: $e';
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // authStateChanges will trigger and update status
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login gagal, periksa kredensial Anda.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String nim,
    required String prodi,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        final newUser = UserModel(
          id: user.uid,
          name: name,
          nim: nim,
          prodi: prodi,
          email: email,
          isAdmin: false,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Gagal mendaftar.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Membuat akun admin default jika gagal login menggunakan kredensial admin
  /// Membantu user yang belum punya akun admin
  Future<void> seedAdmin() async {
    try {
      final email = 'admin@laporan.telkom.ac.id';
      final password = 'admin123';
      
      try {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          // Register admin karena belum ada
          final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
          if (cred.user != null) {
             final adminUser = UserModel(
                id: cred.user!.uid,
                name: 'Admin LaporIn',
                nim: '000000000',
                prodi: 'Administrator',
                email: email,
                isAdmin: true,
                createdAt: DateTime.now(),
              );
              await _firestore.collection('users').doc(cred.user!.uid).set(adminUser.toMap());
          }
        }
      }
    } catch (e) {
      debugPrint('Error seeding admin: $e');
    }
  }

  void logout() async {
    await _auth.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
