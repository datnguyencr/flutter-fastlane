import 'dart:convert';
import 'dart:io';

const releasesUrl = 'https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json';

void main(List<String> args) async {
  final minVersion = args.isNotEmpty ? args[0] : '3.32.0';
  
  try {
    final latestVersion = await fetchLatestStableVersion(minVersion: minVersion);
    if (latestVersion == null) {
      print('No new stable version found.');
      exit(0);
    }

    final currentTags = await getGitTags();
    final tagExists = currentTags.any((tag) => tag.contains(latestVersion));

    if (!tagExists) {
      print('NEW_VERSION=$latestVersion');
    } else {
      print('Already released.');
    }
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

Future<String?> fetchLatestStableVersion({required String minVersion}) async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(releasesUrl));
  final response = await request.close();

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch Flutter releases: ${response.statusCode}');
  }

  final body = await response.transform(utf8.decoder).join();
  final data = jsonDecode(body) as Map<String, dynamic>;
  final releases = data['releases'] as List<dynamic>;

  final minParts = parseVersion(minVersion);

  final stableReleases = releases
      .where((r) => r['channel'] == 'stable')
      .map((r) => r['version'] as String)
      .where((v) => compareVersions(v, minParts) >= 0)
      .toList();

  if (stableReleases.isEmpty) return null;

  stableReleases.sort(compareVersionStringsDesc);
  return stableReleases.first;
}

Future<List<String>> getGitTags() async {
  final result = await Process.run('git', ['tag']);
  if (result.exitCode != 0) return [];
  return (result.stdout as String).split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}

List<int> parseVersion(String version) {
  final clean = version.trim().replaceFirst(RegExp(r'^v'), '');
  return clean.split('.').map((p) => int.tryParse(p) ?? 0).toList();
}

int compareVersions(String v, List<int> minParts) {
  final parts = parseVersion(v);
  for (var i = 0; i < minParts.length; i++) {
    final a = i < parts.length ? parts[i] : 0;
    final b = minParts[i];
    if (a != b) return a.compareTo(b);
  }
  return 0;
}

int compareVersionStringsDesc(String a, String b) {
  final pa = parseVersion(a);
  final pb = parseVersion(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return y.compareTo(x);
  }
  return 0;
}
