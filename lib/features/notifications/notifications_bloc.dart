import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../repositories/rental_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._repository) : super(const NotificationsInitial()) {
    on<NotificationsRequested>(_load);
    on<NotificationReadRequested>(_read);
    on<AllNotificationsReadRequested>(_readAll);
  }
  final RentalRepository _repository;
  Future<void> _load(
      NotificationsRequested event, Emitter<NotificationsState> emit) async {
    emit(const NotificationsLoading());
    await _refresh(emit, unread: event.unreadOnly);
  }

  Future<void> _read(
      NotificationReadRequested event, Emitter<NotificationsState> emit) async {
    try {
      await _repository.markNotificationsRead(ids: [event.id]);
      await _refresh(emit);
    } catch (error) {
      emit(NotificationsFailure(readableError(error)));
    }
  }

  Future<void> _readAll(AllNotificationsReadRequested event,
      Emitter<NotificationsState> emit) async {
    try {
      await _repository.markNotificationsRead();
      await _refresh(emit, message: 'All notifications marked as read.');
    } catch (error) {
      emit(NotificationsFailure(readableError(error)));
    }
  }

  Future<void> _refresh(Emitter<NotificationsState> emit,
      {bool unread = false, String? message}) async {
    try {
      final items = await _repository.getNotifications(unread: unread);
      emit(items.isEmpty
          ? const NotificationsEmpty()
          : NotificationsLoaded(items, message: message));
    } catch (error) {
      emit(NotificationsFailure(readableError(error)));
    }
  }
}
