import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';

import 'package:get/get.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({Key? key}) : super(key: key);

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  late Future<List<dynamic>> _savedPostsFuture;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _savedPostsFuture = _fetchSavedPosts();
  }

   Future<List<dynamic>> _fetchSavedPosts() async {
  try {
    isLoading.value = true;
    var urlPath = "${url}/post/saved";
   

    var response = await getDataApiCall(urlPath);
   

    isLoading.value = false;
    if (getFlagOfResponse(response)) {
      var responseData = jsonDecode(response.body); 
     
      return responseData['data'] ?? [];
    } else {
      errorMessage.value = 'Failed to load saved posts';
     
      return [];
    }
  } catch (e) {
    isLoading.value = false;
    errorMessage.value = 'Error: $e';
   
    return [];
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Saved Posts',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.bg1,
          ),
        ),
        backgroundColor: AppColors.mt,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.bg1),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => isLoading.value
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : errorMessage.value.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage.value,
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 16,
                            color: AppColors.bg1,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _savedPostsFuture = _fetchSavedPosts();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : FutureBuilder<List<dynamic>>(
                    future: _savedPostsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading posts',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 16,
                              color: AppColors.bg1,
                            ),
                          ),
                        );
                      }
                      final posts = snapshot.data ?? [];
                      if (posts.isEmpty) {
                        return Center(
                          child: Text(
                            'No saved posts found',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 16,
                              color: AppColors.bg1,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return PostCard(
                            data: posts[index],
                             // Indicate saved post context
                            index: index,
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}