class AuthService {
  /// Simulates sending OTP email.
  Future<void> sendOtp(String email) async {
    await Future.delayed(const Duration(seconds: 2));
    // In a real implementation, integrate with backend.
  }

  /// Simulates verifying OTP; returns true if OTP is six digits.
  Future<bool> verifyOtp(String email, String otp) async {
    await Future.delayed(const Duration(seconds: 2));
    return otp.length == 6;
  }
}
