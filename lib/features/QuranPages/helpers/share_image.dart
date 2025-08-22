
import 'dart:typed_data';

import 'package:azkark/features/QuranPages/helpers/save_image.dart';
import 'package:share_plus/share_plus.dart';

void shareImage(Uint8List capturedImage) async {
  try {
    final tempImageFile = await saveImageToTempDirectory(capturedImage);

    await SharePlus.instance.share(
      ShareParams(
        files:  [XFile(tempImageFile.path)],
        // mimeTypes: ['image/png'],
      ),

      // text: '',
      // subject: 'Image Subject',
       // Adjust mime type as needed
      // filenames: ['temp_image.png'], // Adjust the filename as needed
    );

    // Optionally, delete the temporary file after sharing
    await tempImageFile.delete();
  } catch (e) {
    print('Error sharing image: $e');
  }
}
