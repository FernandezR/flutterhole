import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole_again/bloc/query/query_event.dart';
import 'package:flutterhole_again/bloc/query/query_state.dart';
import 'package:flutterhole_again/repository/query_repository.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';

class QueryBloc extends Bloc<QueryEvent, QueryState> {
  final QueryRepository queryRepository;

  QueryBloc(this.queryRepository);

  @override
  QueryState get initialState => QueryStateEmpty();

  @override
  Stream<QueryState> mapEventToState(
    QueryEvent event,
  ) async* {
    yield QueryStateLoading(cache: queryRepository.cache);
    if (event is FetchQueries) yield* _fetch();
  }

  Stream<QueryState> _fetch() async* {
    try {
      final cache = await queryRepository.getQueries();
      print('bloc cache: ${cache.length}');
      yield QueryStateSuccess(cache);
    } on PiholeException catch (e) {
      yield QueryStateError(e: e);
    }
  }
}