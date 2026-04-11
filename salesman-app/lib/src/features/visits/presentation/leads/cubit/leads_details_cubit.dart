import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/domain/entities/leads_list_entity.dart';
import 'package:track/src/features/visits/domain/usecases/get_all_leads.dart';

part 'leads_details_state.dart';

class LeadsDetailsCubit extends Cubit<LeadsDetailsState> {
  final GetAllLeads getAllLeads;
  LeadsDetailsCubit(this.getAllLeads) : super(LeadsDetailsInitial());

  LeadsListEntity leadsData = LeadsListEntity.empty();
  int _currentPage = 1;
  String _currentQuery = '';
  bool _isLoading = false;

  // Getters
  int get currentPage => _currentPage;
  String get currentQuery => _currentQuery;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _currentPage < leadsData.paginationData.totalPages;
  bool get canLoadMore => hasMoreData && !_isLoading;

  Future getAllTheLeads({
    required int pageNumber,
    int limit = 10,
    String? query,
    bool loadAllForMap = false,
  }) async {
    if (pageNumber > 1 &&
        leadsData.paginationData.totalPages > 0 &&
        pageNumber > leadsData.paginationData.totalPages) {
      return;
    }

    _isLoading = true;
    _currentPage = pageNumber;
    _currentQuery = query ?? '';

    // For map view, increase limit to show all leads
    if (loadAllForMap && limit == 10) {
      limit = 1000; // Load more leads for map display
    }

    if (query == null) {
      if (pageNumber > 1) {
        emit(LeadsDetailsLoading(false));
      } else {
        emit(LeadsDetailsLoading(true));
      }
    }

    final res = await getAllLeads(
      GetAllLeadsParams(pageNumber: pageNumber, limit: limit, query: query),
    );

    _isLoading = false;

    res.fold(
      (failure) =>
          emit(LeadsDetailsFailed(failure.message, failure.statusCode)),
      (leadsAPIData) {
        List<LeadsDetailsEntity> allLeads;

        if (pageNumber == 1) {
          allLeads = List<LeadsDetailsEntity>.from(leadsAPIData.allLeads);
        } else {
          allLeads = List<LeadsDetailsEntity>.from(leadsData.allLeads);
          allLeads.addAll(leadsAPIData.allLeads);
        }

        LeadsListEntity leadsNewData = LeadsListEntity(
          allLeads: allLeads,
          paginationData: leadsAPIData.paginationData,
          totalLeads: leadsAPIData.totalLeads,
          visitedLeads: leadsAPIData.visitedLeads,
          remainingLeads: leadsAPIData.remainingLeads,
        );

        leadsData = leadsNewData;
        emit(LeadsDetailsLoaded(leadsNewData));
      },
    );
  }

  Future<void> loadMoreLeads() async {
    if (!canLoadMore) return;

    final nextPage = _currentPage + 1;
    await getAllTheLeads(
      pageNumber: nextPage,
      query: _currentQuery.isNotEmpty ? _currentQuery : null,
    );
  }

  Future<void> refreshLeads() async {
    await getAllTheLeads(pageNumber: 1);
  }

  Future<void> searchLeads(String query) async {
    await getAllTheLeads(pageNumber: 1, query: query.isNotEmpty ? query : null);
  }

  Future<void> loadAllLeadsForMap() async {
    await getAllTheLeads(pageNumber: 1, loadAllForMap: true);
  }

  void resetPagination() {
    _currentPage = 1;
    _currentQuery = '';
    _isLoading = false;
  }
}
