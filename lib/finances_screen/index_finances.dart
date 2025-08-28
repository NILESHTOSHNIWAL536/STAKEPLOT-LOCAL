import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import '../bottomNavigations.dart';
import '../colorcodes.dart';
import '../controllers/credit_card_controller.dart';
import '../finance_screen/Budgets/Budget.dart';
import './FeatureGrid.dart';
import 'creditCard_slider.dart';
import 'searchfinance.dart';
import 'topay_toreceive.dart';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  @override
  void initState() {
    super.initState();
    CardDueController().fetchCardData();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: SafeArea(
          child: BottomNavigations(
        data: 1,
      )),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Section with custom clipper and search bar
              Container(
                // color: AppColors.primaryColor,
                padding: EdgeInsets.all(0),
                height: size.height / 2,
                width: MediaQuery.of(context).size.width,
                // color: AppColors.primaryColor,
                child: Stack(
                  children: [
                    // Background color with a wave shape at the bottom
                    Center(
                        child: Transform.translate(
                      offset: const Offset(0, -15),
                      child: AvatarProfileImageZero(
                          url: svgIconPath.finance, width: 1, height: 2),
                    )),
        
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Main title "Plot your finances"
                         const SizedBox(
                                height: 25,
                              ),
                        buildHeadingAndSearchBar(),
        
                        Stack(
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -180),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: AvatarProfileImageZero(
                                    url: svgIconPath.finance_background,
                                    width: 1,
                                    height: 1.6),
                              ),
                            ),
                            // Positioned(
                            //   right: 20,
                            //   top: 30,
                            //   child: Container(
                            //   alignment: Alignment.topRight,
                            //   padding: const EdgeInsets.only(right: 10,top: 5),
                            //   child: const Icon(
                            //       Icons.more_horiz,
                            //       color: Color(0xFFB8AECC),
                            //       size: 30,
                            //     ),
                            // ),),
                          Transform.translate(
                              offset: const Offset(0, -60),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(5, 10, 10, 5),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Center(child: FeatureGrid()),
                                // child: Center(child: _buildFeatureCards(context)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        
              // Middle sections start here
              const SizedBox(height: 24),
        
              // "Heading" section with "View all"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildSectionHeader('Credit Cards', () {}),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CardDueCarousel(),
              ),
        
              // "Heading to Recieve / to Pay" section
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TopayToreceive(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // Bottom navigation bar
    );
  }

  // Widget for the search bar
  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: const [
              Text(
                'View all',
                style: TextStyle(
                  color: Color(0xFF8A7FA7),
                  fontSize: 14,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF8A7FA7),
                size: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget for the horizontal scrollable grid of cards
  Widget _buildGridCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSquareCard(
            const Icon(
              Icons.add_rounded,
              color: Color(0xFF8A7FA7),
              size: 40,
            ),
            isDashed: true,
          ),
          const SizedBox(width: 16),
          _buildSquareCard(
            const Icon(
              Icons.image,
              color: Color(0xFF8A7FA7),
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          _buildSquareCard(
            const Icon(
              Icons.image,
              color: Color(0xFF8A7FA7),
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  // Individual square card with an optional dashed border
  Widget _buildSquareCard(Widget child, {bool isDashed = false}) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDashed ? const Color(0xFFE5E0F0) : Colors.transparent,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(child: child),
    );
  }

  // Widget for the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6A5ACD),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.wallet),
          label: 'Wallet',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: ClipOval(
            child: Image.network(
              'https://placehold.co/40x40/FF5733/FFFFFF?text=P',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
          label: 'User',
        ),
      ],
    );
  }
  
Widget  buildHeadingAndSearchBar() {
    return  Container(
                   margin:const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image:  DecorationImage(
                            image: AssetImage(svgIconPath.financepayReceive2),
                            fit: BoxFit.cover,
                          ),
                          // gradient: LinearGradient(
                          //   begin: Alignment.topCenter,
                          //   end: Alignment.bottomCenter,
                          //   colors: [
                          //     Color(0x061F35E5)
                          //         .withOpacity(0.4), // top color with opacity
                          //     Color(0xFF061F35)
                          //         .withOpacity(0.2), // bottom softer
                          //     Color(0xFF061F35)
                          //         .withOpacity(0.1), // bottom softer
                          //   ],
                          // ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Center(
                              child: textStyle(
                                context: context,
                                text: 'Plot your finances',
                                c: Colors.white,
                                fontsize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Search bar located below the title
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: buildSearchBar(context),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      );
  }
}

// CustomClipper for the header wave. Improved to match the image's curve.
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);

    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.95);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.88);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.8);
    var secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

// CustomClipper for the main card's complex shape. Improved for accuracy.
class CardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.15);

    var firstControlPoint = Offset(size.width * 0.15, size.height * -0.1);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.15);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.8, size.height * 0.3);
    var secondEndPoint = Offset(size.width, size.height * 0.15);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
