import 'package:app_analytics/app_analytics.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loan_tracking_view_model.g.dart';

class LoanCandidateItem {
  const LoanCandidateItem({required this.item, required this.collectionName});

  final Item item;
  final String collectionName;

  String get displayLabel => '${item.title} • $collectionName';
}

@riverpod
Stream<List<LoanRecord>> activeLoans(Ref ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return repository.watchActiveLoans();
}

@riverpod
Stream<List<LoanRecord>> loanHistory(Ref ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return repository.watchLoanHistory();
}

@riverpod
Stream<LoanRecord?> activeLoanForItem(Ref ref, String itemId) {
  final repository = ref.watch(loanRepositoryProvider);
  return repository.watchActiveLoanForItem(itemId);
}

@riverpod
Future<List<LoanCandidateItem>> loanCandidateItems(Ref ref) async {
  final collectionRepository = ref.read(collectionRepositoryProvider);
  final itemRepository = ref.read(itemRepositoryProvider);

  final collectionsResult = await collectionRepository.getCollections();
  final collections = collectionsResult.fold(
    (exception) => throw exception,
    (r) => r,
  );

  final candidates = <LoanCandidateItem>[];
  for (final collection in collections) {
    final itemsResult = await itemRepository.getItems(
      collectionId: collection.id,
    );
    final items = itemsResult.fold((exception) => throw exception, (r) => r);
    for (final item in items) {
      candidates.add(
        LoanCandidateItem(item: item, collectionName: collection.name),
      );
    }
  }

  candidates.sort(
    (a, b) => a.item.title.toLowerCase().compareTo(b.item.title.toLowerCase()),
  );

  return candidates;
}

@riverpod
Future<void> createLoan(
  Ref ref, {
  required String itemId,
  required String borrowerName,
  String? borrowerContact,
  String? notes,
  DateTime? dueAt,
}) async {
  final repository = ref.read(loanRepositoryProvider);
  final result = await repository.createLoan(
    itemId: itemId,
    borrowerName: borrowerName,
    borrowerContact: borrowerContact,
    notes: notes,
    dueAt: dueAt,
  );

  result.fold((exception) => throw exception, (loan) async {
    await AnalyticsService.instance.track(
      AnalyticsEvent.custom(
        name: 'loan_created',
        properties: {
          'loan_id': loan.id,
          'item_id': loan.itemId,
          'has_due_date': loan.dueAt != null,
        },
      ),
    );
  });
}

@riverpod
Future<void> markLoanReturned(Ref ref, {required String loanId}) async {
  final repository = ref.read(loanRepositoryProvider);
  final result = await repository.markLoanReturned(loanId: loanId);

  result.fold((exception) => throw exception, (loan) async {
    await AnalyticsService.instance.track(
      AnalyticsEvent.custom(
        name: 'loan_returned',
        properties: {'loan_id': loan.id, 'item_id': loan.itemId},
      ),
    );
  });
}

@riverpod
Future<void> deleteLoan(Ref ref, {required String loanId}) async {
  final repository = ref.read(loanRepositoryProvider);
  final result = await repository.deleteLoan(loanId);
  result.fold((exception) => throw exception, (_) => null);
}
