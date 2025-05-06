import 'dart:convert';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

import 'one_screen.dart';

class TwoScreen extends StatelessWidget {
   TwoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical, // Свайп вверх-вниз
        children: [
          PageView(
            scrollDirection: Axis.horizontal, // Свайп влево-вправо
            children: [
              _buildSettingsContent(context),
              OneScreen(), // Переход на экран OneScreen при свайпе вправо
            ],
          ),
          OneScreen(), // Переход на экран OneScreen при свайпе вверх
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            'Настройки',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
          ),
          SizedBox(height: 25),
          Container(
            height: 90,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.cloud_download_outlined,
                  size: 40,
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: _saveProgressToGoogleDrive,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      'Сохранить прогресс',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 90,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.cloud_download_sharp,
                  size: 40,
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: _loadProgressFromGoogleDrive,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      'Загрузить прогресс',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 70,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Text(
                    'Политика конфиденциальности',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 70,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Text(
                    'Правила пользования',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 70,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Text(
                    'О приложении',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 65),
          Text(
            'Сохранить',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.blue),
          ),
          SizedBox(height: 20),
          Text(
            'Отменить',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  Future<void> _saveProgressToGoogleDrive() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User canceled the sign-in
      return;
    }

    final authHeaders = await googleUser.authHeaders;
    final authenticateClient = authenticatedClient(
      Client(),
      AccessCredentials(
        AccessToken(
          authHeaders['type']!,
          authHeaders['access_token']!,
          DateTime.now().add(Duration(hours: 1)),
        ),
        null,
        ['https://www.googleapis.com/auth/drive.file'],
      ),
    );

    final driveApi = drive.DriveApi(authenticateClient);

    // Assuming progressData is the data you want to save
    final progressData = jsonEncode({
      'userName': 'YourUserName', // Replace with actual data
      'userLastName': 'YourUserLastName', // Replace with actual data
      'secondsSpent': 3600, // Replace with actual data
      'goalMinutes': 30, // Replace with actual data
      'dailyTimes': [0, 0, 0, 0, 0, 0, 0], // Replace with actual data
    });

    final media = drive.Media(
      Stream.value(utf8.encode(progressData)),
      progressData.length,
    );

    final driveFile = drive.File();
    driveFile.name = 'progress.json';

    await driveApi.files.create(driveFile, uploadMedia: media);
  }

  Future<void> _loadProgressFromGoogleDrive() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User canceled the sign-in
      return;
    }

    final authHeaders = await googleUser.authHeaders;
    final authenticateClient = authenticatedClient(
      Client(),
      AccessCredentials(
        AccessToken(
          authHeaders['type']!,
          authHeaders['access_token']!,
          DateTime.now().add(Duration(hours: 1)),
        ),
        null,
        ['https://www.googleapis.com/auth/drive.file'],
      ),
    );

    final driveApi = drive.DriveApi(authenticateClient);

    final fileList = await driveApi.files.list(q: "name='progress.json'");
    if (fileList.files == null || fileList.files!.isEmpty) {
      // No progress file found
      return;
    }

    final progressFile = fileList.files!.first;
    final media = await driveApi.files.get(progressFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia);
    final progressData = await (media as drive.Media).stream.transform(utf8.decoder).join();

    final Map<String, dynamic> progressMap = jsonDecode(progressData);

    // Update your state with the loaded progress data
    print(progressMap);
  }
}