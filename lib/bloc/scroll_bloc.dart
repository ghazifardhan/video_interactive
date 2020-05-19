import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ScrollState extends Equatable {
  const ScrollState();

  @override
  List<Object> get props => null;
}

class ScrollUnreadyState extends ScrollState {}

class ScrollReadyState extends ScrollState {

  final ScrollNotification scrollNotification;
  final int count;

  ScrollReadyState({
    @required this.scrollNotification,
    @required this.count,
  });

  ScrollReadyState copyWith({
    ScrollNotification scrollNotification,
    int count,
  }) {
    return ScrollReadyState(
        scrollNotification: scrollNotification ?? this.scrollNotification,
        count: count ?? this.count
    );
  }

  @override
  List<Object> get props => [
    scrollNotification,
    count,
  ];

  @override
  String toString() => 'ScrollReadyState {}';


}

// Event
abstract class ScrollEvent extends Equatable {
  const ScrollEvent();

  @override
  List<Object> get props => null;
}

class ScrollAttachedEvent extends ScrollEvent {
  final ScrollNotification scrollNotification;

  ScrollAttachedEvent({ @required this.scrollNotification });
}

// Bloc

class ScrollBloc extends Bloc<ScrollEvent, ScrollState> {

  int _count = 0;

  @override
  ScrollState get initialState => ScrollUnreadyState();

  @override
  Stream<ScrollState> mapEventToState(ScrollEvent event) async* {
    if (event is ScrollAttachedEvent) {
      if (state is ScrollUnreadyState) {

        // print(event.scrollNotification);

        yield ScrollReadyState(
          scrollNotification: event.scrollNotification,
          count: _count++
        );
      } else {

        // print(event.scrollNotification);

        yield (state as ScrollReadyState).copyWith(
          scrollNotification: event.scrollNotification,
          count: _count++
        );
      }
    }
  }

}