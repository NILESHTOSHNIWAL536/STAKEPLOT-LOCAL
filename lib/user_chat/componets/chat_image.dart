 import 'package:flutter/material.dart';
import '../../Constants/colors.dart';
import '../fullScreen.dart';


  Widget imageDisplay(msg, bool, url,context)
  {
    return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image(url,context),
            ],
        );
  }


   Widget image(url,context) {
    if (url == "" || url == "None") return SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to full image screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullImageScreen(imageUrl: url),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            url,
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 5,
            fit: BoxFit.cover,
            color: AppColors.accentColor.withOpacity(0.0),
            colorBlendMode: BlendMode.exclusion,
          ),
        ),
      ),
    );
  }
