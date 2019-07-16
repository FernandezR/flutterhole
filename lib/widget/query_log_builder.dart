import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_bloc.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_event.dart';
import 'package:flutterhole_again/bloc/blacklist/blacklist_state.dart';
import 'package:flutterhole_again/bloc/query/query_bloc.dart';
import 'package:flutterhole_again/bloc/query/query_event.dart';
import 'package:flutterhole_again/bloc/query/query_state.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_bloc.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_event.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_state.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/model/query.dart';
import 'package:flutterhole_again/model/whitelist.dart';
import 'package:flutterhole_again/service/browser.dart';
import 'package:flutterhole_again/widget/scaffold.dart';
import 'package:intl/intl.dart';

import 'error_message.dart';

String dnsSecStatusToString(DnsSecStatus dnsSecStatus) {
  return dnsSecStatus == DnsSecStatus.Empty
      ? 'no DNSSEC'
      : dnsSecStatus.toString().replaceAll('DnsSecStatus.', '');
}

String queryTypeToString(QueryType type) {
  return type == QueryType.UNKN
      ? 'Unknown'
      : type.toString().replaceAll('QueryType.', '');
}

String queryStatusToString(QueryStatus status) {
  switch (status) {
    case QueryStatus.BlockedWithGravity:
      return 'Blocked (gravity)';
    case QueryStatus.Forwarded:
      return 'OK (forwarded)';
    case QueryStatus.Cached:
      return 'OK (cached)';
    case QueryStatus.BlockedWithRegexWildcard:
      return 'Blocked (regex/wildcard)';
    case QueryStatus.BlockedWithBlacklist:
      return 'Blocked (blacklist)';
    case QueryStatus.BlockedWithExternalIP:
      return 'Blocked (external, IP)';
      break;
    case QueryStatus.BlockedWithExternalNull:
      return 'Blocked (external, NULL)';
      break;
    case QueryStatus.BlockedWithExternalNXRA:
      return 'Blocked (external, NXRA)';
      break;
    case QueryStatus.Unknown:
      return 'Unknown';
      break;
    default:
      return 'Empty';
  }
}

class QueryLogBuilder extends StatefulWidget {
  @override
  _QueryLogBuilderState createState() => _QueryLogBuilderState();
}

class _QueryLogBuilderState extends State<QueryLogBuilder> {
  Completer _refreshCompleter;

  List<Query> _queryCache;

