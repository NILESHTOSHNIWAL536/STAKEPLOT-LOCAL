




import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:get/get.dart';



void showEditBottomSheet({
  required BuildContext context,
  required String initialText,
  required String id,
  required String postId,
  required String type,
}) {
  final TextEditingController controller = TextEditingController(text: initialText);
  RxBool isButtonDisabled = true.obs;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return AnimatedPadding(
        duration: Duration(milliseconds: 200),
        padding: MediaQuery.of(context).viewInsets,
        curve: Curves.easeOut,
        
        child: Container(
          height: MediaQuery.of(context).size.height/3,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withOpacity(0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:  20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cross Icon Top Right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                Text(
                'Edit ${type.capitalizeFirst!}',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 22, color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
              // Title
              
                  
              const SizedBox(height: 24),
                  
              // Text Field with Floating Label
              TextFormField(
                controller: controller,
                maxLines: null,
                onChanged: (value) {
                  isButtonDisabled.value = value.trim() == initialText.trim();
                },
                decoration: InputDecoration(
                  labelText: 'Edit your ${type.toLowerCase()}',
                  labelStyle: TextStyle(
                    color: AppColors.primaryColor
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3B3F75), width: 2),
                  ),
                ),
              ),
                  
              const SizedBox(height: 28),
                  
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(() => InkWell(
                        onTap: isButtonDisabled.value
                            ? null
                            : () {
                                editCommentReply(
                                  commentId: id,
                                  postId: postId,
                                  context: context,
                                  type: type,
                                  newText: controller.text.trim(),
                                );
                              },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isButtonDisabled.value
                                ? Colors.grey.shade400
                                : const Color(0xFF3B3F75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              color: AppColors.backgroundColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}



void showDeleteDialogComment(BuildContext context2, String commentText,String type,String id,String postId,int index,int replyindex) {
    showDialog(
      context: context2,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Icon
            // Icon(Icons.mark_chat_read_outlined, size: 50, color: Colors.red),
            AvatarProfileImage(url: 'assets/svgs/delete_pop.svg', width: 10, height: 12),

            const SizedBox(height: 12),

            // Text
             Text(
              "Are you sure u want to delete this msg",
              textAlign: TextAlign.center,
              style:   FontManager().getTextStyle(
                        context2,
                        fontSize: 16,
                       lWeight: FontWeight.w500
                      ),
            ),

            const SizedBox(height: 20),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Delete Button
              
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child:  Text(
                    "Cancel",
                      style:  FontManager().getTextStyle(
                      context2,
                      color: Colors.grey,
                      lWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                 ElevatedButton(
                  onPressed: () {
                      deleteCommentReply(commentId:id,type: type,context: ctx,postId: postId,commentIndex: index,replyIndex: replyindex );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B3F75),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child:  Text(
                    "Delete",
                    style: FontManager().getTextStyle(
                      context2,
                      color: AppColors.backgroundColor,
                      lWeight: FontWeight.w600),
                  ),
                ),

              ],
            ),
          ],
        ),
      ));
  }


              // deleteCommentReply(commentId:id,type: type,context: ctx,postId: postId,commentIndex: index,replyIndex: replyindex );
