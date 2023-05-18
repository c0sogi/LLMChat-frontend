
import 'package:hive/hive.dart';

class AuthService {
  static const String _boxName = 'authBox';
  static const String _jwtKey = 'jwtToken';

  static Future<void> saveToken(String token) async {
    final box = await Hive.openBox<String>(_boxName);
    box.put(_jwtKey, token);
  }

  static Future<String?> getToken() async {
    final box = await Hive.openBox<String>(_boxName);
    return box.get(_jwtKey);
  }

  static Future<void> deleteToken() async {
    final box = await Hive.openBox<String>(_boxName);
    box.delete(_jwtKey);
  }
}

// import 'package:hive/hive.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:math';

// class AuthService {
//   static const String _boxName = 'authBox';
//   static const String _jwtKey = 'jwtToken';

//   Future<void> saveToken(String token) async {
//     final box = await Hive.openBox<String>(_boxName);
//     box.put(_jwtKey, token);
//   }

//   Future<String?> getToken() async {
//     final box = await Hive.openBox<String>(_boxName);
//     return box.get(_jwtKey);
//   }

//   Future<void> deleteToken() async {
//     final box = await Hive.openBox<String>(_boxName);
//     box.delete(_jwtKey);
//   }

//   Future<void> saveEmbedding(String text, List<double> embedding) async {
//     final box = await Hive.openBox<List<double>>('embeddingBox');
//     box.put(text, embedding);
//   }

//   Future<List<double>?> getEmbedding(String text) async {
//     final box = await Hive.openBox<List<double>>('embeddingBox');
//     return box.get(text);
//   }

//   Future<List<double>> requestEmbedding(String text) async {
//     String? token = await AuthService().getToken();

//     if (token == null) {
//       throw Exception("No JWT token found");
//     }

//     final response = await http.post(
//       Uri.parse('https://api.openai.com/v1/embeddings'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         'input': text,
//         'model': 'text-embedding-ada-002',
//       }),
//     );
//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
//       var embedding = data['data'][0]['embedding'].cast<double>();
//       return embedding;
//     } else {
//       throw Exception("Failed to request embedding");
//     }
//   }

//   double cosineSimilarity(List<double> a, List<double> b) {
//     var vectorA = Vector(a);
//     var vectorB = Vector(b);

//     var dotProduct = vectorA.dot(vectorB);
//     var magnitudeA = vectorA.magnitude();
//     var magnitudeB = vectorB.magnitude();

//     return dotProduct / (magnitudeA * magnitudeB);
//   }
// }

// class EmbeddingService {
//   static const String _boxName = 'embeddingBox';
//   static const String _baseUrl = 'https://api.openai.com/v1/embeddings';
//   static const String _model = 'text-embedding-ada-002';
//   static const String _jwtKey =
//       'jwtToken'; // Assuming you're using the same key for your JWT tokens

//   Future<void> saveEmbedding(String text) async {
//     final jwtToken = await _getJwtToken();
//     final embedding = await _getEmbeddingFromApi(text, jwtToken);

//     final box = await Hive.openBox<List<double>>(_boxName);
//     box.put(text, embedding);
//   }

//   Future<List<double>?> getEmbedding(String text) async {
//     final box = await Hive.openBox<List<double>>(_boxName);
//     return box.get(text);
//   }

//   Future<List<double>> _getEmbeddingFromApi(
//       String text, String jwtToken) async {
//     final response = await http.post(
//       Uri.parse(_baseUrl),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $jwtToken'
//       },
//       body: jsonEncode({'input': text, 'model': _model}),
//     );

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       return responseData['data'][0]['embedding'].cast<double>();
//     } else {
//       throw Exception('Failed to get embedding');
//     }
//   }

//   Future<String> _getJwtToken() async {
//     final box = await Hive.openBox<String>('authBox');
//     final jwtToken = box.get(_jwtKey);

//     if (jwtToken == null) {
//       throw Exception('JWT token not found');
//     }

//     return jwtToken;
//   }
// }


// // Future<void> main() async {
// //   var authService = AuthService();
// //   await authService.init();

// //   var text = 'Your text string goes here';
// //   var embedding = await requestEmbedding(text);
// //   await authService.saveEmbedding(text, embedding);

// //   var queryText = 'Your query string goes here';
// //   var queryEmbedding = await requestEmbedding(queryText);

// //   var texts = ['text1', 'text2', 'text3', ...];
// //   var similarities = <String, double>{};

// //   for (var text in texts) {
// //     var storedEmbedding = await authService.getEmbedding(text);

// //     if (storedEmbedding != null) {
// //       var similarity = cosineSimilarity(queryEmbedding, storedEmbedding);
// //       similarities[text] = similarity;
// //     }
// //   }

// //   var sortedTexts = similarities.entries.toList()
// //     ..sort((a, b) => b.value.compareTo(a.value));

// //   var topKTexts = sortedTexts.take(10).map((e) => e.key).toList();

// //   print(topKTexts);
// // }
