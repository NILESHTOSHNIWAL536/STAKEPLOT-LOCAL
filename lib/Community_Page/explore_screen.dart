import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postLoad.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:image_picker/image_picker.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'dart:io';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ExploreModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;

  const ExploreModal({super.key, required this.onPostCreated});

  @override
  _ExploreModalState createState() => _ExploreModalState();
}

class _ExploreModalState extends State<ExploreModal> {
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController locationAddressController =
      TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = []; // Changed to List<File>
  static const int maxImages = 5;
  final List<CustomImageCropController> _cropControllers = [];
  double _rating = 0.0;
  bool _isSubmitting = false;

  final List<TextEditingController> _textControllers = [];
  final List<TextEditingController> _amountControllers = [];
  bool exploreSubmitted = false;
 final CommunityScreenStrings strings = CommunityScreenStrings();
  @override
  void initState() {
    super.initState();
    _textControllers.add(TextEditingController());
    _amountControllers.add(TextEditingController());
  }

  Future<void> _pickAndCropImage() async {
    if (selectedImages.length >= maxImages) {
      snackBarCalled(context,SnackbarData().maxFiveImagesAllowed );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _showCropDialog(File(image.path));
    }
  }


  Future<void> _showCropDialog(File imageFile, [int? existingIndex]) async {
    final cropController = CustomImageCropController();
    bool isLoading = false; // Track loading state

    final croppedFile = await showDialog<File?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => LayoutBuilder(
          builder: (context, constraints) {
            double dialogWidth = constraints.maxWidth * 0.9;
            double dialogHeight = constraints.maxHeight * 0.5;
            double buttonWidth = constraints.maxWidth * 0.5;

            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: dialogWidth,
                height: dialogHeight,
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageCrop(
                    cropController: cropController,
                    image: FileImage(imageFile),
                    shape: CustomCropShape.Square,
                    overlayColor: Colors.black.withOpacity(0.3),
                    cropPercentage: 0.9,
                    outlineStrokeWidth: 0.0,
                  ),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel Button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: buttonWidth / 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text( strings.cancelButton,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Colors.white)),
                      ),
                    ),
                    // Save Button with Loader
                    InkWell(
                      onTap: isLoading
                          ? null // Disable tap when loading
                          : () async {
                              setDialogState(() {
                                isLoading = true; // Show loader
                              });
                              final croppedImage =
                                  await cropController.onCropImage();
                              if (croppedImage != null) {
                                final croppedFile =
                                    await _saveCroppedImage(croppedImage);
                                if (croppedFile != null) {
                                  Navigator.pop(context, croppedFile);
                                }
                              }
                              setDialogState(() {
                                isLoading = false; // Hide loader
                              });
                            },
                      child: Container(
                        width: buttonWidth / 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isLoading
                              ? Colors.grey[400]
                              : AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text( strings.saveButton,
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );

    if (croppedFile != null) {
      setState(() {
        if (existingIndex != null) {
          selectedImages[existingIndex] = croppedFile;
        } else {
          selectedImages.add(croppedFile);
          _cropControllers.add(cropController);
        }
      });
    }

    if (existingIndex == null) {
      cropController.dispose();
    }
  }

  Future<File?> _saveCroppedImage(ImageProvider imageProvider) async {
    try {
      final byteData = await _imageProviderToByteData(imageProvider);
      if (byteData == null) return null;

      final Uint8List bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File(
              '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png')
          .writeAsBytes(bytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
      _cropControllers[index].dispose();
      _cropControllers.removeAt(index);
    });
  }

  void _addTextFields() {
    setState(() {
      _textControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
    });
  }

  Future<File?> _cropAndSaveImage(int index) async {
    try {
      if (index >= selectedImages.length) return null;

      final croppedImage = await _cropControllers[index].onCropImage();
      if (croppedImage == null) return null;

      final byteData = await _imageProviderToByteData(croppedImage);
      if (byteData == null) return null;

      final Uint8List bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File(
              '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}_$index.png')
          .writeAsBytes(bytes);

      return file;
    } catch (e) {
      return null;
    }
  }

  Future<ByteData?> _imageProviderToByteData(
      ImageProvider imageProvider) async {
    final completer = Completer<ByteData?>();
    final ImageStream stream =
        imageProvider.resolve(const ImageConfiguration());

    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        final image = info.image;
        image.toByteData(format: ImageByteFormat.png).then((byteData) {
          completer.complete(byteData);
          stream.removeListener(listener!);
        });
      },
      onError: (exception, stackTrace) {
        completer.completeError(exception, stackTrace);
        stream.removeListener(listener!);
      },
    );

