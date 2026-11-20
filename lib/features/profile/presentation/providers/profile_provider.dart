import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

final userProfileProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(null);
  }

  return SupabaseConfig.client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((list) => list.isNotEmpty ? list.first : null);
});
