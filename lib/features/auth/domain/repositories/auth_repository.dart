import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> signInWithGoogle();
  Future<void> sendMagicLink(String email);
  Future<bool> checkAuthStatus();
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Supabase's signInWithOAuth launches browser for OAuth flow
      // and returns true if the browser was opened successfully
      final bool launched = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.rva.kasihustle://login-callback',
      );

      if (!launched) {
        throw Exception('Failed to launch Google Sign-In');
      }

      // Wait for the auth state change after redirect
      // The AppBloc will handle the session once user returns
      final completer = Completer<Map<String, dynamic>>();

      final subscription = _supabase.auth.onAuthStateChange.listen((data) {
        final user = data.session?.user;
        if (user != null && !completer.isCompleted) {
          final fullName = user.userMetadata?['full_name'] ?? '';
          final nameParts = fullName.split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
          final lastName = nameParts.length > 1
              ? nameParts.sublist(1).join(' ')
              : '';

          completer.complete({
            'userId': user.id,
            'email': user.email ?? '',
            'firstName': firstName,
            'lastName': lastName,
          });
        }
      });

      // Set a timeout of 5 minutes for the OAuth flow
      return await completer.future
          .timeout(
            const Duration(minutes: 5),
            onTimeout: () {
              subscription.cancel();
              throw Exception('Google Sign-In timed out');
            },
          )
          .then((value) {
            subscription.cancel();
            return value;
          });
    } on AuthException catch (e) {
      throw Exception('Google sign-in failed: ${e.message}');
    } catch (e) {
      throw Exception('Google sign-in error: $e');
    }
  }

  @override
  Future<void> sendMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'com.rva.kasihustle://login-callback',
      );
    } on AuthException catch (e) {
      throw Exception('Failed to send magic link: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<bool> checkAuthStatus() async {
    try {
      final session = _supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Sign out failed: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
