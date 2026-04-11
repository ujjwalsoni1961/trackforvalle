import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'tab_change_state.dart';

class TabChangeCubit extends Cubit<TabChangeState> {
  TabChangeCubit() : super(TabChangeInitial());
  int tabIndex = 0;
  void changeTab(int index) {
    tabIndex = index;
    emit(TabChange(index));
  }

  int calculateNavBarIndexFromTabIndex(int tabIndex) {
    if (tabIndex < 2) {
      return tabIndex;
    } else {
      return tabIndex + 1;
    }
  }
}
