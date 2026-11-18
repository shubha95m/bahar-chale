import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../rides/domain/entities/ride.dart';

/// Live Realtime stream of recent driver-offered rides on the Home page feed.
/// Instantly displays newly offered rides or seat changes without manual refresh.
final recentRidesFeedProvider = StreamProvider<List<Ride>>((ref) async* {
  final user = ref.watch(currentUserProvider);
  final controller = StreamController<List<Ride>>();

  Future<List<Ride>> fetch() async {
    var query = SupabaseConfig.client
        .from('rides')
        .select('*, profiles:owner_id(display_name, avatar_url)')
        .eq('status', 'open')
        .gt('available_seats', 0)
        .gte('travel_date', DateTime.now().toIso8601String().split('T').first);

    if (user != null) {
      query = query.neq('owner_id', user.id);
    }

    final response = await query.order('created_at', ascending: false).limit(10);
    return (response as List).map((row) => Ride.fromMap(row as Map<String, dynamic>)).toList();
  }

  final initial = await fetch();
  if (!controller.isClosed) controller.add(initial);

  final channel = SupabaseConfig.client
      .channel('realtime:home_recent_rides')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'rides',
        callback: (_) async {
          final fresh = await fetch();
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  final timer = Timer.periodic(const Duration(seconds: 5), (_) async {
    final fresh = await fetch();
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

/// Live Realtime stream of user's upcoming journeys on the Home page.
final homeUpcomingJourneysProvider = StreamProvider.family<List<Ride>, String>((ref, userId) async* {
  final controller = StreamController<List<Ride>>();

  Future<List<Ride>> fetch() async {
    final response = await SupabaseConfig.client
        .from('rides')
        .select('*, profiles:owner_id(display_name, avatar_url)')
        .eq('owner_id', userId)
        .gte('travel_date', DateTime.now().toIso8601String().split('T').first)
        .order('travel_date', ascending: true)
        .limit(3);

    return (response as List).map((row) => Ride.fromMap(row as Map<String, dynamic>)).toList();
  }

  final initial = await fetch();
  if (!controller.isClosed) controller.add(initial);

  final channel = SupabaseConfig.client
      .channel('realtime:home_upcoming:$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'rides',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'owner_id',
          value: userId,
        ),
        callback: (_) async {
          final fresh = await fetch();
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  final timer = Timer.periodic(const Duration(seconds: 5), (_) async {
    final fresh = await fetch();
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});

/// Live Realtime stream of pending requests count for a driver.
final homePendingRequestsCountProvider = StreamProvider.family<int, String>((ref, userId) async* {
  final controller = StreamController<int>();

  Future<int> fetch() async {
    final response = await SupabaseConfig.client
        .from('ride_requests')
        .select('id, rides!inner(owner_id)')
        .eq('status', 'pending')
        .eq('rides.owner_id', userId);

    return (response as List).length;
  }

  final initial = await fetch();
  if (!controller.isClosed) controller.add(initial);

  final channel = SupabaseConfig.client
      .channel('realtime:home_pending_count:$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'ride_requests',
        callback: (_) async {
          final fresh = await fetch();
          if (!controller.isClosed) controller.add(fresh);
        },
      )
      .subscribe();

  final timer = Timer.periodic(const Duration(seconds: 5), (_) async {
    final fresh = await fetch();
    if (!controller.isClosed) controller.add(fresh);
  });

  ref.onDispose(() {
    timer.cancel();
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});
