import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_settings/app_settings.dart' as AppSettingsOpen;
import 'package:uuid/uuid.dart';

typedef ImageSelectCallback = void Function(File image);

void main() {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  //Вся магия просиходит здесь: при выборе видео
  Future<void> _showVideoSelector(
    ImageSource imageSource,
    ImageSelectCallback onVideoSelected,
    BuildContext context,
  ) async {
    Navigator.of(context).pop();
    File file;
    File newFile;
    try {
      //Забираем файл из файловой системы
      file = await ImagePicker.pickVideo(
        source: imageSource,
      );

      // Берем путь до директории приложения, куда будет временно помещён
      //новый обработанный файл
      final directory = await getApplicationDocumentsDirectory();
      String random = Uuid().v1();
      newFile = File("${directory.path}/$random.mp4");

      //Обработка видео происходит с помощью команды, которую подаём библиотеке ffmpeg
      // -i : input file
      //-vf : frames
      // -b : bit rate файла.
      //bit rate для разных разрешений экранов:
      // * LD 240p 350 kbps
      // * LD 360p 700 kbps
      // * SD 480p 1200 kbps
      // * HD 720p 2500 kbps
      // * HD 1080p 5000 kbps
      await _flutterFFmpeg
          .execute("-i ${file.path} -vf scale=720:-1 -b 2500k ${newFile.path}")
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      //Можно сравнить размер файлов, прибегнув к сравнению кол-ва байт в каждом из них:
      var fileSize = file.readAsBytesSync();
      var newFileSize = newFile.readAsBytesSync();
      print("${fileSize.length} - original video size in bytes");
      print("${newFileSize.length} - changed (new) video size in bytes");
    } catch (platformException) {
      PlatformException exception = platformException;
      if (exception.code == "photo_access_denied") {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text((imageSource == ImageSource.gallery)
                    ? "Для выбора видео необходимо дать разрешение на доступ к галерее."
                    : "Для того чтобы снять видео, необходимо дать разрешение на доступ к камере."),
                actions: <Widget>[
                  RaisedButton(
                    child: Text("Перейти"),
                    onPressed: () {
                      AppSettingsOpen.AppSettings.openAppSettings();
                      Navigator.of(context).pop();
                    },
                  ),
                  RaisedButton(
                    child: Text("Отмена"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            });
      }
    }
    if (newFile != null) {
      //TODO: возвращаем наш обработанный файл здесь. Далее отправляем запрос на сервер вместе с ним.
      onVideoSelected(newFile);
    }
    return;
  }

  AlertDialog _buildPickerAlertDialog(
    BuildContext context,
    ImageSelectCallback onFileSelected,
    String dialogTitle,
    String galleryButtonTitle,
    String cameraButtonTitle,
    bool galleryButtonEnabled,
    bool cameraButtonEnabled,
    bool isImagePick,
  ) {
    return AlertDialog(
      title: Text(dialogTitle),
      content: ButtonTheme.bar(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (galleryButtonEnabled)
              FlatButton(
                child: Text(galleryButtonTitle),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isImagePick) {
                    // _showImageSelector(ImageSource.gallery, onFileSelected);
                  } else {
                    _showVideoSelector(
                        ImageSource.gallery, onFileSelected, context);
                  }
                },
              ),
            if (cameraButtonEnabled)
              FlatButton(
                child: Text(cameraButtonTitle),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isImagePick) {
                    // _showImageSelector(ImageSource.camera, onFileSelected);
                  } else {
                    _showVideoSelector(
                        ImageSource.camera, onFileSelected, context);
                  }
                },
              ),
            FlatButton(
              child: Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void showVideoPickerDialog(
    BuildContext context,
    ImageSelectCallback onVideoSelected, {
    String dialogTitle = "Выберите видео",
    String cameraButtonTitle = "Записать видео",
    String galleryButtonTitle = "Загрузить из галереи",
    bool galleryButtonEnabled = true,
    bool cameraButtonEnabled = true,
  }) {
    bool isImagePick = false;
    var alertDialogImageSelect = _buildPickerAlertDialog(
      context,
      onVideoSelected,
      dialogTitle,
      galleryButtonTitle,
      cameraButtonTitle,
      galleryButtonEnabled,
      cameraButtonEnabled,
      isImagePick,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialogImageSelect;
      },
    );
  }
}
