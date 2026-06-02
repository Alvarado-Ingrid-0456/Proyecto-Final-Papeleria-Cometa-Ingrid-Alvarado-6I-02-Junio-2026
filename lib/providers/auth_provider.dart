import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:myapp/models/usuario.dart';

class AuthProvider with ChangeNotifier {
  firebase_auth.User? _user;
  Usuario? _usuarioDatos;

  firebase_auth.User? get user => _user;
  Usuario? get usuarioDatos => _usuarioDatos;

  AuthProvider() {
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      _user = firebaseUser;
      if (firebaseUser != null) {
        await _fetchUsuarioDatos(firebaseUser.uid);
      } else {
        _usuarioDatos = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUsuarioDatos(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      if (doc.exists) {
        _usuarioDatos = Usuario.fromFirestore(doc);
      } else {
        // Fallback: Si no existe el documento en Firestore, creamos uno básico para que no falle la UI
        final email = _user?.email ?? '';
        final nuevoUsuario = Usuario(
          id: uid,
          nombre: _user?.displayName ?? email.split('@')[0],
          email: email,
          telefono: '',
          direccion: '',
          rol: 'cliente',
          fechaRegistro: DateTime.now(),
          activo: true,
        );
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .set(nuevoUsuario.toMap())
            .timeout(const Duration(seconds: 10));
        _usuarioDatos = nuevoUsuario;
      }
    } catch (e) {
      debugPrint("Error fetching user profile from Firestore: $e");
      // Fallback local en memoria en caso de error de red
      final email = _user?.email ?? '';
      _usuarioDatos = Usuario(
        id: uid,
        nombre: _user?.displayName ?? email.split('@')[0],
        email: email,
        telefono: '',
        direccion: '',
        rol: 'cliente',
        fechaRegistro: DateTime.now(),
        activo: true,
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String telefono = '',
    String direccion = '',
    String imagenUrl = '',
  }) async {
    try {
      final credential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;

      if (_user != null) {
        // Crear perfil inicial del usuario en Firestore
        final nuevoUsuario = Usuario(
          id: _user!.uid,
          nombre: email.split('@')[0],
          email: email,
          telefono: telefono,
          direccion: direccion,
          rol: 'cliente',
          fechaRegistro: DateTime.now(),
          activo: true,
          imagenUrl: imagenUrl,
        );
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(_user!.uid)
            .set(nuevoUsuario.toMap())
            .timeout(const Duration(seconds: 10));
        _usuarioDatos = nuevoUsuario;
      }
      notifyListeners();
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Auth registration error: ${e.code} – ${e.message}');
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final credential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      if (_user != null) {
        await _fetchUsuarioDatos(_user!.uid);
      }
      notifyListeners();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    _user = null;
    _usuarioDatos = null;
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    try {
      await firebase_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to $email');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email.');
    }
  }

  Future<void> updateUserProfile({
    required String nombre,
    required String telefono,
    required String direccion,
    required String imagenUrl,
  }) async {
    if (_user == null) throw Exception("No user is currently authenticated.");
    try {
      final uid = _user!.uid;
      final rolActual = _usuarioDatos?.rol ?? 'cliente';
      final fechaRegistroActual = _usuarioDatos?.fechaRegistro ?? DateTime.now();

      final usuarioActualizado = Usuario(
        id: uid,
        nombre: nombre,
        email: _user!.email ?? '',
        telefono: telefono,
        direccion: direccion,
        rol: rolActual,
        fechaRegistro: fechaRegistroActual,
        activo: true,
        imagenUrl: imagenUrl,
      );

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set(usuarioActualizado.toMap());
      _usuarioDatos = usuarioActualizado;
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to update user profile in Firestore: ${e.toString()}");
    }
  }

  Future<void> signInWithGoogle() async {
    // TODO: Implement actual Google Sign-In logic here using Firebase Auth and Google Sign-In plugin
    debugPrint("Google Sign-In not implemented yet.");
  }

  Future<void> signInWithFacebook() async {
    // TODO: Implement actual Facebook Sign-In logic here using Firebase Auth and Facebook Login plugin
    debugPrint("Facebook Sign-In not implemented yet.");
  }
}
