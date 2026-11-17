import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../../rides/domain/entities/ride.dart';

final recentRidesFeedProvider = FutureProvider<List<Ride>>((ref) async {
  final response = await SupabaseConfig.client
      .from('rides')
      .select('*, profiles:owner_id(display_name, avatar_url)')
      .eq('status', 'open')
      .gt('available_seats', 0)
      .gte('travel_date', DateTime.now().toIso8601String().split('T').first)
      .order('created_at', ascending: false)
      .limit(5);

  return (response as List).map((row) => Ride.fromMap(row as Map<String, dynamic>)).toList();
});

final homeUpcomingJourneysProvider = FutureProvider.family<List<Ride>, String>((ref, userId) async {
  final response = await SupabaseConfig.client
      .from('rides')
      .select('*, profiles:owner_id(display_name, avatar_url)')
      .eq('owner_id', userId)
      .gte('travel_date', DateTime.now().toIso8601String().split('T').first)
      .order('travel_date', ascending: true)
      .limit(3);

  return (response as List).map((row) => Ride.fromMap(row as Map<String, dynamic>)).toList();
});

final homePendingRequestsCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final response = await SupabaseConfig.client
      .from('ride_requests')
      .select('id, rides!inner(owner_id)')
      .eq('status', 'pending')
      .eq('rides.owner_id', userId);

  return (response as List).length;
});
