import 'dart:convert';


import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'one_screen.dart';

class TwoScreen extends StatelessWidget {
  TwoScreen({super.key});

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        children: [
          PageView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSettingsContent(context),
              OneScreen(),
            ],
          ),
          OneScreen(),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double cardWidth = screenWidth > 500 ? 420 : screenWidth * 0.92;
    final double cardHeight = screenHeight * 0.11;
    final double smallCardHeight = screenHeight * 0.085;
    final double spacing = screenHeight * 0.018;
    final double titleFont = screenWidth > 500 ? 38 : 28;
    final double buttonFont = screenWidth > 500 ? 24 : 18;
    final double iconSize = screenWidth > 500 ? 36 : 28;

    Widget buildButton({required Widget child, required VoidCallback? onTap}) {
      return Container(
        height: cardHeight,
        width: cardWidth,
        margin: EdgeInsets.only(bottom: spacing),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Center(child: child),
          ),
        ),
      );
    }

    Widget buildButtonContent() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_download_outlined, size: iconSize, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'Сохранить прогресс',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: buttonFont,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    Widget buildSmallButton(String text) {
      return Container(
        height: smallCardHeight,
        width: cardWidth,
        margin: EdgeInsets.only(bottom: spacing),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: buttonFont,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: spacing + 8),
                Text(
                  'Настройки',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFont),
                ),
                SizedBox(height: spacing + 5),
                buildButton(
                  child: buildButtonContent(),
                  onTap: () => _showSaveOptionsBottomSheet(context),
                ),
                buildButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_download_sharp, size: iconSize, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Загрузить прогресс',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: buttonFont,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  onTap: _loadProgressFromGoogleDrive,
                ),
                buildSmallButton('Политика конфиденциальности'),
                buildSmallButton('Правила пользования'),
                buildSmallButton('О приложении'),
                SizedBox(height: spacing * 2),
                SizedBox(height: spacing),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSaveOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Wrap(
            runSpacing: 16,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12), 
              Icon(Icons.cloud_download_outlined, size: 48, ),
              Text(
                'Cохранить прогресс',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.folder_copy_outlined, size: 28, color: Colors.white),
                label: const Text ( 'В телефон', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.pop(context);
                  _saveProgressToLocal(context);
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.disc_full_outlined, size: 28, color: Colors.white),
                label: const Text('Сохранить в Google Диск', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.pop(context);
                  _saveProgressToGoogleDrive();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProgressToLocal(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final progressData = jsonEncode({
      'userName': 'YourUserName',
      'userLastName': 'YourUserLastName',
      'secondsSpent': 3600,
      'goalMinutes': 30,
      'dailyTimes': [0, 0, 0, 0, 0, 0, 0],
    });

    await prefs.setString('progressData', progressData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Прогресс сохранён локально')),
    );
  }

  Future<void> _saveProgressToGoogleDrive() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final authHeaders = await googleUser.authHeaders;
    final authenticateClient = authenticatedClient(
      Client(),
      AccessCredentials(
        AccessToken(
          authHeaders['type']!,
          authHeaders['access_token']!,
          DateTime.now().add(const Duration(hours: 1)),
        ),
        null,
        ['https://www.googleapis.com/auth/drive.file'],
      ),
    );

    final driveApi = drive.DriveApi(authenticateClient);

    final progressData = jsonEncode({
      'userName': 'YourUserName',
      'userLastName': 'YourUserLastName',
      'secondsSpent': 3600,
      'goalMinutes': 30,
      'dailyTimes': [0, 0, 0, 0, 0, 0, 0],
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
    if (googleUser == null) return;

    final authHeaders = await googleUser.authHeaders;
    final authenticateClient = authenticatedClient(
      Client(),
      AccessCredentials(
        AccessToken(
          authHeaders['type']!,
          authHeaders['access_token']!,
          DateTime.now().add(const Duration(hours: 1)),
        ),
        null,
        ['https://www.googleapis.com/auth/drive.file'],
      ),
    );

    final driveApi = drive.DriveApi(authenticateClient);

    final fileList = await driveApi.files.list(q: "name='progress.json'");
    if (fileList.files == null || fileList.files!.isEmpty) return;

    final progressFile = fileList.files!.first;
    final media = await driveApi.files.get(progressFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia);
    final progressData = await (media as drive.Media).stream.transform(utf8.decoder).join();

    final Map<String, dynamic> progressMap = jsonDecode(progressData);

    print(progressMap);
  }
}
