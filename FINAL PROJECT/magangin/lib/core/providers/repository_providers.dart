
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../config.dart';

// Interfaces
import '../../repositories/interfaces/auth_repository.dart';
import '../../repositories/interfaces/profile_repository.dart';
import '../../repositories/interfaces/preference_repository.dart';
import '../../repositories/interfaces/job_repository.dart';
import '../../repositories/interfaces/saved_job_repository.dart';
import '../../repositories/interfaces/document_repository.dart';
import '../../repositories/interfaces/application_repository.dart';
import '../../repositories/interfaces/company_repository.dart';
import '../../repositories/interfaces/admin_repository.dart';
import '../../repositories/interfaces/notification_repository.dart';

// Mock repositories
import '../../repositories/mock/mock_auth_repository.dart';
import '../../repositories/mock/mock_profile_repository.dart';
import '../../repositories/mock/mock_preference_repository.dart';
import '../../repositories/mock/mock_job_repository.dart';
import '../../repositories/mock/mock_saved_job_repository.dart';
import '../../repositories/mock/mock_document_repository.dart';
import '../../repositories/mock/mock_application_repository.dart';
import '../../repositories/mock/mock_company_repository.dart';
import '../../repositories/mock/mock_admin_repository.dart';
import '../../repositories/mock/mock_notification_repository.dart';

// Supabase repositories
import '../../repositories/supabase/supabase_auth_repository.dart';
import '../../repositories/supabase/supabase_profile_repository.dart';
import '../../repositories/supabase/supabase_preference_repository.dart';
import '../../repositories/supabase/supabase_job_repository.dart';
import '../../repositories/supabase/supabase_saved_job_repository.dart';
import '../../repositories/supabase/supabase_document_repository.dart';
import '../../repositories/supabase/supabase_application_repository.dart';
import '../../repositories/supabase/supabase_company_repository.dart';
import '../../repositories/supabase/supabase_admin_repository.dart';
import '../../repositories/supabase/supabase_notification_repository.dart';

List<SingleChildWidget> get repositoryProviders {
  if (AppConfig.useMock) {
    final preferenceRepository = MockPreferenceRepository();

    return [
      Provider<AuthRepository>(
        create: (_) => MockAuthRepository(),
      ),
      Provider<ProfileRepository>(
        create: (_) => MockProfileRepository(),
      ),
      Provider<PreferenceRepository>.value(
        value: preferenceRepository,
      ),
      Provider<JobRepository>(
        create: (_) => MockJobRepository(
          preferenceRepository: preferenceRepository,
        ),
      ),
      Provider<SavedJobRepository>(
        create: (_) => MockSavedJobRepository(),
      ),
      Provider<DocumentRepository>(
        create: (_) => MockDocumentRepository(),
      ),
      Provider<ApplicationRepository>(
        create: (_) => MockApplicationRepository(),
      ),
      Provider<CompanyRepository>(
        create: (_) => MockCompanyRepository(),
      ),
      Provider<AdminRepository>(
        create: (_) => MockAdminRepository(),
      ),
      Provider<NotificationRepository>(
        create: (_) => MockNotificationRepository(),
      ),
    ];
  }

  return [
    Provider<AuthRepository>(
      create: (_) => SupabaseAuthRepository(),
    ),
    Provider<ProfileRepository>(
      create: (_) => SupabaseProfileRepository(),
    ),
    Provider<PreferenceRepository>(
      create: (_) => SupabasePreferenceRepository(),
    ),
    Provider<JobRepository>(
      create: (_) => SupabaseJobRepository(),
    ),
    Provider<SavedJobRepository>(
      create: (_) => SupabaseSavedJobRepository(),
    ),
    Provider<DocumentRepository>(
      create: (_) => SupabaseDocumentRepository(),
    ),
    Provider<ApplicationRepository>(
      create: (_) => SupabaseApplicationRepository(),
    ),
    Provider<CompanyRepository>(
      create: (_) => SupabaseCompanyRepository(),
    ),
    Provider<AdminRepository>(
      create: (_) => SupabaseAdminRepository(),
    ),
    Provider<NotificationRepository>(
      create: (_) => SupabaseNotificationRepository(),
    ),
  ];
}
