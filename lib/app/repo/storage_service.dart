import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(
    Object imageSource, {
    String contentType = 'image/jpeg',
  }) async {
    try {
      final Uint8List imageBytes = imageSource is Uint8List
          ? imageSource
          : await (imageSource as dynamic).readAsBytes() as Uint8List;

      Reference ref = _storage
          .ref()
          .child('uploads/${DateTime.now().millisecondsSinceEpoch}.png');

      final SettableMetadata metadata = SettableMetadata(
        contentType: contentType,
      );

      UploadTask uploadTask = ref.putData(imageBytes, metadata);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
