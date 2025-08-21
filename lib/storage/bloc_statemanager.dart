import 'package:flutter_bloc/flutter_bloc.dart';

abstract class OrderEvent {}

class ClearCartEvent extends OrderEvent {}

class OrderState {
  final bool cartCleared;
  OrderState({this.cartCleared = false});
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderState()) {
    on<ClearCartEvent>((event, emit) {
      emit(OrderState(cartCleared: true)); // mark as cleared
    });
  }
}
