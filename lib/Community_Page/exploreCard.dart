import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';

class ExploreCard extends StatefulWidget {
  final dynamic extractdata;
  final dynamic dataObj;

  ExploreCard({
    super.key,
    required this.extractdata,
    required this.dataObj,
  });

  @override
  State<ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<ExploreCard> {
  final ScrollController _scrollController = ScrollController();

 bool _showFullDescription = false;

  // Helper method to get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    return baseSize * MediaQuery.of(context).size.width / 375; // Based on a standard width (e.g., iPhone 8)
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.015,
        horizontal: MediaQuery.of(context).size.width * 0.025,
      ),
      child: Container(
        //decoration: _buildBackgroundDecoration(),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildImageSection(context),
              _buildPlaceInfo(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildBudgetSection(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildTripHighlights(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildDescription(context),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      image: const DecorationImage(
        image: NetworkImage(
          'https://drifttravel.com/wp-content/uploads/2023/01/travel-aesthetic-content-japan.jpg',
        ),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black26,
          BlendMode.dstATop,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Exploria",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: _getResponsiveFontSize(context, 16),
              color: AppColors.bg1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            Text(
              "Rating: ",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: _getResponsiveFontSize(context, 14),
                color: AppColors.bg1,
              ),
            ),
            Text(
              "${widget.extractdata['rating']}/5",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w400,
                fontSize: _getResponsiveFontSize(context, 12),
                color: AppColors.bg1,
              ),
            ),
            Icon(
              Icons.star,
              size: _getResponsiveFontSize(context, 20),
              color: Colors.yellow,
            ),
          ],
        ),
      ],
    );
  }

 Widget _buildImageSection(BuildContext context) {
  bool hasMultipleImages = widget.extractdata['pictures'] != null && widget.extractdata['pictures'].length > 1;

  return Padding(
    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.015),
    child: Stack(
      children: [
        widget.extractdata['pictures'] != null
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.extractdata['pictures'].length,
                  itemBuilder: (context, index) => _buildImageItem(context, index),
                ),
              )
            : _buildSingleImage(context, widget.dataObj['image']),

        // Show swipe icon only if multiple images exist
        if (hasMultipleImages)
          Positioned(
            right: 10,
            bottom: 10,
            child: Icon(
              Icons.swipe,
              color: Colors.black,
              size: _getResponsiveFontSize(context, 24),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildImageItem(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.025),
      child: GFImageOverlay(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.35,
        borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
        image: NetworkImage(widget.extractdata['pictures'][index]),
      ),
    );
  }

  Widget _buildSingleImage(BuildContext context, String imageUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.015),
      child: Center(
        child: GFImageOverlay(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.4,
          boxFit: BoxFit.fill,
          borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
          image: NetworkImage(imageUrl),
        ),
      ),
    );
  }

  Widget _buildPlaceInfo(BuildContext context) {
    return Container(
      //padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.015),
      // decoration: BoxDecoration(
      //   color: Colors.white.withOpacity(0.2),
      //   borderRadius: BorderRadius.circular(8),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.my_location_outlined, size: _getResponsiveFontSize(context, 18), color: AppColors.bg1),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                child: Text(
                  "Place: ${widget.extractdata['place']['name']}",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: _getResponsiveFontSize(context, 14),
                    color: AppColors.bg1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Row(
            children: [
              Icon(Icons.location_on, size: _getResponsiveFontSize(context, 18), color: AppColors.bg1),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                child: Text(
                  "Location: ${widget.extractdata['place']['location']}",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: _getResponsiveFontSize(context, 14),
                    color: AppColors.bg1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Text(
          "Budget",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: _getResponsiveFontSize(context, 16),
            color: AppColors.bg1,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Wrap(
          spacing: MediaQuery.of(context).size.width * 0.025,
          runSpacing: MediaQuery.of(context).size.height * 0.015,
          children: (widget.extractdata['budget'] as List).map((budgetItem) {
            return _buildBudgetItem(context, budgetItem);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetItem(BuildContext context, dynamic budgetItem) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.03,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${budgetItem['category']}:",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: _getResponsiveFontSize(context, 14),
              color: AppColors.bg1,
            ),
          ),
          Text(
            "₹${budgetItem['amount']}",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w400,
              fontSize: _getResponsiveFontSize(context, 14),
              color: AppColors.bg1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHighlights(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trip Highlight(s)",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w600,
            fontSize: _getResponsiveFontSize(context, 16),
            color: AppColors.bg1,
          ),
        ),
         SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Container(
          //width: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
          decoration: BoxDecoration(
            color: AppColors.button,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
              Icons.tips_and_updates, // Added icon for Trip Highlights
              size: _getResponsiveFontSize(context, 20),
              color: AppColors.bg1,
            ),
              Text(
                "${widget.extractdata['tripHighlight']}",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: AppColors.bg1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
      ],
    );
  }

  //  Widget _buildDescription(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Description",
  //         style: FontManager().getTextStyle(
  //           context,
  //           lWeight: FontWeight.w600,
  //           fontSize: _getResponsiveFontSize(context, 16),
  //           color: AppColors.bg1,
  //         ),
  //       ),
  //       Padding(
  //         padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               widget.extractdata['description'],
  //               maxLines: _showFullDescription ? null : 2,
  //               overflow: _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
  //               style: FontManager().getTextStyle(
  //                 context,
  //                 lWeight: FontWeight.w400,
  //                 fontSize: _getResponsiveFontSize(context, 14),
  //                 color: AppColors.bg1,
  //               ),
  //             ),
  //             SizedBox(height: MediaQuery.of(context).size.height * 0.01),
  //             GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   _showFullDescription = !_showFullDescription;
  //                 });
  //               },
  //               child: Text(
  //                 _showFullDescription ? "Show Less" : "Show More",
  //                 style: FontManager().getTextStyle(
  //                   context,
  //                   lWeight: FontWeight.w600,
  //                   fontSize: _getResponsiveFontSize(context, 14),
  //                   color: Colors.blue,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDescription(BuildContext context) {
  // Check if text exceeds one line
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: widget.extractdata['description'],
      style: FontManager().getTextStyle(
        context,
        lWeight: FontWeight.w400,
        fontSize: _getResponsiveFontSize(context, 14),
        color: AppColors.bg1,
      ),
    ),
    maxLines: 2,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: MediaQuery.of(context).size.width * 0.9);

  bool isTextOverflowing = textPainter.didExceedMaxLines;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Description",
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.w600,
          fontSize: _getResponsiveFontSize(context, 16),
          color: AppColors.bg1,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.extractdata['description'],
              maxLines: _showFullDescription ? null : 2,
              overflow: _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w400,
                fontSize: _getResponsiveFontSize(context, 14),
                color: AppColors.bg1,
              ),
            ),
            if (isTextOverflowing) // Show button only if text exceeds one line
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showFullDescription = !_showFullDescription;
                  });
                },
                child: Text(
                  _showFullDescription ? "Show Less" : "Show More",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

}