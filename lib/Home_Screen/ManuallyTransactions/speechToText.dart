
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
 final stt.SpeechToText speech = stt.SpeechToText();
  
  bool isProcessing = false;
  String recognizedText = '';
  int retryCount = 0;
  late AnimationController micAnimationController;
  late Animation<double> micAnimation;
 
class SpeechToTextService {
  bool isListening = false;
  final BuildContext context;
  final Map<String, List<String>> categories;
  final List<Map<String, dynamic>> customCategoryList;
  final bool isDebit;
  final Function(double, String, String?) onSpeechProcessed;
  final TickerProvider tickerProvider;

  SpeechToTextService({
    required this.context,
    required this.categories,
    required this.customCategoryList,
    required this.isDebit,
    required this.onSpeechProcessed,
    required this.tickerProvider,
  }) {
    micAnimationController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    micAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: micAnimationController, curve: Curves.easeInOut),
    );
    checkInitialPermissions();
  }

  Future<void> checkInitialPermissions() async {
    var status = await Permission.microphone.status;
    if (status.isPermanentlyDenied) {
      snackBarCalledfail(
        context,
        'Microphone permission denied. Please enable it in settings.',
        Colors.red,
      );
    }
  }

  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      snackBarCalledfail(
        context,
        'Microphone permission denied. Please enable it in settings.',
        Colors.red,
      );
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  Future<void> startListening() async {
    if (isProcessing) return;
    bool hasPermission = await requestMicrophonePermission();
    if (!hasPermission) return;

    bool available = await speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening = false;
          micAnimationController.stop();
        }
      },
      onError: (error) {
        isListening = false;
        isProcessing = false;
        micAnimationController.stop();
        snackBarCalledfail(
          context,
          'Speech recognition failed: ${error.errorMsg}',
          Colors.red,
        );
      },
    );

    if (available) {
      isListening = true;
      isProcessing = true;
      recognizedText = '';
      micAnimationController.repeat(reverse: true);
      showListeningModal();
      speech.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          if (result.finalResult) {
            isListening = false;
            micAnimationController.stop();
            processSpokenText(recognizedText);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
    } else {
      isListening = false;
      isProcessing = false;
      snackBarCalledfail(
        context,
        'Speech recognition not available. Ensure Google Speech Services are installed.',
        Colors.red,
      );
    }
  }

  void stopListening() {
    speech.stop();
    isListening = false;
    isProcessing = false;
    micAnimationController.stop();
  }

  void showListeningModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.mt,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FocusScope(
                node: FocusScopeNode(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedOpacity(
                      opacity: isListening ? 1.0 : 0.7,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isListening ? 'Speak Now' : 'Processing...',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w700,
                          fontSize: 20,
                          color: AppColors.accentColor,
                        ),
                        semanticsLabel: isListening ? 'Speak now' : 'Processing',
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening
                            ? Colors.green.withOpacity(0.1)
                            : Colors.yellow.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: isListening
                                ? Colors.green.withOpacity(0.3)
                                : Colors.yellow.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!isListening)
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.yellow),
                              strokeWidth: 4,
                              backgroundColor: Colors.grey,
                            ),
                          ScaleTransition(
                            scale: isListening
                                ? micAnimation
                                : const AlwaysStoppedAnimation(1.0),
                            child: Icon(
                              Icons.mic,
                              size: 56,
                              color: isListening ? Colors.green : Colors.yellow,
                              semanticLabel: 'Microphone',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedOpacity(
                      opacity: recognizedText.isEmpty ? 0.7 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        recognizedText.isEmpty
                            ? 'Say amount and category (e.g., "500 Zomato")'
                            : 'Heard: $recognizedText',
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 16,
                          color: AppColors.accentColor.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                        semanticsLabel: recognizedText.isEmpty
                            ? 'Say amount and category'
                            : 'Heard: $recognizedText',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: isListening ? 1.0 : 0.7,
                          duration: const Duration(milliseconds: 300),
                          child: TextButton(
                            focusNode: FocusNode(),
                            onPressed: () {
                              stopListening();
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              backgroundColor: Colors.red.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: FontManager().getTextStyle(
                                context,
                                fontSize: 14,
                                color: Colors.red,
                                lWeight: FontWeight.w600,
                              ),
                              semanticsLabel: 'Cancel speech input',
                            ),
                          ),
                        ),
                        if (!isListening) ...[
                          const SizedBox(width: 16),
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: TextButton(
                              focusNode: FocusNode(),
                              onPressed: () {
                                Navigator.pop(context);
                                startListening();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                backgroundColor:
                                    AppColors.primaryColor.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: FontManager().getTextStyle(
                                  context,
                                  fontSize: 14,
                                  color: AppColors.primaryColor,
                                  lWeight: FontWeight.w600,
                                ),
                                semanticsLabel: 'Retry speech input',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int levenshteinDistance(String a, String b) {
    final List<List<int>> matrix = List.generate(
      a.length + 1,
      (_) => List<int>.filled(b.length + 1, 0),
    );

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return matrix[a.length][b.length];
  }

  double calculateSimilarity(String a, String b) {
    int distance = levenshteinDistance(a.toLowerCase(), b.toLowerCase());
    int maxLength = a.length > b.length ? a.length : b.length;
    return (1 - distance / maxLength) * 100;
  }

  void processSpokenText(String text) async {
    Navigator.pop(context);
    if (text.isEmpty) {
      snackBarCalledfail(context, 'No speech detected', Colors.red);
      isProcessing = false;
      return;
    }

    String normalizedText =
        text.toLowerCase().replaceAll(RegExp(r'^(add|spend|paid|for|to|on|in|and) '), '').trim();
    List<String> parts = normalizedText.split(RegExp(r'\s+'));

    double? parsedAmount;
    String? spokenCategory;
    String? spokenSubCategory;

    String numberPart = '';
    for (String part in parts) {
      double? number = double.tryParse(part.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (number != null && number > 0) {
        parsedAmount = number;
        continue;
      }
      numberPart += part + ' ';
    }

    if (parsedAmount == null) {
      Map<String, double> numberWords = {
        'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
        'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
        'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15,
        'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 'nineteen': 19,
        'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50, 'sixty': 60,
        'seventy': 70, 'eighty': 80, 'ninety': 90,
        'hundred': 100, 'thousand': 1000
      };
      double tempAmount = 0;
      double multiplier = 1;
      List<String> numberTokens = numberPart.trim().split(' ');
      for (int i = 0; i < numberTokens.length; i++) {
        String word = numberTokens[i];
        if (numberWords.containsKey(word)) {
          if (word == 'hundred' || word == 'thousand') {
            multiplier = numberWords[word]!;
          } else {
            double value = numberWords[word]!;
            if (i + 1 < numberTokens.length && numberTokens[i + 1] == 'hundred') {
              tempAmount += value * 100;
              i++;
            } else if (i + 1 < numberTokens.length && numberTokens[i + 1] == 'thousand') {
              tempAmount += value * 1000;
              i++;
            } else {
              tempAmount += value * multiplier;
              multiplier = 1;
            }
          }
        }
      }
      if (tempAmount > 0) parsedAmount = tempAmount;
    }

    List<String> potentialWords = [];
    for (int i = 0; i < parts.length; i++) {
      potentialWords.add(parts[i]);
      if (i < parts.length - 1) {
        potentialWords.add('${parts[i]} ${parts[i + 1]}');
      }
      if (i < parts.length - 2) {
        potentialWords.add('${parts[i]} ${parts[i + 1]} ${parts[i + 2]}');
      }
    }

    double maxSimilarity = 0;
    for (String word in potentialWords) {
      categories.forEach((category, subCategories) {
        for (String sub in subCategories) {
          double similarity = calculateSimilarity(word, sub);
          if (similarity >= 80 && similarity > maxSimilarity) {
            maxSimilarity = similarity;
            spokenCategory = category;
            spokenSubCategory = sub;
          } else if (word.toLowerCase() == sub.toLowerCase()) {
            spokenCategory = category;
            spokenSubCategory = sub;
            maxSimilarity = 100;
          }
        }
      });
    }

    if (spokenCategory == null) {
      maxSimilarity = 0;
      for (String word in potentialWords) {
        for (String cat in categories.keys) {
          double similarity = calculateSimilarity(word, cat);
          if (similarity >= 80 && similarity > maxSimilarity) {
            maxSimilarity = similarity;
            spokenCategory = cat;
            spokenSubCategory = 'Other';
          } else if (word.toLowerCase() == cat.toLowerCase()) {
            spokenCategory = cat;
            spokenSubCategory = 'Other';
            maxSimilarity = 100;
          }
        }
      }
    }

    if (spokenCategory == null) {
      maxSimilarity = 0;
      for (String word in potentialWords) {
        for (var customCat in customCategoryList) {
          String name = customCat['name'].toString();
          double similarity = calculateSimilarity(word, name);
          if (similarity >= 80 && similarity > maxSimilarity) {
            maxSimilarity = similarity;
            spokenCategory = name;
            spokenSubCategory = '';
          } else if (word.toLowerCase() == name.toLowerCase()) {
            spokenCategory = name;
            spokenSubCategory = '';
            maxSimilarity = 100;
          }
        }
      }
    }

    if (parsedAmount == null) {
      snackBarCalledfail(context, 'Invalid or missing amount. Please try again.', Colors.red);
      isProcessing = false;
      return;
    }

    if (spokenCategory == null) {
      snackBarCalledfail(context, 'Category or subcategory not recognized. Please try again.', Colors.red);
      isProcessing = false;
      return;
    }

    if (!isDebit && spokenCategory != 'Income') {
      snackBarCalledfail(context, 'Only Income category allowed for Cash In', Colors.red);
      isProcessing = false;
      return;
    }

    onSpeechProcessed(parsedAmount, spokenCategory??'', spokenSubCategory);
    isProcessing = false;
  }

  void dispose() {
    micAnimationController.dispose();
    speech.stop();
  }
}




