# google_mlkit_text_recognition mereferensikan recognizer bahasa lain
# (Cina, Jepang, Korea, Devanagari) yang tidak dipakai/di-include app ini
# (cuma pakai recognizer Latin bawaan). R8 tetap mendeteksi referensinya
# lewat TextRecognizer.initialize() sehingga build release gagal minify
# kalau kelas-kelas ini tidak diberi tahu boleh diabaikan.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
