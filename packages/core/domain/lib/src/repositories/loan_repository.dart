import 'package:domain/src/entities/loan_record.dart';
import 'package:domain/src/failures/app_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class LoanRepository {
  Stream<List<LoanRecord>> watchActiveLoans();
  Stream<List<LoanRecord>> watchLoanHistory({int limit = 200});
  Stream<LoanRecord?> watchActiveLoanForItem(String itemId);

  Future<Either<AppException, LoanRecord>> createLoan({
    required String itemId,
    required String borrowerName,
    String? borrowerContact,
    String? notes,
    DateTime? dueAt,
  });

  Future<Either<AppException, LoanRecord>> markLoanReturned({
    required String loanId,
    DateTime? returnedAt,
  });

  Future<Either<AppException, void>> deleteLoan(String loanId);
}
