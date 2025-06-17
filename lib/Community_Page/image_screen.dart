import 'dart:async';
import 'dart:ui';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/post_interest.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_code_stakeplot/Community_Page/success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class ImageScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;
  final Map<String, dynamic> userInfo;

  const ImageScreen({
    Key? key,
    required this.onPostCreated,
    required this.userInfo,
  }) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final CustomImageCropController _cropController = CustomImageCropController();
  File? selectedImage;
    // New state variable for crop shape
 bool _selectedCropShape = true;
  final CommunityScreenStrings strings = CommunityScreenStrings();
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      snackBarAllFeilds2(context, SnackbarData().pickingError);
    }
  }

  Future<File?> _cropAndSaveImage() async {
    try {
      if (selectedImage == null) {
        return null;
      }

      final croppedImage = await _cropController.onCropImage();
      if (croppedImage == null) {
        return null;
      }

      final byteData = await _imageProviderToByteData(croppedImage);
      if (byteData == null) {
        return null;
      }

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
        title: Text(
          strings.postCard,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.bg1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
            height: MediaQuery.of(context).viewInsets.bottom > 0 
    ? MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - 180 // Adjust for keyboard
    : MediaQuery.of(context).size.height / 1.3,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2.8,
                          width: MediaQuery.of(context).size.width / 0.5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            // borderRadius: BorderRadius.circular(20),
                          ),
                          child: selectedImage != null
                              ? CustomImageCrop(
                                  image: FileImage(selectedImage!),
                                  cropController: _cropController,
                                  shape: CustomCropShape.Square,
                                  // ratio: Ratio(width: 402, height: 214),
                                    ratio: _selectedCropShape
                                      ?  Ratio(width: 402, height: 400)
                                      :  Ratio(width: 402, height: 214),
                                  outlineStrokeWidth: 0.0,
                                  //  ratio: Ratio(16, 9),
                                  // forceInsideCropArea:true,

                                  overlayColor: Colors.black.withOpacity(0.5),
                                  cropPercentage: 0.92, // Increased crop size
                                  // Increased crop size
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: AppColors.bg1,
                                    ),
                                    Text(
                                      "Upload Image",
                                      style: FontManager().getTextStyle(
                                        context,
                                        lWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppColors.bg1,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                        // Crop shape selection UI
                      if (selectedImage != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCropShape = true;
                                });
                              },
                              child: AvatarProfileImage(
                                                url: FinSpaceIcons.square,
                                                width: 20,
                                                height: 20,
                                                // background: userAvatarBackGround.value ?? defaultBackGround.value,
                                               
                                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCropShape = false;
                                });
                              },
                              child: AvatarProfileImage(
                                                url: FinSpaceIcons.custom,
                                                width: 20,
                                                height: 20,
                                                // background: userAvatarBackGround.value ?? defaultBackGround.value,
                                               
                                              ),
                            ),
                            
                            // ChoiceChip(
                            //   label: Text(
                            //     'Square',
                            //     style: FontManager().getTextStyle(
                            //       context,
                            //       lWeight: _selectedCropShape 
                            //           ? FontWeight.bold
                            //           : FontWeight.normal,
                            //       fontSize: 14,
                            //       color: AppColors.bg1,
                            //     ),
                            //   ),
                            //   selected: _selectedCropShape ,
                            //   onSelected: (selected) {
                            //     if (selected) {
                            //       setState(() {
                            //         _selectedCropShape = true;
                            //       });
                            //     }
                            //   },
                            //   selectedColor: AppColors.primaryColor,
                            //   backgroundColor: AppColors.textBgColor,
                            // ),
                            // const SizedBox(width: 10),
                            // ChoiceChip(
                            //   label: Text(
                            //     'Custom (402:214)',
                            //     style: FontManager().getTextStyle(
                            //       context,
                            //       lWeight: !_selectedCropShape
                            //           ? FontWeight.bold
                            //           : FontWeight.normal,
                            //       fontSize: 14,
                            //       color: AppColors.bg1,
                            //     ),
                            //   ),
                            //   selected: !_selectedCropShape,
                            //   onSelected: (selected) {
                            //     if (selected) {
                            //       setState(() {
                            //         _selectedCropShape = false;
                            //       });
                            //     }
                            //   },
                            //   selectedColor: AppColors.primaryColor,
                            //   backgroundColor: AppColors.textBgColor,
                            // ),
                          
                          ],
                        ),
                      
                      ],
                      const SizedBox(height: 10),
                      TextField(
                        controller: textController,
                        // focusNode: _contentFocusNode,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: strings.addThoughts,
                          filled: true,
                          fillColor: AppColors.textBgColor,
                          border: InputBorder.none,
                          hintStyle: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal,
                              fontSize: 14,
                              color: AppColors.bg1),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16.0 : 0,
                top: MediaQuery.of(context).viewInsets.bottom > 0 ? 16.0 : 16.0,
              ),
              child: GestureDetector(
                onTap: () async {
                  if (selectedImage == null) {
                    snackBarAllFeilds2(context, "Please select an image");
                    return;
                  }
                  if (textController.text.trim().isEmpty) {
                    snackBarAllFeilds2(context, "Please add your thoughts");
                    return;
                  }
                  showTagListOfInterestModal(
                      context: context, onConfirm: callBack);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  decoration: BoxDecoration(
                    color:
                        selectedImage != null && textController.text.isNotEmpty
                            ? AppColors.primaryColor
                            : AppColors.button,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Obx(() => posting.value
                        ? Spinner(size: 20, color: Colorcodes.white)
                        : Text(
                            strings.continueButton,
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.bold,
                              fontSize: 15,
                              color: selectedImage != null &&
                                      textController.text.isNotEmpty
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void callBack() async {
    if (selectedImage == null) {
      snackBarAllFeilds2(context, SnackbarData().uploadError);
      return;
    }

    if (textController.text.trim().isEmpty) {
      snackBarAllFeilds(context);
      return;
    }

    if (posting.value) return;

    try {
      posting.value = true;

      final croppedImageFile = await _cropAndSaveImage();
      if (croppedImageFile == null) {
        posting.value = false;
        return;
      }

      await createPost(
        context,
        titleController.text.toString().trim(),
        textController.text.toString().trim(),
        croppedImageFile,
         _selectedCropShape,
        
      );

      if (mounted) {
        Navigator.pop(context);
        Get.to(() => const SuccessPost(
              celebrationText: "Posted",
            ));
      }
    } catch (e) {
      // Log error instead of showing snackbar
    } finally {
      if (mounted) {
        posting.value = false;
      }
    }
  }
}
