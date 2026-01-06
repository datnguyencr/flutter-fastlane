import 'dart:convert';
import 'dart:io';

const releasesUrl =
    'https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json';

void main() async {
  final versions = await fetchStableVersions(minVersion: '3.32.0');

  if (versions.isEmpty) {
    print('No stable versions found >= 3.32.0');
    return;
  }

  for (final version in versions) {
    final batchContent = '''
@echo off
setlocal enabledelayedexpansion

REM --- Get current date in YYYYMMDD format ---
for /f "tokens=2-4 delims=/.- " %%a in ('date /t') do (
    set YYYY=%%c
    set MM=%%a
    set DD=%%b
)

REM --- Get current time in HHMMSSCC format ---
for /f "tokens=1 delims=." %%a in ("%time: =0%") do set T=%%a
set HH=%T:~0,2%
set MIN=%T:~3,2%
set SEC=%T:~6,2%
set MS=%T:~9,2%

REM --- Set Flutter version and Docker tag dynamically ---
set FLUTTER_BASE=$version
set FLUTTER_VER=%FLUTTER_BASE%.%YYYY%%MM%%DD%%HH%%MIN%%SEC%%MS%
set DOCKER_TAG=%FLUTTER_VER%

REM --- Update docker_config.json ---
>docker_config.json (
  echo {
  echo   "flutter_version": "%FLUTTER_BASE%",
  echo   "docker_tag": "%DOCKER_TAG%"
  echo }
)

echo -----------------------------
echo Processing Flutter version %FLUTTER_VER%
echo Docker tag: %DOCKER_TAG%

REM --- Commit changes ---
git add docker_config.json
git commit -m "Release %DOCKER_TAG%"
git push

REM --- Create and push Git tag ---
git tag -a v%DOCKER_TAG% -m "Release %DOCKER_TAG%"
git push origin v%DOCKER_TAG%

echo Done! Tag v%DOCKER_TAG% pushed.
''';

    final batFile = File('release-$version.bat');
    batFile.writeAsStringSync(batchContent);
    print('release-$version.bat generated');
  }
}

Future<List<String>> fetchStableVersions({required String minVersion}) async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(releasesUrl));
  final response = await request.close();

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch Flutter releases');
  }

  final body = await response.transform(utf8.decoder).join();
  final data = jsonDecode(body) as Map<String, dynamic>;
  final releases = data['releases'] as List<dynamic>;

  final minParts = parseVersion(minVersion);

  final versions = releases
      .where((r) => r['channel'] == 'stable')
      .map((r) => r['version'] as String)
      .where((v) => compareVersions(v, minParts) >= 0)
      .toSet() // remove duplicates
      .toList();

  versions.sort(compareVersionStringsDesc);
  return versions;
}

/// Safely parse versions like:
///  - 3.32.0
///  - v1.22.6
List<int> parseVersion(String version) {
  final clean = version.trim().replaceFirst(RegExp(r'^v'), '');
  return clean
      .split('.')
      .map((p) => int.tryParse(p) ?? 0)
      .toList();
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