  Whitelist _whitelistCache;
  Blacklist _blacklistCache;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer();
    _queryCache = [];
  }

  @override
  Widget build(BuildContext context) {
    final QueryBloc queryBloc = BlocProvider.of<QueryBloc>(context);
    final WhitelistBloc whitelistBloc = BlocProvider.of<WhitelistBloc>(context);
    final BlacklistBloc blacklistBloc = BlocProvider.of<BlacklistBloc>(context);
    return MultiBlocListener(
      listeners: [
        BlocListener(
            bloc: queryBloc,
            listener: (context, state) {
              if (state is QueryStateEmpty) {
                queryBloc.dispatch(FetchQueries());
              }

              if (state is QueryStateSuccess || state is QueryStateError) {
                _refreshCompleter?.complete();
                _refreshCompleter = Completer();

                if (state is QueryStateSuccess) {
                  setState(() {
                    _queryCache = state.queries;
                  });
                }
              }
            }),
        BlocListener(
          bloc: whitelistBloc,
          listener: (context, state) {
            if (state is WhitelistStateSuccess) {
              setState(() {
                _whitelistCache = state.whitelist;
              });
            }
          },
        ),
        BlocListener(
          bloc: blacklistBloc,
          listener: (context, state) {
            if (state is BlacklistStateSuccess) {
              setState(() {
                _blacklistCache = state.blacklist;
              });
            }
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () {
          queryBloc.dispatch(FetchQueries());
          whitelistBloc.dispatch(FetchWhitelist());
          blacklistBloc.dispatch(FetchBlacklist());
          return _refreshCompleter.future;
        },
        child: BlocBuilder(
            bloc: queryBloc,
            builder: (BuildContext context, QueryState state) {
              if (state is QueryStateSuccess ||
                  state is QueryStateLoading && _queryCache != null) {
                if (state is QueryStateSuccess) {
                  _queryCache = state.queries;
                }

                return Scrollbar(
                  child: ListView.separated(
                    itemCount: _queryCache.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Query query = _queryCache[index];

                      final bool isOnWhitelist = _whitelistCache != null &&
                          _whitelistCache.list.contains(query.entry);
                      final bool isOnBlacklist = _blacklistCache != null &&
                          _blacklistCache.exact.contains(
                              BlacklistItem.exact(entry: query.entry));

                      final actions = <Widget>[
                        IconButton(
                            icon: Icon(Icons.open_in_browser),
                            tooltip:
                            'Open in browser ${Uri.parse(query.entry)
                                .toString()}',
                            onPressed: () {
                              final uri = Uri.parse(query.entry);
                              final url = uri.scheme.length > 0
                                  ? uri.toString()
                                  : 'http://${uri.toString()}';
                              launchURL(url);
                            }),
                        isOnWhitelist
                            ? IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: 'Remove from whitelist',
                          onPressed: () {
                            whitelistBloc.dispatch(
                                RemoveFromWhitelist(query.entry));
                            showSnackBar(
                                context,
                                Text(
                                    'Removing ${query.entry} from whitelist'));
                          },
                        )
                            : isOnBlacklist
                            ? null
                            : IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: Theme
                                .of(context)
                                .iconTheme
                                .color,
                          ),
                          tooltip: 'Add to whitelist',
                          onPressed: () {
                            whitelistBloc.dispatch(
                                AddToWhitelist(query.entry));
                            showSnackBar(
                                context,
                                Text(
                                    'Adding ${query.entry} to whitelist'));
                          },
                        ),
                        isOnBlacklist
                            ? IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: 'Remove from blacklist',
                          onPressed: () {
                            blacklistBloc.dispatch(RemoveFromBlacklist(
                                BlacklistItem.exact(entry: query.entry)));
                            showSnackBar(
                                context,
                                Text(
                                    'Removing ${query.entry} from blacklist'));
                          },
                        )
                            : isOnWhitelist
                            ? null
                            : IconButton(
                          icon: Icon(
                            Icons.cancel,
                          ),
                          tooltip: 'Add to blacklist',
                          onPressed: () {
                            blacklistBloc.dispatch(AddToBlacklist(
                                BlacklistItem.exact(
                                    entry: query.entry)));
                            showSnackBar(
                                context,
                                Text(
                                    'Adding ${query.entry} to blacklist'));
                          },
                        ),
                      ];

                      return QueryExpansionTile(
                        query: query,
                        actions: actions,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(height: 1);
                    },
                  ),
                );
              }

              if (state is QueryStateError) {
                return ErrorMessage(errorMessage: state.e.message);
              }

              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}

class QueryExpansionTile extends StatelessWidget {
  final Query query;

  final List<Widget> actions;

  const QueryExpansionTile(
      {Key key, @required this.query, this.actions = const []})
      : super(key: key);

  static final _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final bool successful = (query.queryStatus == QueryStatus.Cached ||
        query.queryStatus == QueryStatus.Forwarded);
    return ExpansionTile(
      key: Key(query.entry),
      backgroundColor: Theme
          .of(context)
          .dividerColor,
      leading: _expansionTileLeading(query, successful),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(query.entry),
          Text(
            _formatter.format(query.time),
            style: Theme
                .of(context)
                .textTheme
                .caption,
          ),
          Text(
            queryStatusToString(query.queryStatus),
            style: Theme
                .of(context)
                .textTheme
                .caption
                .copyWith(color: successful ? Colors.green : Colors.red),
          )
        ],
      ),
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                ListTile(
                  title: Text(_formatter.format(query.time)),
                  subtitle: Text('Time'),
                ),
                ListTile(
                  title: Text(queryTypeToString(query.queryType)),
                  subtitle: Text('Type'),
                ),
                ListTile(
                  title: Text(query.client),
                  subtitle: Text('Client'),
                ),
                ListTile(
                  title: Text(queryStatusToString(query.queryStatus)),
                  subtitle: Text('Query status'),
                ),
                ListTile(
                  title: Text(dnsSecStatusToString(query.dnsSecStatus)),
                  subtitle: Text('DNSSEC'),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: ButtonBar(
                    children: actions,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  _expansionTileLeading(Query query, bool successful) {
    final color = successful ? Colors.green : Colors.red;
    IconData data = successful ? Icons.check_circle : Icons.cancel;
    switch (query.queryStatus) {
      case QueryStatus.BlockedWithGravity:
        data = Icons.remove_circle;
        break;
      case QueryStatus.Forwarded:
        break;
      case QueryStatus.Cached:
        data = Icons.cached;
        break;
      case QueryStatus.BlockedWithRegexWildcard:
        data = Icons.code;
        break;
      default:
        break;
    }

    return Icon(data, color: color);
  }
}
