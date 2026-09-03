import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../repositories/rental_repository.dart';
import 'application_detail_event.dart';
import 'application_detail_state.dart';

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
      final applications = await _repository.getApplications();
      final application =
          applications.where((item) => item.id == event.id).firstOrNull;
      if (application == null) {
        throw const AppException('The application could not be found.',
            type: AppErrorType.notFound);
      }
      emit(ApplicationDetailLoaded(application));
    } catch (error) {
      emit(ApplicationDetailFailure(readableError(error)));
    }
  }
}
