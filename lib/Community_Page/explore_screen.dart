import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postLoadFeed.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/post_interest.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:image_picker/image_picker.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'dart:io';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../routes/route_user_login.dart';
import '../routes/route_post.dart';

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
 bool? _isSquare;
  @override
  void initState() {
    super.initState();
    _textControllers.add(TextEditingController());
    _amountControllers.add(TextEditingController());
  }

  Future<void> _pickAndCropImage() async {
    if (selectedImages.length >= maxImages) {
      snackBarCalledfail(context, SnackbarData().maxFiveImagesAllowed);
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
   bool localIsSquare = _isSquare ?? true; 
     bool showCropSelection = _isSquare == null;
    final croppedFile = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => LayoutBuilder(
          builder: (context, constraints) {
            double dialogWidth = constraints.maxWidth * 0.9;
            double dialogHeight = constraints.maxHeight * 0.5;
            double buttonWidth = constraints.maxWidth * 0.5;

            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: dialogWidth,
                    height: dialogHeight,
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomImageCrop(
                        cropController: cropController,
                        image: FileImage(imageFile),
                        shape: CustomCropShape.Square,
                        ratio: localIsSquare
                            ? Ratio(width: 1, height: 1) // Square
                            : Ratio(width: 402, height: 214),
                        outlineStrokeWidth: 0.0,
                        //  ratio: Ratio(16, 9),
                        // forceInsideCropArea:true,

                        overlayColor: AppColors.accentColor.withOpacity(0.5),
                        cropPercentage: 0.92, //
                      ),
                    ),
                  ),
                   if (showCropSelection)
                      Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child:Row(
                      children:[
                        GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                localIsSquare = true;
                              });
                              },
                              child: AvatarProfileImage(
                                                url: FinSpaceIcons.square,
                                                width: 20,
                                                height: 20,
                                               
                                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  localIsSquare = false;
                                });
                              },
                              child: AvatarProfileImage(
                                                url: FinSpaceIcons.custom,
                                                width: 20,
                                                height: 20,
                                               
                                              ),
                            ),
                      ]

                    ),
                   
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     ChoiceChip(
                    //       label: Text(
                    //         'Square',
                    //         style: FontManager().getTextStyle(
                    //           context,
                    //           lWeight: localIsSquare == 'true'
                    //               ? FontWeight.bold
                    //               : FontWeight.normal,
                    //           fontSize: 14,
                    //           color: AppColors.bg1,
                    //         ),
                    //       ),
                    //       selected: localIsSquare == 'true',
                    //       onSelected: (selected) {
                    //         if (selected) {
                    //           setDialogState(() {
                    //             localIsSquare = true;
                    //           });
                    //         }
                    //       },
                    //       selectedColor: AppColors.primaryColor,
                    //       backgroundColor: AppColors.textBgColor,
                    //     ),
                    //     const SizedBox(width: 10),
                    //     ChoiceChip(
                    //       label: Text(
                    //         'Custom (402:214)',
                    //         style: FontManager().getTextStyle(
                    //           context,
                    //           lWeight: localIsSquare == 'false'
                    //               ? FontWeight.bold
                    //               : FontWeight.normal,
                    //           fontSize: 14,
                    //           color: AppColors.bg1,
                    //         ),
                    //       ),
                    //       selected: localIsSquare == 'false',
                    //       onSelected: (selected) {
                    //         if (selected) {
                    //           setDialogState(() {
                    //             localIsSquare = false;
                    //           });
                    //         }
                    //       },
                    //       selectedColor: AppColors.primaryColor,
                    //       backgroundColor: AppColors.textBgColor,
                    //     ),
                    //   ],
                    // ),
                  
                  ),
                ],
              ),
              // Crop shape selection

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
                        child: Text(strings.cancelButton,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: 12,
                                color: AppColors.backgroundColor)),
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
                                  // Navigator.pop(context, croppedFile);
                                  Navigator.pop(context, {
                                    'file': croppedFile,
                                    'isSquare': localIsSquare,
                                  });
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
                              : AppColors.finSpaceColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isLoading
                            ?  SizedBox(
                                width: 20,
                                height: 20,
                                child: Spinner()
                              )
                            : Text(strings.saveButton,
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: AppColors.backgroundColor)),
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

    // if (croppedFile != null) {
    //   setState(() {
    //     if (existingIndex != null) {
    //       selectedImages[existingIndex] = croppedFile;
    //     } else {
    //       selectedImages.add(croppedFile);
    //       _cropControllers.add(cropController);
    //     }
    //   });
    // }
   if (croppedFile != null) {
      setState(() {
        if (existingIndex != null) {
          selectedImages[existingIndex] = croppedFile['file'];
        } else {
          selectedImages.add(croppedFile['file']);
          _cropControllers.add(cropController);
          _isSquare = croppedFile['isSquare']; // Set crop shape for all images
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
      final tempDir = await getExternalStorageDirectory();
      final file = await File(
              '${tempDir!.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png')
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
      if (selectedImages.isEmpty) {
        _isSquare = null; // Reset crop shape if no images remain
      }
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
      final tempDir = await getExternalStorageDirectory();
      final file = await File(
              '${tempDir!.path}/cropped_${DateTime.now().millisecondsSinceEpoch}_$index.png')
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

 

  Future<void> _submitPost() async {
    if (locationNameController.text.isEmpty ||
        locationAddressController.text.isEmpty) {
      snackBarCalledfail(context, SnackbarData().fillAllRequiredFields);
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
        snackBarCalledfail(context, SnackbarData().errorUploadingImage);
        setState(() => _isSubmitting = false);
        return;
      }
    }
    final TagList = [...selectedSubCategories, ...selectedCategories];
    Map<String, dynamic> requestBody = {
      "images": imageUrls,
      "name": locationNameController.text,
      "location": locationAddressController.text,
      "budget": budget,
      "rating": _rating,
      "tripHighlights": titleController.text,
      "description": contentController.text,
      "postType": "exploria",
      "tags": TagList,
      "isSquareImage": _isSquare ?? true,
    };


    try {
     
      final response = await postDataApiCall(PostRoutes.post,requestBody
      );


      if (getFlagOfResponse(response)) {
        setState(() {
          exploreSubmitted = true;
          _isSubmitting = false;
        });
        var postData = jsonDecode(response.body);

        // Update local state
         postController.feedPostList.insert(0, PostModel.fromJson(postData));
         postController.getPosted.value = ! postController.getPosted.value;
         postController.postCount[postData["_id"]] = 0;
         postController.postCommentCount[postData["_id"]] = 0;
         postController.posting.value = false;
         postController.postDis.value = false;
        widget.onPostCreated(jsonDecode(response.body));
        Navigator.pop(context);
      } else {
        snackBarCalledfail(context, SnackbarData().failedToSubmitPost);
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      snackBarCalledfail(context, SnackbarData().errorSubmittingPost);
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.bg1,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        title: _buildHeader(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            color: AppColors.backgroundColor,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                lWeight: FontWeight.bold, fontSize: 18, color: AppColors.backgroundColor)),
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
              color: AppColors.backgroundColor,
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
            starColor: AppColors.finSpaceColor,
            starOffColor: AppColors.button,
            valueLabelVisibility: false,
            valueLabelTextStyle: const TextStyle(color: AppColors.backgroundColor),
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
          strings.photosLabel
              .replaceFirst('{count}', selectedImages.length.toString()),
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.backgroundColor,
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
                                  color: AppColors.backgroundColor,
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
              backgroundColor: AppColors.finSpaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo, color: AppColors.backgroundColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  strings.addPhoto,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: AppColors.backgroundColor,
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
        Text(strings.aboutPlace,
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 16, color: AppColors.accentColor)),
        const SizedBox(height: 10),
        TextField(
          controller: locationNameController,
          decoration: _inputDecoration(strings.locationName, Icons.place),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: locationAddressController,
          decoration:
              _inputDecoration(strings.locationAddress, Icons.location_pin),
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
                    color: AppColors.accentColor)),
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
                    decoration: _inputDecoration(
                        strings.addCategory, Icons.description),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountControllers[index],
                    keyboardType: TextInputType.number,
                    inputFormatters: allowDecimalInput(),
                    decoration: _inputDecoration(
                        strings.addBudget, Icons.currency_rupee),
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
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.normal,
            fontSize: 16,
            color: AppColors.accentColor,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: titleController,
           maxLines: null,
          decoration: _inputDecoration(strings.enterTitle, null), // Updated
        ),
        const SizedBox(height: 10),
        TextField(
          controller: contentController,
          decoration: _inputDecoration(strings.addThoughts, null), // Updated
          maxLines: null,
          maxLength: null,
        ),
      ],
    );
  }

  void callBack() async {
    final isEnabled = locationNameController.text.isNotEmpty &&
        locationAddressController.text.isNotEmpty  &&
        !_isSubmitting;

    isEnabled ? _submitPost() : null;
  }

  Widget _buildSubmitButton() {
    final bool isEnabled = locationNameController.text.isNotEmpty &&
      locationAddressController.text.isNotEmpty &&
      titleController.text.isNotEmpty &&
      contentController.text.isNotEmpty &&
      selectedImages.isNotEmpty && // At least one image
      _isSubmitting == false &&
      // Check if at least one budget entry is valid (optional, adjust as needed)
      _textControllers.asMap().entries.any((entry) {
        int index = entry.key;
        return _textControllers[index].text.isNotEmpty &&
            _amountControllers[index].text.isNotEmpty;
      });

    return GestureDetector(
      onTap: () {
         isEnabled?showTagListOfInterestModal(context: context, onConfirm: callBack):null;
      },
      child: _isSubmitting
          ? Center(child: Spinner())
          : Container(
              width: MediaQuery.of(context).size.width / 1.1,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                  color: isEnabled ? AppColors.finSpaceColor : Colors.grey,
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
                        ? AppColors.backgroundColor
                        : AppColors.accentColor,
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
          lWeight: FontWeight.normal, fontSize: 16, color: AppColors.accentColor),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      prefixIcon: icon != null ? Icon(icon) : null,
    );
  }
}
