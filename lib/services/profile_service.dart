import 'package:dio/dio.dart';
import '../models/user_profile.dart';
import 'api_service.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService _instance = ProfileService._();
  static ProfileService get instance => _instance;

  final Dio _dio = ApiService.instance.dio;

  Future<UserProfile> fetchProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      print('Profile response: ${response.data}'); // Add debug logging
      
      // Check if we got the success response
      if (response.data['success'] != true) {
        throw Exception('Failed to fetch profile: ${response.data['message']}');
      }
      
      // Get the nested data object
      final profileData = response.data['data'] as Map<String, dynamic>;
      print('Profile data: $profileData'); // Add debug logging
      
      return UserProfile.fromJson(profileData);
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final response = await _dio.post('/user/profile', data: profile.toJson());
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }
}
