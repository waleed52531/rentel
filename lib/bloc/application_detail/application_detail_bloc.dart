import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/data/errors/app_exception.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/bloc/application_detail/application_detail_event.dart';
import 'package:rent_settlement_app/bloc/application_detail/application_detail_state.dart';

class ApplicationDetailBloc
    extends Bloc<ApplicationDetailEvent, ApplicationDetailState> {
  ApplicationDetailBloc(this._repository)
      : super(const ApplicationDetailInitial()) {
    on<ApplicationDetailRequested>(_load);
  }

  final RentalRepository _repository;

  Future<void> _load(ApplicationDetailRequested event,
      Emitter<ApplicationDetailState> emit) async {
    emit(const ApplicationDetailLoading());
    try {
      final application = await _repository.getApplication(event.id);
      emit(ApplicationDetailLoaded(application));
    } catch (error) {
      emit(ApplicationDetailFailure(readableError(error)));
    }
  }
}
