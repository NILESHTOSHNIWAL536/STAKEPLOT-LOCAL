import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:flutter_svg/svg.dart';

class CardStackScreen extends StatefulWidget {
  @override
  _CardStackScreenState createState() => _CardStackScreenState();
}

class _CardStackScreenState extends State<CardStackScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  List<CardData> cards = []; // For stack display (up to 3 cards)
  List<CardData> allCards = []; // Store all fetched cards
  int selectedCardIndex = -1;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAutoPayData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize controllers based on cards + 1 for "View All"
    _controllers = List.generate(
      cards.length + 1, // Cards + View All card
      (index) => AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      ),
    );

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(begin: Offset.zero, end: Offset(0, -0.8)).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  Future<void> _fetchAutoPayData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final fetchedCards = await getAutoPayInfo();

    setState(() {
      allCards = fetchedCards; // Store all fetched cards
      cards = fetchedCards.take(3).toList(); // Limit to 3 for stack
      isLoading = false;
      if (fetchedCards.isEmpty) {
        errorMessage = "No auto-pay data available.";
      }
    });

    // Reinitialize animations based on the number of cards
    setState(() {
      _controllers = List.generate(
        cards.length + 1, // Cards + View All
        (index) => AnimationController(
          duration: Duration(milliseconds: 500),
          vsync: this,
        ),
      );

      _slideAnimations = _controllers.map((controller) {
        return Tween<Offset>(begin: Offset.zero, end: Offset(0, -0.8)).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCardTap(int index, BuildContext context) {
    if (index == cards.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AllCardsScreen(cards: allCards), // Pass allCards
        ),
      );
    } else {
      setState(() {
        if (selectedCardIndex == index) {
          _controllers[index].reverse();
          selectedCardIndex = -1;
        } else {
          if (selectedCardIndex != -1)
            _controllers[selectedCardIndex].reverse();
          selectedCardIndex = index;
          _controllers[index].forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Center(
                    child: Text(errorMessage!,
                        style: TextStyle(color: Colors.red)))
              else
                Container(
                  height: MediaQuery.of(context).size.height * 0.36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4A4A6A).withOpacity(0.9),
                        Color(0xFF3A3A5A).withOpacity(0.8),
                        Color(0xFF2A2A4A).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = cards.length; i >= 0; i--)
                        Positioned(
                          top: 20.0 + (cards.length - i) * 40.0,
                          left: 15,
                          right: 15,
                          child: AnimatedBuilder(
                            animation: _controllers[i],
                            builder: (context, child) {
                              return SlideTransition(
                                position: _slideAnimations[i],
                                child: GestureDetector(
                                  onTap: () => _onCardTap(i, context),
                                  child: i == cards.length
                                      ? Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.25),
                                                blurRadius: 12,
                                                offset: Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            "View All",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            gradient: cards[i].gradient,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.25),
                                                blurRadius: 12,
                                                offset: Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        cards[i].title,
                                                         style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.accentColor,
              ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        cards[i].date,
                                                          style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 10,
                color: AppColors.accentColor,
              ),
              
                                                      ),
                                                      SizedBox(height: 4),
                                                      Container(
                                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.4),  // same as given background
      borderRadius: BorderRadius.circular(2), // given border-radius
    ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          
                                                          children: [
                                                             chatAvatartImage(
                    url: 'assets/icons/Home-page/frequency.svg',
                    height: 50,
                    width: 50,
                  ),
                  SizedBox(width: 2,),
                                                            Text(
                                                              cards[i].frequency,
                                                                 style: FontManager().getTextStyle(
                                                                            context,
                                                                            lWeight: FontWeight.w500,
                                                                            fontSize: 12,
                                                                            color: AppColors.primaryColor,
                                                                          ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                     
                                                      Text(
                                                                      "Occurrences",
                                                                      style: FontManager().getTextStyle(
                                                                        context,
                                                                        lWeight: FontWeight.w500,
                                                                        fontSize: 14,
                                                                        color:
                                                                            AppColors.bg1,
                                                                      ),
                                                                    ),

                                                                     SizedBox(height: 4),
                                                  Expanded(
                                                        child: Wrap(
                                                          spacing: 4.0,
                                                          runSpacing: 4.0,
                                                          children: cards[i].occuranceDate.isEmpty
                                                              ? [
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal: 8, vertical: 4),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          Colors.white.withOpacity(0.2),
                                                                      borderRadius:
                                                                          BorderRadius.circular(4),
                                                                    ),
                                                                    child: Text(
                                                                      "No occurrences",
                                                                      style: FontManager().getTextStyle(
                                                                        context,
                                                                        lWeight: FontWeight.w400,
                                                                        fontSize: 10,
                                                                        color:
                                                                            AppColors.backgroundColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]
                                                              : cards[i]
                                                                  .occuranceDate
                                                                  .map((date) => Container(
                                                                        
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal: 8,
                                                                            vertical: 4),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.white
                                                                              .withOpacity(0.2),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        child: Text(
                                                                          date,
                                                                          style:
                                                                              FontManager().getTextStyle(
                                                                            context,
                                                                            lWeight: FontWeight.w400,
                                                                            fontSize: 10,
                                                                            color: AppColors
                                                                                .backgroundColor,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      cards[i].amount,
                                                        style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.accentColor,
              ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Container(
                                                      //  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      //     decoration: BoxDecoration(
                                                      //       color: Colors.white.withOpacity(0.2),  // same as given background
                                                      //       borderRadius: BorderRadius.circular(6), // given border-radius
                                                      //     ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                        GestureDetector(
                                                        onTap: () async {
                                                          final confirm = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              title: const Text("Add Payment"),
                                                              content: const Text("Do you want to add this recurring payment?"),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context, false),
                                                                  child: const Text("Cancel"),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context, true),
                                                                  child: const Text("Add"),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                      
                                                          if (confirm == true) {
                                                            final success = await addRecurringPayment(cards[i].id);
                                                      
                                                            if (success) {
                                                              snackBarCalled(context, "Payment added successfully");
                                                              await _fetchAutoPayData();
                                                            } else {
                                                              snackBarCalled(context, "Failed to add payment");
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.2),  // same as given background
                                                            borderRadius: BorderRadius.only(topLeft:Radius.circular(10), topRight: Radius.circular(10) ),  // given border-radius
                                                          ),
                                                          child: const Text(
                                                            "+",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.white, // same as foreground color
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      
                                                          SizedBox(height: 2),
                                                      
                                                          GestureDetector(
                                                       onTap: () async {
                                                              final confirm =
                                                                  await showDialog<
                                                                      bool>(
                                                                context: context,
                                                                builder:
                                                                    (context) =>
                                                                        AlertDialog(
                                                                  title: Text(
                                                                      "Ignore Payment"),
                                                                  content: Text(
                                                                      "Are you sure you want to ignore this recurring payment?"),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              context,
                                                                              false),
                                                                      child: Text(
                                                                          "Cancel"),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              context,
                                                                              true),
                                                                      child: Text(
                                                                          "Ignore"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                              if (confirm ==
                                                                  true) {
                                                                final success =
                                                                    await ignoreRecurringPayment(
                                                                        cards[i]
                                                                            .id);
                                                                            snackBarCalled(
                                                                    context,
                                                                    "Payment ignored successfully");
                                                                snackBarCalled(
                                                                    context,
                                                                    "Failed to ignore payment");
                                                               
                                                                if (success) {
                                                                  await _fetchAutoPayData();
                                                                }
                                                              }
                                                            },
                                                            
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.2),  // same as given background
                                                            borderRadius: BorderRadius.only(bottomLeft:Radius.circular(10), bottomRight: Radius.circular(10) ), // given border-radius
                                                          ),
                                                          child: const Text(
                                                            "x",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.white, // same as foreground color
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      
                                                        
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      Positioned(
                        bottom: 20,
                        left: 10,
                        child: SvgPicture.asset(
                          'assets/icons/Home-page/autoPays.svg',
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.height * 0.17,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllCardsScreen extends StatelessWidget {
  final List<CardData> cards;

  AllCardsScreen({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Transactions"),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: cards.isEmpty
              ? Center(
                  child: Text("No transactions available",
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: cards[index].gradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cards[index].title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      cards[index].date,
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    ),
                                    Text(
                                      cards[index].frequency,
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    ),
                                    SizedBox(height: 4),
                                    Expanded(
                                      child: Text(
                                        cards[index].narration,
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    cards[index].amount,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Implement Add functionality
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.white.withOpacity(0.2),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          minimumSize: Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          "+ Add",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      TextButton(
                                        onPressed: () {
                                          // Implement Ignore functionality
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 4),
                                          minimumSize: Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          "Ignore",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
