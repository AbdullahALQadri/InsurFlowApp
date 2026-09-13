/// Local inspection-step progress for a claim.
///
/// TODO(api): Backend GET /claims and GET /claims/{id} do not yet return
/// field-inspection step progress. Persist completed steps locally until
/// a reliable progress contract exists. Do not invent progress fields.
class InspectionProgressStore {
  InspectionProgressStore();

  static final InspectionProgressStore instance = InspectionProgressStore();

  static const stepCount = 8;

  final Map<String, int> _currentIndex = {};

  void reset() => _currentIndex.clear();

  void start(String claimId) {
    _currentIndex.putIfAbsent(claimId, () => 0);
  }

  void completeThrough(String claimId, int nextIndex) {
    final current = _currentIndex[claimId] ?? 0;
    if (nextIndex > current) {
      _currentIndex[claimId] = nextIndex.clamp(0, stepCount);
    }
  }

  void completeAll(String claimId) {
    _currentIndex[claimId] = stepCount;
  }

  int? indexFor(String claimId) => _currentIndex[claimId];
}
