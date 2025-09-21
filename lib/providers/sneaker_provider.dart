import 'package:flutter/material.dart';
import '../models/sneaker_model.dart';
import '../services/sneaker_service.dart';

class SneakerProvider with ChangeNotifier {
  List<SneakerModel> _sneakers = [];
  List<SneakerModel> _topSneakers = [];
  List<SneakerModel> _searchResults = [];
  List<String> _popularBrands = [];
  SneakerModel? _selectedSneaker;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreSneakers = true;

  List<SneakerModel> get sneakers => _sneakers;
  List<SneakerModel> get topSneakers => _topSneakers;
  List<SneakerModel> get searchResults => _searchResults;
  List<String> get popularBrands => _popularBrands;
  SneakerModel? get selectedSneaker => _selectedSneaker;
  bool get isLoading => _isLoading;
  String? get error => _error;
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
      final newSneakers = await SneakerService.getAllSneakers(
        page: _currentPage,
        limit: 10,
      );

      if (newSneakers.length < 10) {
        _hasMoreSneakers = false;
      }

      if (refresh) {
        _sneakers = newSneakers;
      } else {
        _sneakers.addAll(newSneakers);
      }

      _currentPage++;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTopSneakers() async {
    _setLoading(true);
    _clearError();

    try {
      _topSneakers = await SneakerService.getTopSneakers(limit: 20);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
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
      _searchResults = await SneakerService.searchSneakers(query);
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
      _searchResults = await SneakerService.getSneakersByBrand(brand);
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

  String _getErrorMessage(dynamic error) {
    return error.toString().replaceAll('Exception: ', '');
  }

  void clearError() {
    _clearError();
  }
}
