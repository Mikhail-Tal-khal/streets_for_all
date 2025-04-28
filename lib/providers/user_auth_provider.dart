// lib/providers/user_auth_provider.dart
// ignore_for_file: avoid_print

import 'package:diabetes_test/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserAuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get userId => _auth.currentUser?.uid;

  // Constructor to listen for auth changes
  UserAuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;

        // TODO: TAKE USER TO LOGIN SCREEN
      } else {
        await _fetchUserData(firebaseUser.uid);
      }
      notifyListeners();
    });
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      
      if (docSnapshot.exists) {
        _currentUser = UserModel.fromJson({
          ...docSnapshot.data()!,
          'id': userId,
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _clearError();
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during sign in');
      rethrow;
    } catch (e) {
      _setError('An unexpected error occurred');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email, 
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toJson());

      _currentUser = user;
      _clearError();
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during sign up');
      rethrow;
    } catch (e) {
      _setError('An unexpected error occurred');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _setLoading(false);
        return; // User cancelled the sign-in flow
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user exists in Firestore
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      
      if (!docSnapshot.exists) {
        // Create new user document
        final newUser = UserModel(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toJson());
      }

      _clearError();
    } catch (e) {
      _setError('Failed to sign in with Google');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    _setLoading(true);
    try {
      // Implement Apple Sign In
      // This requires additional configuration
      _setError('Apple Sign In not implemented yet');
      throw UnimplementedError('Apple Sign In not implemented');
    } catch (e) {
      _setError('Failed to sign in with Apple');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
      _clearError();
    } catch (e) {
      _setError('Failed to sign out');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _clearError();
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred');
      rethrow;
    } catch (e) {
      _setError('An unexpected error occurred');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}