    stream.addListener(listener);
    return completer.future;
  }

  static Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("accessToken");
  }

  Future<void> _submitPost() async {
    if (locationNameController.text.isEmpty || locationAddressController.text.isEmpty) {
       snackBarCalled(context, SnackbarData().fillAllRequiredFields);
      return;
    }

    setState(() => _isSubmitting = true); // Show loading indicator

    List<Map<String, dynamic>> budget = [];
    for (int i = 0; i < _textControllers.length; i++) {
      if (_textControllers[i].text.isNotEmpty &&
          _amountControllers[i].text.isNotEmpty) {
        budget.add({
          "category": _textControllers[i].text,
          "amount": int.tryParse(_amountControllers[i].text) ?? 0,
        });
      }
    }

    // Upload all cropped images and get their URLs
    List<String> imageUrls = [];
    for (File image in selectedImages) {
      try {
        String url = await postImageToCloud(image, context);
        imageUrls.add(url);
      } catch (e) {
        snackBarCalled(context,SnackbarData().errorUploadingImage);
        setState(() => _isSubmitting = false);
        return;
      }
    }

    Map<String, dynamic> requestBody = {
      "pictures": imageUrls,
      "place": {
        "name": locationNameController.text,
        "location": locationAddressController.text,
      },
      "budget": budget,
      "rating": _rating,
      "tripHighlight": titleController.text,
      "description": contentController.text,
      "comments": 0,
      "shares": 0,
      "upvotes": 0,
    };

    var body = {
      'title': titleController.text,
      'description': {'message': requestBody},
      'image': imageUrls.isNotEmpty
          ? imageUrls[0]
          : '', // Use first image as main image
      'fileName': '',
      'type': 'explore'
    };

    try {
      var accessToken = await getToken();
      final response = await http.post(
        Uri.parse('$url/post/'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "$accessToken",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          exploreSubmitted = true;
          _isSubmitting = false;
        });
        var postData = jsonDecode(response.body);

        // Update local state
        getTrendingData.insert(0, postData);
        getPosted.value = !getPosted.value;
        postCount[postData["_id"]] = 0;
        postCommentCount[postData["_id"]] = 0;
        resetAndLoadData();
        posting.value = false;
        postDis.value = false;
        widget.onPostCreated(jsonDecode(response.body));
        Navigator.pop(context);
      } else {
        snackBarCalled(context,SnackbarData().failedToSubmitPost);
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      
      snackBarCalled(context,SnackbarData().errorSubmittingPost);
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    locationNameController.dispose();
    locationAddressController.dispose();
    titleController.dispose();
    contentController.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    for (var controller in _amountControllers) {
      controller.dispose();
    }
    for (var cropController in _cropControllers) {
      cropController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          color: AppColors.backgroundColor,
          child: AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildImageSection(),
                    const SizedBox(height: 10),
                    _buildPlaceSection(),
                    const SizedBox(height: 10),
                    _buildBudgetSection(),
                    _buildRatingSection(),
                    const SizedBox(height: 20),
                    _buildHighlightSection(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.explore_sharp, size: 24, color: AppColors.accentColor),
        const SizedBox(width: 8),
        Text(strings.exploria, 
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
      ],
    );
  }

  Widget _buildRatingSection() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align items vertically centered
        children: [
          Text(
             strings.rateThisPlace,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8), // Reduced spacing for better alignment
          RatingStars(
            value: _rating,
            onValueChanged: (value) {
              if (mounted) {
                setState(() => _rating = value);
              }
            },
            starCount: 5,
            starSize: 30,
            maxValue: 5,
            starSpacing: 2,
            starColor: AppColors.primaryColor,
            starOffColor: AppColors.button,
            valueLabelVisibility: false,
            valueLabelTextStyle: const TextStyle(color: Colors.black),
            starBuilder: (index, color) => Icon(
              Icons.star,
              color: color,
              size: 30,
            ),
          ),
        ],
      );

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
           strings.photosLabel.replaceFirst('{count}', selectedImages.length.toString()),
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: selectedImages.isEmpty
              ? Center(
                  child: Text(
                   strings.noImagesSelected,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _showCropDialog(selectedImages[index], index),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -8,
                            top: -8,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:
                selectedImages.length < maxImages ? _pickAndCropImage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                   strings.addPhoto,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text( strings.aboutPlace,
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 16, color: Colors.black)),
        const SizedBox(height: 10),
        TextField(
          controller: locationNameController,
          decoration: _inputDecoration(strings.locationName, Icons.place),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: locationAddressController,
         decoration: _inputDecoration(strings.locationAddress, Icons.location_pin),
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(strings.budgetLabel,
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.black)),
            IconButton(
              onPressed: _addTextFields,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        ...List.generate(_textControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textControllers[index],
                    decoration:
                        _inputDecoration(strings.addCategory, Icons.description),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountControllers[index],
                    keyboardType: TextInputType.number,
                    decoration:
                        _inputDecoration(strings.addBudget, Icons.currency_rupee),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

    Widget _buildHighlightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.tripHighlights, // Updated
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: 16,
              color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: titleController,
          decoration: _inputDecoration(strings.enterTitle, null), // Updated
        ),
        const SizedBox(height: 10),
        TextField(
          controller: contentController,
          decoration: _inputDecoration(strings.addThoughts, null), // Updated
          maxLines: 3,
          maxLength: 150,
        ),
      ],
    );
  }
 

  Widget _buildSubmitButton() {
    final isEnabled = locationNameController.text.isNotEmpty &&
        locationAddressController.text.isNotEmpty &&
        !_isSubmitting;

    return GestureDetector(
      onTap: () {
        isEnabled ? _submitPost() : null;
      },
      child: _isSubmitting
          ? Center(child: const CircularProgressIndicator(color: Colors.black))
          : Container(
              width: MediaQuery.of(context).size.width / 1.1,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                  color: isEnabled ? AppColors.primaryColor : Colors.grey,
                  borderRadius: BorderRadius.circular(24)),
              child: Center(
                child: Text(
                 strings.continueButton, 
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 15,
                    color: locationNameController.text.isNotEmpty &&
                            locationAddressController.text.isNotEmpty
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData? icon) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: FontManager().getTextStyle(context,
          lWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      prefixIcon: icon != null ? Icon(icon) : null,
    );
  }
}
