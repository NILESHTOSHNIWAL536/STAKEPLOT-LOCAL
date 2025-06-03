import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/post_interest.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finSpace/InterestSelectionScreen.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import './success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class TextScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;
  final Map<String, dynamic> userInfo;

  const TextScreen({
    Key? key,
    required this.onPostCreated,
    required this.userInfo,
  }) : super(key: key);

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  bool showImage = false;
  bool postSubmitted = false;
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  final CustomImageCropController _cropController = CustomImageCropController();
  double modalHeight = 300; // Initial height
  final ImagePicker _picker = ImagePicker();
  final CommunityScreenStrings strings = CommunityScreenStrings();

  @override
  void initState() {
    super.initState();
    titleController.addListener(_updateButtonState);
    contentController.addListener(_updateButtonState);
    _titleFocusNode.addListener(_adjustHeight);
    _contentFocusNode.addListener(_adjustHeight);
  }

  void _updateButtonState() {
    setState(() {});
  }

  void _adjustHeight() {
    setState(() {
      if (_titleFocusNode.hasFocus || _contentFocusNode.hasFocus) {
        // Adjust height based on keyboard presence
        modalHeight = showImage
            ? MediaQuery.of(context).size.height * 0.6 // With image and keyboard
            : MediaQuery.of(context).size.height * 0.36; // Without image, with keyboard
      } else {
        // Adjust height based on content (no keyboard)
        modalHeight = showImage
            ? 500 // Larger height for image when no keyboard
            : 300; // Default height without image or keyboard
      }
    });
  }

  @override
  void dispose() {
    titleController.removeListener(_updateButtonState);
    contentController.removeListener(_updateButtonState);
    _titleFocusNode.removeListener(_adjustHeight);
    _contentFocusNode.removeListener(_adjustHeight);
    titleController.dispose();
    contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      snackBarAllFeilds2(context,SnackbarData().pickingError);
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
    return Container(
      height: modalHeight + MediaQuery.of(context).viewInsets.bottom,
      // height: MediaQuery.of(context).size.height /1.1,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: postSubmitted
          ?SuccessPost(celebrationText: strings.postedSuccess)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            getProfile(),
                            // AvatarProfileImage(url: avatar.value, width: 20, height: 20),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName.value.toString(),
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: AppColors.bg1),
                                ),
                                Text(
                                  strings.newPost,
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: AppColors.bg1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            DecoratedContainer(
                              borderRadius: 10,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showImage = !showImage;
                                    _adjustHeight(); // Adjust height when toggling showImage
                                  });
                                },
                                icon: FaIcon(FontAwesomeIcons.images),
                              ),
                            ),
                            const Positioned(
                              top: 10,
                              right: 2,
                              child: Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      focusNode: _titleFocusNode,
                      decoration: InputDecoration(
                        hintText: strings.enterTitle,
                        hintStyle: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.bg1),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (showImage)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: selectedImage != null
                              ?  CustomImageCrop(
                              image: FileImage(selectedImage!),
                              cropController: _cropController,
                              shape: CustomCropShape.Square,
                             outlineStrokeWidth:0.0,
                           //  ratio: Ratio(16, 9),
                            // forceInsideCropArea:true,
                           
                              overlayColor: Colors.black.withOpacity(0.5),
                              cropPercentage: 0.92, // Increased crop size
                              // Increased crop size
                            )
                              : const Icon(Icons.add_photo_alternate,
                                  size: 50, color: Colors.grey),
                        ),
                      ),
                    if (showImage) const SizedBox(height: 10),
                    Flexible(
                      child: TextField(
                        controller: contentController,
                        focusNode: _contentFocusNode,
                        maxLines: null,
                        decoration: InputDecoration(
                           hintText: strings.addThoughts, 
                          border: InputBorder.none,
                          hintStyle: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal,
                              fontSize: 14,
                              color: AppColors.bg1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    GestureDetector(
                      onTap: () async {
                          showTagListOfInterestModal(context:  context,onConfirm: callBack);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        decoration: BoxDecoration(
                          color: titleController.text.isNotEmpty &&
                                  contentController.text.isNotEmpty
                              ? AppColors.primaryColor
                              : AppColors.button,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Obx(
                            () => posting.value
                                ? Spinner(size: 30, color: Colorcodes.white)
                                : Text(
                                    strings.continueButton,
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: titleController.text.isNotEmpty &&
                                              contentController.text.isNotEmpty
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }


  void callBack()async
  {
       if (contentController.text.isNotEmpty) {
                          if (showImage && selectedImage == null) {
                            snackBarAllFeilds2(context,SnackbarData().uploadError);
                            return;
                          }

                          if (posting.value) return;
                          posting.value = true;

                          if (titleController.text.trim().isEmpty ||
                              contentController.text.trim().isEmpty) {
                            snackBarAllFeilds(context);
                            posting.value = false;
                            return;
                          }

                          if (selectedImage != null && showImage) {
                             try {
                        posting.value = true;

                        final croppedImageFile = await _cropAndSaveImage();
                        if (croppedImageFile == null) {
                          posting.value = false;
                          return;
                        }

                        await createPost(
                          context,
                          titleController.text,
                          contentController.text,
                          croppedImageFile,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
              
                      } finally {
                        if (mounted) {
                          posting.value = false;
                        }
                      }
                            
                          } else {
                            createPostWithOutImage(
                                context, titleController.text, contentController.text);
                                Navigator.pop(context);
                          }
                        }
  }

}