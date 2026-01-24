import 'receipt_service.dart';

class MedicalRecordService {
  /// Returns the number of stored "medical records" for a given user.
  ///
  /// Under the hood this counts receipts in the standalone receipt-backend
  /// (reciptbackend-production.up.railway.app/api/receipts) keyed by userId.
  Future<int> fetchReportsCount(String userId) async {
    if (userId.isEmpty) return 0;
    try {
      final receipts = await ReceiptService.instance.listReceipts(userId);
      return receipts.length;
    } catch (_) {
      return 0;
    }
  }
}
