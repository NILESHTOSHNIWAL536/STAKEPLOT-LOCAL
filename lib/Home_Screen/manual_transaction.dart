import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/apicalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:speech_to_text/speech_to_text.dart' as stt;

bool isDebit = true;


class ModalContent extends StatefulWidget {
  final bool isDebit;
  const ModalContent(this.isDebit, {Key? key}) : super(key: key);

  @override
  _ModalContentState createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> with TickerProviderStateMixin {
  String? selectedCategory;
  String? selectedSubCategory;
  final TextEditingController _amountController = TextEditingController();
  double? amount;
  String? fin;
  final TextEditingController categoryFieldController = TextEditingController();
  bool isCategoryFieldExpanded = false;
  final TextEditingController searchController = TextEditingController();
  List<String> filteredCategories = [];
  late ConfettiController _confettiController;
  late AnimationController _iconAnimationController;
  bool _isCelebrationVisible = false;
  String? selectedCategory2;
  String? selectedSubCategory2;
  // List  addedUser=[];
  // List addedMembers=[];
  bool _isAmountFieldFocused = true;
  late IO.Socket socket;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  late AnimationController _micAnimationController;
  late Animation<double> _micAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    getAllTransaction(context);
    getCategoryData();
    filteredCategories = categories.keys.toList();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _micAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _micAnimationController, curve: Curves.easeInOut),
    );
    socket = IO.io(urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    var status = await Permission.microphone.status;
    if (status.isPermanentlyDenied) {
      snackBarCalled(
          context,
          'Microphone permission denied. Please enable it in settings.',
          Colors.red);
    }
  }

  // Request microphone permission
  Future<bool> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      snackBarCalled(
          context,
          'Microphone permission denied. Please enable it in settings.',
          Colors.red);
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  // Start speech recognition
  Future<void> _startListening() async {
    if (_isProcessing) return;
    bool hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) return;

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
          _micAnimationController.stop();
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
          _isProcessing = false;
          _micAnimationController.stop();
        });
        snackBarCalled(context, 'Speech recognition failed: ${error.errorMsg}',
            Colors.red);
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _isProcessing = true;
        _recognizedText = '';
        _micAnimationController.repeat(reverse: true);
      });
      _showListeningModal();
      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
              _micAnimationController.stop();
              _processSpokenText(_recognizedText);
            }
          });
        },
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 3),
      );
    } else {
      setState(() {
        _isListening = false;
        _isProcessing = false;
      });
      snackBarCalled(
          context,
          'Speech recognition not available. Ensure Google Speech Services are installed.',
          Colors.red);
    }
  }

  // Stop listening
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _isProcessing = false;
      _micAnimationController.stop();
    });
  }

  // Show listening modal
  void _showListeningModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.mt,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FocusScope(
              node: FocusScopeNode(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isListening ? 'Speak now' : 'Processing...',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold, fontSize: 18, color: AppColors.accentColor),
                    semanticsLabel: _isListening ? 'Speak now' : 'Processing',
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!_isListening)
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                          strokeWidth: 3,
                        ),
                      ScaleTransition(
                        scale: _micAnimation,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening ? Colors.green.withOpacity(0.2) : Colors.yellow.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.mic,
                            size: 48,
                            color: _isListening ? Colors.green : Colors.yellow,
                            semanticLabel: 'Microphone',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _recognizedText.isEmpty
                        ? 'Say amount and category (e.g., "500 Zomato", "Zomato 500")'
                        : 'Heard: $_recognizedText',
                    style: FontManager().getTextStyle(context, fontSize: 16, color: AppColors.accentColor),
                    textAlign: TextAlign.center,
                    semanticsLabel: _recognizedText.isEmpty
                        ? 'Say amount and category'
                        : 'Heard: $_recognizedText',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        focusNode: FocusNode(),
                        onPressed: () {
                          _stopListening();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: FontManager().getTextStyle(context, fontSize: 14, color: Colors.red),
                          semanticsLabel: 'Cancel speech input',
                        ),
                      ),
                      if (!_isListening)
                        TextButton(
                          focusNode: FocusNode(),
                          onPressed: () {
                            Navigator.pop(context);
                            _startListening();
                          },
                          child: Text(
                            'Retry',
                            style: FontManager().getTextStyle(context, fontSize: 14, color: AppColors.primaryColor),
                            semanticsLabel: 'Retry speech input',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  // Process spoken text
 void _processSpokenText(String text) async {
    Navigator.pop(context); // Close listening modal
    if (text.isEmpty) {
      snackBarCalled(context, 'No speech detected', Colors.red);
      _isProcessing = false;
      return;
    }

    // Normalize text and tokenize
    String normalizedText = text.toLowerCase().replaceAll(RegExp(r'^(add|spend|paid|for|to|on|in|and) '), '').trim();
    List<String> parts = normalizedText.split(RegExp(r'\s+'));

    double? parsedAmount;
    String? spokenCategory;
    String? spokenSubCategory;

    // Parse amount
    String numberPart = '';
    for (String part in parts) {
      double? number = double.tryParse(part.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (number != null && number > 0) {
        parsedAmount = number;
        continue;
      }
      numberPart += part + ' ';
    }

    // Parse spoken numbers
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

    // Parse category/subcategory with multi-word support
    List<String> potentialWords = [];
    for (int i = 0; i < parts.length; i++) {
      potentialWords.add(parts[i]);
      if (i < parts.length - 1) {
        potentialWords.add('${parts[i]} ${parts[i + 1]}'); // Two-word phrases
      }
      if (i < parts.length - 2) {
        potentialWords.add('${parts[i]} ${parts[i + 1]} ${parts[i + 2]}'); // Three-word phrases
      }
    }

    // Check for subcategory first (most specific)
    for (String word in potentialWords) {
      categories.forEach((category, subCategories) {
        if (subCategories.any((sub) => sub.toLowerCase() == word)) {
          if (spokenCategory == null) { // Take first valid match
            spokenCategory = category;
            spokenSubCategory = subCategories.firstWhere((sub) => sub.toLowerCase() == word);
          }
        }
      });
    }

    // Then check categories
    if (spokenCategory == null) {
      for (String word in potentialWords) {
        String? foundCategory = categories.keys.firstWhere(
          (cat) => cat.toLowerCase() == word,
          orElse: () => '',
        );
        if (foundCategory.isNotEmpty) {
          spokenCategory = foundCategory;
          spokenSubCategory = 'Other';
          break; // Take first valid category
        }
      }
    }

    // Then check custom categories
    if (spokenCategory == null) {
      for (String word in potentialWords) {
        var customCat = customCategoryList.firstWhere(
          (cat) => cat['name'].toString().toLowerCase() == word,
          orElse: () => {},
        );
        if (customCat.isNotEmpty) {
          spokenCategory = customCat['name'];
          spokenSubCategory = '';
          break; // Take first valid custom category
        }
      }
    }

    if (parsedAmount == null) {
      snackBarCalled(context, 'Invalid or missing amount. Please try again.', Colors.red);
      _isProcessing = false;
      return;
    }

    if (spokenCategory == null) {
      snackBarCalled(context, 'Category or subcategory not recognized. Please try again.', Colors.red);
      _isProcessing = false;
      return;
    }

     if (!widget.isDebit && spokenCategory != 'Income') {
      snackBarCalled(context, 'Only Income category allowed for Cash In', Colors.red);
      _isProcessing = false;
      return;
    }

    setState(() {
      amount = parsedAmount;
      _amountController.text = parsedAmount.toString();
      selectedCategory = spokenCategory;
      selectedSubCategory = spokenSubCategory ?? '';
      selectedCategory2 = selectedCategory;
      selectedSubCategory2 = selectedSubCategory;
      fin = '$selectedCategory (${selectedSubCategory?.isEmpty ==true? 'None' : selectedSubCategory})';
      _isAmountFieldFocused = false;
      isCategoryFieldExpanded = false;
    });

    _showConfirmationDialog(parsedAmount, spokenCategory??'', spokenSubCategory);
  }

  // Show confirmation dialog
  void _showConfirmationDialog(
      double amount, String category, String? subCategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.mt,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Confirm Transaction',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.accentColor),
          ),
          content: Text(
            'Add ₹$amount to $category (${subCategory?.isEmpty == true ? 'None' : subCategory})?',
            style: FontManager().getTextStyle(context,
                fontSize: 16, color: AppColors.accentColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isProcessing = false);
              },
              child: Text(
                'No',
                style: FontManager()
                    .getTextStyle(context, fontSize: 14, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addTransactionAutomatically();
              },
              child: Text(
                'Yes',
                style: FontManager().getTextStyle(context,
                    fontSize: 14, color: AppColors.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add transaction
  void _addTransactionAutomatically() async {
    if (cashInAndOut.value) return;
    cashInAndOut.value = true;

    try {
      addTransaction(
        amount.toString(),
        selectedSubCategory2 ?? '',
        selectedCategory2!,
        context,
        "cash",
      );
      // snackBarCalled(context, SnackbarData()., Colors.black);
      Navigator.pop(context); // Close modal
    } catch (error) {
      snackBarCalled(context, 'Failed to add transaction: $error', Colors.red);
    } finally {
      cashInAndOut.value = false;
      _isProcessing = false;
    }
  }

  setUpSocketListener() {
    socket.on(
        "disconnect",
        (data) => {
              socket.close(),
            });
  }

  void dispose() {
    _confettiController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        // Show all categories when search is cleared
        filteredCategories = categories.keys.toList();
      } else {
        // Filter categories by search query
        filteredCategories = categories.keys
            .where((category) =>
                category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void resetToInitialScreen() {
    setState(() {
      selectedCategory = null;
      selectedSubCategory = null;
      isCategoryFieldExpanded = false;
      _isAmountFieldFocused = false;
    });
  }

  void toggleCategoryField() {
    setState(() {
      isCategoryFieldExpanded = !isCategoryFieldExpanded;
      _isAmountFieldFocused = false;
      _isAmountFieldFocused = false;
    });
  }

  void _showCelebration() {

    setState(() {
      _isCelebrationVisible = true;
    });
    _confettiController.play(); // Start confetti animation
    _iconAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isCelebrationVisible
            ? celebration()
            : AnimatedPadding(
                padding: MediaQuery.of(context).viewInsets,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Container(
                  color: AppColors.mt,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedSubCategory == null
                              ? selectedCategory == null
                                  ? HomepageStringsDart().manualTransaction
                                  : ''
                              : HomepageStringsDart().manualTransactions,
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.accentColor),
                        ),
                        const SizedBox(height: 16),
                        if ((selectedCategory == null &&
                                selectedSubCategory == null) ||
                            !widget.isDebit) ...[
                          Row(
                            children: [
                              Expanded(child: AmountWidget()),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: AppColors.primaryColor,
                                ),
                                onPressed: _isListening
                                    ? _stopListening
                                    : _startListening,
                                tooltip: 'Speech to Text',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (amount != null) ...[
                          categoryWidget(),
                        ],
                        const SizedBox(height: 8),
                        if (isCategoryFieldExpanded) ...[
                          categoryExpandedWidget(),
                          // getListOfCustomCategory(),
                        ],
                        if (selectedCategory != null &&
                            selectedSubCategory == null) ...[
                          Text('$selectedCategory',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: AppColors.accentColor)),
                          SizedBox(height: 5),
                          subcategoryWidget(),
                        ],
                        if (fin != null) ...[
                          widget.isDebit
                              ? SplitLendButton()
                              : SizedBox.shrink(),
                          continueButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget celebration() {
    return Stack(alignment: Alignment.center, children: [
      // Confetti blast effect
      ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality:
            BlastDirectionality.explosive, // Blast in all directions
        numberOfParticles: 50, // Number of confetti pieces
        colors: const [Colors.green, Colors.blue, Colors.orange, Colors.pink],
        gravity: 0.3, // Confetti falls slowly
      ),
      // Animated tick mark
      ScaleTransition(
        scale: CurvedAnimation(
          parent: _iconAnimationController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1.1,
          height: Colorcodes.paddingSize * 10,
          color: AppColors.backgroundColor,
          child: Column(
            key: const ValueKey('celebration'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                HomepageStringsDart().successfullyAdded,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget AmountWidget() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      autofocus: _isAmountFieldFocused,
      inputFormatters: allowDecimalInput(),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.currency_rupee),
        hintText: HomepageStringsDart().enterAmount,
        fillColor: AppColors.button,
        filled: true,
        hintStyle: FontManager().getTextStyle(context,
            lWeight: FontWeight.normal,
            fontSize: 16,
            color: AppColors.accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentColor, // Default border color
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentColor
              // When not focused

              ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentColor, // Color when focused
            // Slightly thicker when focused for emphasis
          ),
        ),
      ),
      onChanged: (value) {
        setState(() {
          // Update the amount variable whenever the input changes
          amount = double.tryParse(value);
          if (!isDebit) {
            selectedCategory = "Income";
            categoryFieldController.text = "Income";
          }
          fin = null;
          _isAmountFieldFocused = false; // Convert string to double
        });
      },
      onEditingComplete: () {
        fin = '$selectedCategory ($selectedSubCategory)';
        FocusScope.of(context).unfocus(); // Dismiss keyboard when done
      },
    );
  }

  Widget categoryWidget() {
    return GestureDetector(
      onTap: toggleCategoryField,
      child: TextField(
        controller: categoryFieldController,
        readOnly: !isDebit,
        decoration: InputDecoration(
          hintText: HomepageStringsDart().selectCategory,
          fillColor: AppColors.button,
          filled: true,
          hintStyle: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: 16,
              color: AppColors.accentColor),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.accentColor, // When not focused
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.accentColor, // Color when focused
              // Slightly thicker when focused for emphasis
            ),
          ),
        ),
        onTap: () {
          if (!isCategoryFieldExpanded) {
            if (isDebit)
              toggleCategoryField();
            else {
              setState(() {
                selectedCategory = "Income";
                selectedSubCategory = null;
                categoryFieldController.text = "Income";
              });
            }
          }
        },
        onChanged: (value) {
          filterCategories(value); // Filter categories as the user types
        },
      ),
    );
  }

  Widget categoryExpandedWidget() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredCategories.length + customCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          bool f = (index >= filteredCategories.length);
          String category = f
              ? customCategoryList[index - filteredCategories.length]['name']
              : filteredCategories[index];
          String urlPath = "";

          if (!f) {
            try {
              urlPath = Categories.link +
                  BudgetCategories.listofCategories[
                      BudgetCategories.listofCategories.keys.elementAt(index)];
            } catch (e) {}
          } else {
            urlPath = customCategoryList[index - filteredCategories.length]
                ['imageUrl'];
          }

          return ListTile(
            //leading: const Icon(Icons.category),

            leading: Container(
              height: 40,
              width: 40,
              child: AvatarProfileImage(
                url: urlPath,
                width: 4,
                height: 4,
              ),
            ),
            title: Text(category,
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: AppColors.accentColor)),
            onTap: () {
              setState(() {
                if (f) {
                  selectedCategory = category;
                  selectedSubCategory = "";
                  isCategoryFieldExpanded = false;
                  _isAmountFieldFocused = false;
                  categoryFieldController.text = '$selectedCategory';
                  // isSplitbill = true; // Uncomment if needed
                  fin = '$selectedCategory ($selectedSubCategory)';
                  selectedCategory2 = selectedCategory;
                  _isAmountFieldFocused = false; // Prevent amount field refocus
                  FocusScope.of(context).unfocus();
                  resetToInitialScreen();
                } else {
                  selectedCategory = category;
                  categoryFieldController.text = category; // Update text field
                  isCategoryFieldExpanded = false;
                  _isAmountFieldFocused = false; // Prevent amount field refocus
                  FocusScope.of(context).unfocus(); // Collapse the list
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget getListOfCustomCategory() {
    return Expanded(
      child: ListView.builder(
        itemCount: customCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          final category = customCategoryList[index];
          final categoryName = category['name'] ?? '';
          final imageUrl = category['imageUrl'] ?? '';

          return ListTile(
            leading: Container(
              height: 40,
              width: 40,
              child: AvatarProfileImage(
                url: imageUrl,
                width: 4,
                height: 4,
              ),
            ),
            title: Text(
              categoryName,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.normal,
                fontSize: 16,
                color: AppColors.accentColor,
              ),
            ),
            onTap: () {
              setState(() {
                selectedCategory = categoryName;
                categoryFieldController.text = categoryName;
                isCategoryFieldExpanded = false;
                _isAmountFieldFocused = false;
                FocusScope.of(context).unfocus();
              });
            },
          );
        },
      ),
    );
  }

  Widget subcategoryWidget() {
    return Wrap(
      spacing: 4.0, // Horizontal spacing between chips
      runSpacing: 2.0, // Vertical spacing between rows
      children: categories[selectedCategory]!.map((subCategory) {
        // Get the URL path for the subcategory's icon from BudgetSubCategories
        String urlPath = BudgetSubCategories.listofSubCategories[subCategory] ??
            "assets/icons/subCategoryIcons/default.svg";

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedSubCategory = subCategory;
              selectedSubCategory2 = subCategory;
              categoryFieldController.text =
                  '$selectedCategory ($selectedSubCategory)';
              // isSplitbill = true; // Uncomment if needed
              fin = '$selectedCategory ($selectedSubCategory)';
              selectedCategory2 = selectedCategory;
              _isAmountFieldFocused = false; // Prevent amount field refocus
              FocusScope.of(context).unfocus();
              resetToInitialScreen();
            });
          },
          child: Chip(
            avatar: ProfileImage(
              url: urlPath,
            ),
            label: Text(
              toUpperCase(subCategory),
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.normal,
                fontSize: 14,
                color: AppColors.accentColor,
              ),
            ),
            backgroundColor: AppColors.button,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget SplitLendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
            if (isLend.value) {
              addedUser.clear();
              addedMembers.clear();
            }
            isSplit.value = true;
            isLend.value = false;

            final result =
                await showCustomFriendsModal(context, amount ?? 0.0, false);
            if (result != null && addedMembers.isNotEmpty) {
              splitUserAmountManualTransaction(
                context,
                amount.toString(),
                addedMembers,
                selectedCategory2.toString(),
                selectedSubCategory2.toString(),
                amounts: result as Map<String, double>,
              );
            }
            setState(() {
              _isAmountFieldFocused = false; // Prevent amount field refocus
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.button,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                HomepageStringsDart().billSplit,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
            if (isSplit.value) {
              addedUser.clear();
              addedMembers.clear();
            }
            isSplit.value = false;
            isLend.value = true;

            await showCustomFriendsModal(context, amount ?? 0.0, true);
            setState(() {
              _isAmountFieldFocused = false; // Prevent amount field refocus
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.button,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                HomepageStringsDart().lendMoney,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget continueButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Button to trigger celebration
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (cashInAndOut.value) return;
                cashInAndOut.value = true;
                if (isSplit.value && addedMembers.isNotEmpty) {
                  splitBill(selectedCategory2.toString(), amount.toString(),selectedSubCategory2.toString(), true);
                } else if (isLend.value && addedMembers.isNotEmpty) {
                  addLendUserAmount(
                    context,
                    amount.toString(),
                    addedMembers,
                    selectedCategory2.toString(),
                    selectedSubCategory2.toString(),
                  );
                } else {
                  addTransaction(
                    amount.toString(),
                    selectedSubCategory2.toString(),
                    selectedCategory2.toString(),
                    context,
                    "cash",
                  );
                }
              },
              child: Obx(() => cashInAndOut.value
                  ? getspinner(context)
                  : getButton(context, HomepageStringsDart().addButton)),
            ),
          ),
        ),
      ],
    );
  }

  void splitBill(categories, amount, subCategories, bool isSplitAmount) {
    if (categories == "" || amount == "" || subCategories == "") {
      snackBarAllFeilds(context);
      return;
    }

    if (acceptReset.value) return;
    acceptReset.value = true;
    isLend.value = false;
    isSplit.value = false;

    splitUserAmountManualTransaction(context, amount, addedMembers, categories, subCategories);
  }

  void addSocketMessage(addedUser, String amount, String splitName,
      String splitID, double parsedTotalAmount) {
    if (addedUser.isEmpty) {
      return;
    }

    // int index=0;
    addedUser.forEach((rec) {
      String room1 = rec['name'] + userName.value;
      String room2 = userName.value + rec['name'];
      String roomId = (room1.compareTo(room2) <= 0) ? room1 : room2;

      var jsonData = {
        "messageType": "split",
        "receiver": rec['id'],
        "sender": currentId.value,
        "message": null,
        "image": null,
        "poll": null,
        "post": null,
        "split": {
          "BillName": splitName,
          "Amount": parsedTotalAmount, // This is now the individual amount
          "Share": amount,
          "isPaid": false,
          "splitId": splitID,
        },
        "roomId": roomId,
      };

      socket.emit("joinRoom", roomId);
      socket.emit("message", jsonData);
      String userToSend = rec['name'] + "" + rec['name'];
      socket.emit("LoadCharts", {
        "roomId": userToSend,
      });
    });
  }

  Future<dynamic> showCustomFriendsModal(
    BuildContext context,
    double totalAmount,
    bool isLendMode,
  ) async {
    return await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return NewFriendsUi(
          totalAmount: totalAmount,
          userId: currentId.value,
          userName: userName.value,
          userAvatar: avatar.value,
          isLendMode: isLendMode,
        );
      },
    );
  }

  void splitUserAmountManualTransaction(
    BuildContext context,
    String totalAmount,
    List members,
    String name,
    String subCategories, {
    Map<String, double>? amounts,
  }) async {
    double? parsedTotalAmount = double.tryParse(totalAmount);
    if (parsedTotalAmount == null || parsedTotalAmount <= 0) {
      snackBarCalled(context, SnackbarData().invalidAmountEntered, Colors.red);
      return;
    }

    if (members.isEmpty) {
      snackBarCalled(context, SnackbarData().noMembersSelected, Colors.red);
      return;
    }

    List<Map<String, dynamic>> nameList = [];
    if (amounts != null) {
      members.forEach((element) {
        double memberAmount = amounts[element['id']] ?? 0.0;
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': memberAmount,
        });
      });
    } else {
      double amountPerPerson = parsedTotalAmount / (members.length + 1);
      members.forEach((element) {
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': amountPerPerson,
        });
      });
      nameList.add({
        'member': currentId.value,
        'markAsComplete': false,
        'amount': amountPerPerson,
      });
    }

    double calculatedTotal =
        nameList.fold(0.0, (sum, item) => sum + item['amount']);

    var response = await postDataApiCall(
      '${url}/split',
      {
        "subcategory": subCategories,
        "category": name,
        "amount": calculatedTotal,
        "paymentStatus": nameList,
        "image": '',
        "ismanual": true,
      },
    );

    if (getFlagOfResponse(response)) {
      final body = json.decode(response.body);
      splitID.value = body['id']['_id'];
      for (var member in members) {
        double memberAmount = amounts?[member['id']] ??
            (parsedTotalAmount / (members.length + 1));
        String formattedAmount = memberAmount.toStringAsFixed(2);

        sendNotificationsToDevice(
            member['id'],
            context,
            "${userName.value} has sent you a Split Bill of $name for ₹$formattedAmount",
            "/chat");
      }

      if (amounts != null) {
        members.forEach((member) {
          double memberAmount = amounts[member['id']] ?? 0.0;
          addSocketMessage([member], memberAmount.toString(), name,
              splitID.value, parsedTotalAmount);
        });
      } else {
        double amountPerPerson = parsedTotalAmount / (members.length + 1);
        addSocketMessage(members, amountPerPerson.toString(), name,
            splitID.value, parsedTotalAmount);
      }
      currentPage = 1;
      isLoadingMore.value = false;
      searchController.clear();
      getAllTransaction(context);

      snackBarCalled(context, SnackbarData().splitAmountSuccess, Colors.black);
      Navigator.pop(context);
      addedMembers.clear();
      addedUser.clear();
      _showCelebration();
    } else {
      snackBarCalled(context, SnackbarData().splitAmountError, Colors.red);
    }

    acceptReset.value = false;
    cashInAndOut.value = false;
  }
}
