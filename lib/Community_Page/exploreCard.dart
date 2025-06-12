import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
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
 final PageController _pageController = PageController(); 
  int _currentPage = 0; 
 bool _showFullDescription = false;

  // Helper method to get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    return baseSize *
        MediaQuery.of(context).size.width /
        375; // Based on a standard width (e.g., iPhone 8)
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //decoration: _buildBackgroundDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
             padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.036,
            ),
            child: _buildHeader(context),
          ),
          _buildImageSection(context),
          Padding(
             padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.036,
            ),
            child: _buildPlaceInfo(context),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
             padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.036,
            ),
            child: _buildBudgetSection(context),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
             padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.036,
            ),
            child: _buildTripHighlights(context),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.036,
            ),
            child: _buildDescription(context),
          ),
        ],
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
    bool hasMultipleImages = widget.extractdata['images'] != null && widget.extractdata['images'].length > 1;

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.015),
      child: Stack(
        alignment: Alignment.bottomCenter, // Align dots at the bottom center
        children: [
         hasMultipleImages
              ? SizedBox(
                  height: MediaQuery.of(context).size.width * 214 / 402,
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.extractdata['images'].length,
                    itemBuilder: (context, index) => _buildImageItem(context, index),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index; // Update current page for dots
                      });
                    },
                  ),
                )
              : _buildSingleImage(context, widget.extractdata['images'][0]),
          // Show dot indicators only if multiple images exist
          if (hasMultipleImages)
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.extractdata['images'].length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 10 : 6,
                    height: _currentPage == index ? 10 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          // Show swipe icon only if multiple images exist
         
        ],
      ),
    );
  }

  Widget _buildImageItem(BuildContext context, int index) {
    return GFImageOverlay(
      width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width *
                                    214 /
                                    402,
                                boxFit: BoxFit.fill,
      // borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
      image: NetworkImage(widget.extractdata['images'][index]),
    );
  }

  Widget _buildSingleImage(BuildContext context, String imageUrl) {
    return Center(
      child: GFImageOverlay(
       width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width *
                                    214 /
                                    402,
                                boxFit: BoxFit.fill,
        // borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
        image: NetworkImage(imageUrl),
      ),
    );
  }

  Widget _buildPlaceInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.my_location_outlined,
                  size: _getResponsiveFontSize(context, 18),
                  color: AppColors.bg1),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                child: Text(
                  "Place: ${widget.extractdata['name']}",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
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
              Icon(Icons.location_on,
                  size: _getResponsiveFontSize(context, 18),
                  color: AppColors.bg1),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                child: Text(
                  "Location: ${widget.extractdata['location']}",
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
        Text(
          "Budget",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: _getResponsiveFontSize(context, 16),
            color: AppColors.bg1,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.006,
      ),
      decoration: BoxDecoration(
        color: AppColors.unSelectedOption,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${budgetItem['category']}:",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: _getResponsiveFontSize(context, 12),
              color: AppColors.bg1,
            ),
          ),
          Text(
            "₹${budgetItem['amount']}",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w400,
              fontSize: _getResponsiveFontSize(context, 12),
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
          // margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
          decoration: BoxDecoration(
            color: AppColors.unSelectedOption,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
              Icons.tips_and_updates, // Added icon for Trip Highlights
              size: _getResponsiveFontSize(context, 16),
              color: AppColors.bg1,
            ),
              Text(
                "${widget.extractdata['tripHighlights']}",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: _getResponsiveFontSize(context, 12),
                  color: AppColors.bg1,
                ),
              ),
            ],
          ),
        ),
       
      ],
    );
  }

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
         lineHeight: 1.2, // Approximating line-height: normal
            letterSpacing: 0.24,
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
          lWeight: FontWeight.w400,
          fontSize: _getResponsiveFontSize(context, 14),
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
                 lineHeight: 1.2, // Approximating line-height: normal
            letterSpacing: 0.24,
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
                    style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.accentColor,
                         lineHeight: 1.2, // Approximating line-height: normal
            letterSpacing: 0.24,
                      ),
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
