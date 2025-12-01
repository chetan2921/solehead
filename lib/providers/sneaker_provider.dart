import 'package:flutter/material.dart';
import '../models/sneaker_model.dart';
import '../services/sneaker_service.dart';

class SneakerProvider with ChangeNotifier {
  static const int _pageSize = 10;
  static const int _maxPageAttemptsPerLoad = 25;
  List<SneakerModel> _sneakers = [];
  List<SneakerModel> _topSneakers = [];
  List<SneakerModel> _searchResults = [];
  List<String> _popularBrands = [];
  SneakerModel? _selectedSneaker;
  bool _isLoading = false;
  bool _isTopSneakersLoading = false;
  String? _error;
  String? _topSneakersError;
  int _currentPage = 1;
  bool _hasMoreSneakers = true;

  List<SneakerModel> get sneakers => _sneakers;
  List<SneakerModel> get topSneakers => _topSneakers;
  List<SneakerModel> get searchResults => _searchResults;
  List<String> get popularBrands => _popularBrands;
  SneakerModel? get selectedSneaker => _selectedSneaker;
  bool get isLoading => _isLoading;
  bool get isTopSneakersLoading => _isTopSneakersLoading;
  String? get error => _error;
  String? get topSneakersError => _topSneakersError;
  bool get hasMoreSneakers => _hasMoreSneakers;

  Future<void> loadSneakers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreSneakers = true;
      _sneakers.clear();
    }

    if (!_hasMoreSneakers || _isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final curatedBatch = <SneakerModel>[];
      int attempts = 0;

      while (_hasMoreSneakers &&
          curatedBatch.length < _pageSize &&
          attempts < _maxPageAttemptsPerLoad) {
        attempts++;

        final pageSneakers = await SneakerService.getAllSneakers(
          page: _currentPage,
          limit: _pageSize,
        );

        if (pageSneakers.length < _pageSize) {
          _hasMoreSneakers = false;
        }

        _currentPage++;

        final filteredSneakers = _filterBackendSneakers(pageSneakers);
        if (filteredSneakers.isEmpty) {
          continue;
        }

        curatedBatch.addAll(filteredSneakers);
      }

      if (refresh) {
        _sneakers = curatedBatch;
      } else {
        _sneakers.addAll(curatedBatch);
      }

      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTopSneakers({bool refresh = false}) async {
    if (_isTopSneakersLoading) return;
    if (!refresh && _topSneakers.isNotEmpty) return;

    _setTopSneakersLoading(true);
    _setTopSneakersError(null);

    try {
      final sneakers = await SneakerService.getTopSneakers(limit: 20);
      _topSneakers = _filterBackendSneakers(sneakers);
      notifyListeners();
    } catch (e) {
      _setTopSneakersError(_getErrorMessage(e));
    } finally {
      _setTopSneakersLoading(false);
    }
  }

  Future<void> searchSneakers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final sneakers = await SneakerService.searchSneakers(query);
      _searchResults = _filterBackendSneakers(sneakers);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadSneakerDetails(String sneakerId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedSneaker = await SneakerService.getSneaker(sneakerId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rateSneaker(String sneakerId, double rating) async {
    _clearError();

    try {
      final updatedSneaker = await SneakerService.rateSneaker(
        sneakerId,
        rating,
      );

      // Update the selected sneaker
      if (_selectedSneaker?.id == sneakerId) {
        _selectedSneaker = updatedSneaker;
      }

      // Update in other lists
      _updateSneakerInLists(updatedSneaker);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  Future<void> loadSneakersByBrand(String brand) async {
    _setLoading(true);
    _clearError();

    try {
      final sneakers = await SneakerService.getSneakersByBrand(brand);
      _searchResults = _filterBackendSneakers(sneakers);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPopularBrands() async {
    _setLoading(true);
    _clearError();

    try {
      _popularBrands = await SneakerService.getPopularBrands();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  void _updateSneakerInLists(SneakerModel updatedSneaker) {
    _updateSneakerInList(_sneakers, updatedSneaker);
    _updateSneakerInList(_topSneakers, updatedSneaker);
    _updateSneakerInList(_searchResults, updatedSneaker);
  }

  void _updateSneakerInList(
    List<SneakerModel> sneakers,
    SneakerModel updatedSneaker,
  ) {
    final index = sneakers.indexWhere(
      (sneaker) => sneaker.id == updatedSneaker.id,
    );
    if (index != -1) {
      sneakers[index] = updatedSneaker;
    }
  }

  void clearSelectedSneaker() {
    _selectedSneaker = null;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setTopSneakersLoading(bool loading) {
    if (_isTopSneakersLoading == loading) return;
    _isTopSneakersLoading = loading;
    notifyListeners();
  }

  void _setTopSneakersError(String? error) {
    if (_topSneakersError == error) return;
    _topSneakersError = error;
    notifyListeners();
  }

  void clearTopSneakersError() {
    _setTopSneakersError(null);
  }

  String _getErrorMessage(dynamic error) {
    return error.toString().replaceAll('Exception: ', '');
  }

  void clearError() {
    _clearError();
    _setTopSneakersError(null);
  }

  List<SneakerModel> _filterBackendSneakers(List<SneakerModel> sneakers) {
    return sneakers.where(_isBackendSneaker).toList();
  }

  bool _isBackendSneaker(SneakerModel sneaker) {
    final hasCatalogSource =
        (sneaker.sourceFile?.isNotEmpty ?? false) ||
        (sneaker.metadataOriginalRowHash?.isNotEmpty ?? false) ||
        (sneaker.metadata != null && sneaker.metadata!.isNotEmpty);
    final hasImage = sneaker.photoUrl.isNotEmpty;
    return hasCatalogSource && hasImage;
  }
}
