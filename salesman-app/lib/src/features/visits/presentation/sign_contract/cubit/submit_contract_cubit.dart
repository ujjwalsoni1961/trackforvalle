import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/repositories/contracts_repository.dart';
import 'package:track/src/features/visits/domain/usecases/submit_contract.dart';
import 'package:track/src/features/visits/domain/usecases/submit_contract_pdf.dart';

part 'submit_contract_state.dart';

class SubmitContractCubit extends Cubit<SubmitContractState> {
  final SubmitContract submitContract;
  final SubmitContractPdf _submitContractPdfUseCase;
  final ContractsRepository _repository;

  SubmitContractCubit({
    required this.submitContract,
    required SubmitContractPdf submitContractPdf,
    required ContractsRepository repository,
  }) : _submitContractPdfUseCase = submitContractPdf,
       _repository = repository,
       super(SubmitContractInitial());

  void submitTheContract({
    required int leadID,
    required int contractTemplateID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required File signature,
  }) async {
    emit(SubmitContractLoading());
    final res = await submitContract(
      SubmitContractParams(
        leadID: leadID,
        metaData: metaData,
        dropdownValues: dropdownValues,
        contractTemplateID: contractTemplateID,
        signature: signature,
      ),
    );
    res.fold(
      (failure) => emit(SubmitContractFailed(failure.message)),
      (contract) => emit(
        SubmitContractSuccess(
          contractID: contract.contractID,
          visitID: contract.visitID,
        ),
      ),
    );
  }

  void submitContractPdf({
    required int leadID,
    required int contractTemplateID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required File contractPdf,
  }) async {
    emit(SubmitContractLoading());
    final res = await _submitContractPdfUseCase(
      SubmitContractPdfParams(
        leadID: leadID,
        metaData: metaData,
        dropdownValues: dropdownValues,
        contractTemplateID: contractTemplateID,
        contractPdf: contractPdf,
      ),
    );
    res.fold(
      (failure) {
        String errorMessage = failure.message;
        if (errorMessage.contains('Only PDF files are allowed')) {
          errorMessage = 'Server rejected the file. Please try using signature mode instead.';
        } else if (errorMessage.contains('500 Internal Server Error')) {
          errorMessage = 'Server error occurred. Please try signature mode or contact support.';
        }
        emit(SubmitContractFailed(errorMessage));
      },
      (contract) => emit(
        SubmitContractSuccess(
          contractID: contract.contractID,
          visitID: contract.visitID,
        ),
      ),
    );
  }

  void signContract({
    required int templateId,
    required int leadId,
    required Map<String, String> fieldValues,
    required String signatureBase64,
  }) async {
    emit(SubmitContractLoading());
    try {
      final result = await _repository.signContract(
        templateId: templateId,
        leadId: leadId,
        fieldValues: fieldValues,
        signatureBase64: signatureBase64,
      );
      result.fold(
        (failure) => emit(SubmitContractFailed(failure.message)),
        (data) {
          final contractId = data['contract_id'] as int? ?? 0;
          final visitId = data['visit_id'] as int? ?? 0;
          emit(SubmitContractSuccess(contractID: contractId, visitID: visitId));
        },
      );
    } catch (e) {
      emit(SubmitContractFailed(e.toString()));
    }
  }
}
