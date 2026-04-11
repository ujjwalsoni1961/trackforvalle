import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/entities/contract_template_entity.dart';
import 'package:track/src/features/visits/domain/usecases/get_contracts_templates.dart';

part 'get_contract_templates_state.dart';

class GetContractTemplatesCubit extends Cubit<GetContractTemplatesState> {
  final GetContractsTemplates getContractsTemplates;
  GetContractTemplatesCubit(this.getContractsTemplates)
    : super(GetContractTemplatesInitial());

  List<ContractTemplateEntity> contractTemplates = [];

  void getTheContractTemplates() async {
    emit(GetContractTemplatesLoading());
    final res = await getContractsTemplates();
    res.fold((failure) => emit(GetContractTemplatesFailed(failure.message)), (
      templates,
    ) {
      contractTemplates = templates.contracts;
      emit(GetContractTemplatesSuccess(templates.contracts));
    });
  }
}
