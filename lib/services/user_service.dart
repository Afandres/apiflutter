import 'dart:convert';
import 'dart:io';

import 'package:api/constant.dart';
import 'package:api/models/api_response.dart';
import 'package:api/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(loginURL),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password});

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = 'Algo salió mal';
        break;
    }
  } catch (e) {
    apiResponse.error = 'Error del servidor';
  }

  return apiResponse;
}

Future<ApiResponse> register(String name, String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(registerURL), headers: {
      'Accept': 'application/json'
    }, body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      default:
        apiResponse.error = 'Algo salió mal';
        break;
    }
  } catch (e) {
    apiResponse.error = 'Error del servidor';
  }
  return apiResponse;
}

Future<ApiResponse<User>> getUserDetail() async {
  ApiResponse<User> apiResponse = ApiResponse<User>();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(userURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    switch (response.statusCode) {
      case 200:
        var responseData = jsonDecode(response.body);
        print('Response Data: $responseData');
        if (responseData.containsKey('user')) {
          User user = User.fromJson(responseData['user']);
          apiResponse.data = user;
        } else {
          apiResponse.error = 'Respuesta de la API inválida';
        }
        break;
      case 401:
        apiResponse.error = 'Error de autenticación: Unauthorized';
        break;
      default:
        apiResponse.error =
            'Error en la respuesta del servidor: ${response.statusCode}';
        break;
    }
  } catch (e) {
    print(e);
    apiResponse.error = 'Error de conexión o del servidor: $e';
  }
  return apiResponse;
}

Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}

Future<ApiResponse> updateUser(String name, String? image) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(Uri.parse(userURL),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: image == null
            ? {
                'name': name,
              }
            : {'name': name, 'image': image});

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = 'No autorizado';
        break;
      default:
        print(response.body);
        apiResponse.error = 'Algo salió mal';
        break;
    }
  } catch (e) {
    apiResponse.error = 'Error del servidor';
  }
  return apiResponse;
}

Future<int> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('userId') ?? 0;
}

Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.remove('token');
}

String? getStringImage(File? file) {
  if (file == null) return null;
  return base64Encode(file.readAsBytesSync());
}
