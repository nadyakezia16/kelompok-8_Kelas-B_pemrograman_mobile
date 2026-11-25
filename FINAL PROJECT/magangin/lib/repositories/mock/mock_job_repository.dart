
import '../../models/company.dart';
import '../../models/job.dart';
import '../interfaces/job_repository.dart';
import '../interfaces/preference_repository.dart';

class MockJobRepository implements JobRepository {
  MockJobRepository({
    this._preferenceRepository,
  });

  final PreferenceRepository? _preferenceRepository;

  final List<Company> _companies = [
    const Company(
      id: 'company-001',
      name: 'PT Teknologi Nusantara',
      location: 'Makassar',
      industry: 'Technology',
    ),
    const Company(
      id: 'company-002',
      name: 'Digital Kreatif Indonesia',
      location: 'Jakarta',
      industry: 'Digital Agency',
    ),
    const Company(
      id: 'company-003',
      name: 'Inovasi Data Indonesia',
      location: 'Bandung',
      industry: 'Data Science',
    ),
    const Company(
      id: 'company-004',
      name: 'Karya Media Digital',
      location: 'Yogyakarta',
      industry: 'Media',
    ),
    const Company(
      id: 'company-005',
      name: 'Solusi Finansial Nusantara',
      location: 'Jakarta',
      industry: 'Finance',
    ),
    const Company(
      id: 'company-006',
      name: 'EduTech Indonesia',
      location: 'Makassar',
      industry: 'Education',
    ),
    const Company(
      id: 'company-007',
      name: 'Kreatif Visual Studio',
      location: 'Surabaya',
      industry: 'Design',
    ),
    const Company(
      id: 'company-008',
      name: 'Cloud Network Indonesia',
      location: 'Jakarta',
      industry: 'IT Services',
    ),
    const Company(
      id: 'company-009',
      name: 'Green Future Indonesia',
      location: 'Bogor',
      industry: 'Environment',
    ),
    const Company(
      id: 'company-010',
      name: 'Startup Muda Indonesia',
      location: 'Makassar',
      industry: 'Startup',
    ),
  ];

  late final List<Job> _jobs = _buildJobs();

  List<Job> _buildJobs() {
    return [
      _createJob('job-001', 'company-001', 'Flutter Developer Intern', 'Technology', 'Makassar', 'hybrid', 3, true),
      _createJob('job-002', 'company-001', 'UI/UX Designer Intern', 'Design', 'Makassar', 'onsite', 3, true),
      _createJob('job-003', 'company-002', 'Frontend Developer Intern', 'Technology', 'Jakarta', 'remote', 6, true),
      _createJob('job-004', 'company-002', 'Social Media Intern', 'Marketing', 'Jakarta', 'hybrid', 3, false),
      _createJob('job-005', 'company-003', 'Data Analyst Intern', 'Data Science', 'Bandung', 'onsite', 6, true),
      _createJob('job-006', 'company-003', 'Backend Developer Intern', 'Technology', 'Bandung', 'remote', 3, true),
      _createJob('job-007', 'company-004', 'Content Writer Intern', 'Content', 'Yogyakarta', 'remote', 3, false),
      _createJob('job-008', 'company-004', 'Graphic Designer Intern', 'Design', 'Yogyakarta', 'hybrid', 3, true),
      _createJob('job-009', 'company-005', 'Finance Intern', 'Finance', 'Jakarta', 'onsite', 6, true),
      _createJob('job-010', 'company-005', 'Business Analyst Intern', 'Business', 'Jakarta', 'hybrid', 3, true),
      _createJob('job-011', 'company-006', 'Mobile Developer Intern', 'Technology', 'Makassar', 'remote', 6, true),
      _createJob('job-012', 'company-006', 'Education Content Intern', 'Education', 'Makassar', 'onsite', 3, false),
      _createJob('job-013', 'company-007', 'Visual Designer Intern', 'Design', 'Surabaya', 'hybrid', 3, true),
      _createJob('job-014', 'company-007', 'Video Editor Intern', 'Multimedia', 'Surabaya', 'onsite', 3, false),
      _createJob('job-015', 'company-008', 'Network Engineer Intern', 'Technology', 'Jakarta', 'onsite', 6, true),
      _createJob('job-016', 'company-008', 'IT Support Intern', 'IT Support', 'Jakarta', 'hybrid', 3, true),
      _createJob('job-017', 'company-009', 'Environmental Research Intern', 'Research', 'Bogor', 'onsite', 6, false),
      _createJob('job-018', 'company-009', 'Data Entry Intern', 'Administration', 'Bogor', 'remote', 3, true),
      _createJob('job-019', 'company-010', 'Product Management Intern', 'Business', 'Makassar', 'hybrid', 3, true),
      _createJob('job-020', 'company-010', 'Full Stack Developer Intern', 'Technology', 'Makassar', 'remote', 6, true),
    ];
  }

