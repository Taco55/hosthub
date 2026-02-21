import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_errors/app_errors.dart';

import '../data/property_repository.dart';

enum PropertyContextStatus { initial, loading, loaded, error }

class PropertyContextState extends Equatable {
  static const _currentPropertyUnchanged = Object();

  const PropertyContextState({
    required this.status,
    required this.properties,
    this.currentProperty,
    this.error,
  });

  const PropertyContextState.initial()
    : status = PropertyContextStatus.initial,
      properties = const [],
      currentProperty = null,
      error = null;

  final PropertyContextStatus status;
  final List<PropertySummary> properties;
  final PropertySummary? currentProperty;
  final DomainError? error;

  PropertyContextState copyWith({
    PropertyContextStatus? status,
    List<PropertySummary>? properties,
    Object? currentProperty = _currentPropertyUnchanged,
    DomainError? error,
  }) {
    return PropertyContextState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      currentProperty: identical(currentProperty, _currentPropertyUnchanged)
          ? this.currentProperty
          : currentProperty as PropertySummary?,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, properties, currentProperty, error];

  @override
  String toString() {
    final current = currentProperty;
    return 'PropertyContextState('
        'status=$status, '
        'properties=${properties.length}, '
        'current=${current == null ? '-' : '${current.name}(${current.id})'}, '
        'hasError=${error != null})';
  }
}

class PropertyContextCubit extends Cubit<PropertyContextState> {
  PropertyContextCubit({required PropertyRepository repository})
    : _repository = repository,
      super(const PropertyContextState.initial()) {
    loadProperties();
  }

  final PropertyRepository _repository;

  Future<void> loadProperties() async {
    if (state.status == PropertyContextStatus.loading) return;
    emit(state.copyWith(status: PropertyContextStatus.loading, error: null));

    try {
      final properties = await _repository.fetchProperties();
      PropertySummary? current = state.currentProperty;
      if (properties.isEmpty) {
        current = null;
      } else if (current != null) {
        final index = properties.indexWhere(
          (property) => property.id == current!.id,
        );
        current = index >= 0 ? properties[index] : properties.first;
      } else {
        current = properties.first;
      }

      emit(
        state.copyWith(
          status: PropertyContextStatus.loaded,
          properties: properties,
          currentProperty: current,
          error: null,
        ),
      );
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: PropertyContextStatus.error,
          properties: const [],
          currentProperty: null,
          error: DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  void selectProperty(PropertySummary property) {
    if (state.currentProperty?.id == property.id) return;
    emit(state.copyWith(currentProperty: property));
  }

  Future<PropertySummary?> createProperty(String name) async {
    try {
      final property = await _repository.createProperty(name: name);
      emit(state.copyWith(currentProperty: property));
      await loadProperties();
      return property;
    } catch (error, stack) {
      emit(
        state.copyWith(
          status: PropertyContextStatus.error,
          error: DomainError.from(error, stack: stack),
        ),
      );
      return null;
    }
  }

  void reset() {
    emit(const PropertyContextState.initial());
  }
}
