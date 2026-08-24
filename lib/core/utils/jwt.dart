import 'dart:convert';

/// Decodes a JWT's payload (second segment) without verifying its signature.
///
/// Client-side only — never a substitute for server-side authorization.
/// Used purely to read claims (e.g. `role`) for UX decisions, since the
/// backend never rejects a login by role. Returns `null` if [token] isn't a
/// well-formed JWT.
Map<String, dynamic>? decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    var payload = parts[1];
    payload += '=' * ((4 - payload.length % 4) % 4);
    final decoded = utf8.decode(base64Url.decode(payload));
    final json = jsonDecode(decoded);
    return json is Map<String, dynamic> ? json : null;
  } catch (_) {
    return null;
  }
}