  Job _createJob(
      String id,
      String companyId,
      String title,
      String category,
      String location,
      String workType,
      int durationMonths,
      bool isPaid,
      ) {
    return Job(
      id: id,
      companyId: companyId,
      company: _companies.firstWhere(
            (company) => company.id == companyId,
      ),
      title: title,
      category: category,
      location: location,
      workType: workType,
      durationMonths: durationMonths,
      isPaid: isPaid,
      allowance: isPaid ? 1500000 : null,
      description: 'Kesempatan magang untuk belajar dan mengembangkan keterampilan di bidang $category.',
      qualifications: [
        'Mahasiswa aktif',
        'Bersedia belajar dan bekerja dalam tim',
        'Memiliki ketertarikan pada bidang $category',
      ],
      benefits: [
        'Pengalaman kerja',
        'Bimbingan mentor',
        'Sertifikat magang',
      ],
      deadline: DateTime.now().add(const Duration(days: 30)),
      status: 'open',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<Job>> searchJobs({
    String? query,
    String? category,
    String? location,
    String? workType,
    int? durationMonths,
    bool? isPaid,
  }) async {
    return _jobs.where((job) {
      final searchText = query?.toLowerCase().trim() ?? '';

      final matchesQuery = searchText.isEmpty ||
          job.title.toLowerCase().contains(searchText) ||
          job.category.toLowerCase().contains(searchText) ||
          (job.company?.name.toLowerCase().contains(searchText) ?? false);

      final matchesCategory = category == null ||
          job.category.toLowerCase().contains(category.toLowerCase());

      final matchesLocation = location == null ||
          job.location.toLowerCase().contains(location.toLowerCase());

      final matchesWorkType =
          workType == null || job.workType == workType;

      final matchesDuration =
          durationMonths == null || job.durationMonths == durationMonths;

      final matchesPayment = isPaid == null || job.isPaid == isPaid;

      return matchesQuery &&
          matchesCategory &&
          matchesLocation &&
          matchesWorkType &&
          matchesDuration &&
          matchesPayment &&
          job.status == 'open';
    }).toList();
  }

  @override
  Future<List<Job>> getLatestJobs() async {
    final jobs = _jobs.where((job) => job.status == 'open').toList();

    jobs.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return jobs;
  }

  @override
  Future<List<Job>> getRecommendedJobs() async {
    final preference = await _preferenceRepository?.getPreferences();

    if (preference == null) {
      return getLatestJobs();
    }

    final recommended = _jobs.where((job) {
      final matchesCategory = preference.categories.isEmpty ||
          preference.categories.any(
                (category) => job.category.toLowerCase().contains(
              category.toLowerCase(),
            ),
          );

      final matchesLocation = preference.locations.isEmpty ||
          preference.locations.any(
                (location) => job.location.toLowerCase().contains(
              location.toLowerCase(),
            ),
          );

      final matchesWorkType = preference.workTypes.isEmpty ||
          preference.workTypes.contains(job.workType);

      final matchesDuration = preference.durationMonths == null ||
          job.durationMonths == preference.durationMonths;

      return job.status == 'open' &&
          matchesCategory &&
          matchesLocation &&
          matchesWorkType &&
          matchesDuration;
    }).toList();

    return recommended.isEmpty ? getLatestJobs() : recommended;
  }

  @override
  Future<Job?> getJob(String id) async {
    try {
      return _jobs.firstWhere((job) => job.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Company?> getCompany(String id) async {
    try {
      return _companies.firstWhere((company) => company.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Job>> getJobsByCompany(String companyId) async {
    return _jobs
        .where((job) => job.companyId == companyId)
        .toList();
  }
}
