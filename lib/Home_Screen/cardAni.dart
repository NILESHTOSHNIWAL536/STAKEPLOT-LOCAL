import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _swipeAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<Offset> _swipeAnimation;
  
  String? selectedCategory;
  List<String> selectedSubCategories = [];
  int currentCardIndex = 0;
  
  // Sample JSON data for transactions
  final List<Map<String, dynamic>> transactionData = [
    {
      "id": "1",
      "name": "Meena Maruboina",
      "amount": 300,
      "type": "credit",
      "time": "3 hours ago",
      "narration": "MUTYES/YBL**FL34",
      "status": "Untagged",
      "icon": "trending_up",
      "category": "Income"
    },
    {
      "id": "2",
      "name": "Swiggy Order",
      "amount": 450,
      "type": "debit",
      "time": "5 hours ago",
      "narration": "SWIGGY/UPI**2847",
      "status": "Tagged",
      "icon": "restaurant",
      "category": "Food"
    },
    {
      "id": "3",
      "name": "Uber Ride",
      "amount": 180,
      "type": "debit",
      "time": "1 day ago",
      "narration": "UBER/TRIP**9876",
      "status": "Untagged",
      "icon": "directions_car",
      "category": "Travel"
    }
  ];

  final Map<String, List<String>> categories = {
    "Food": [
      "Swiggy", "Zomato", "Restaurant", "Cafe", "Pizza", "Dairy", "Tea",
      "Chai", "canteen", "Bistro", "Mcdonalds", "kfc", "subway", "dominos",
      "Dhaba", "Chicken", "Italia", "bawarchi", "cafe", "Tiffin", "meals",
      "Vegetables", "udupi", "coffee", "eats", "Frankie", "Store", "rasoi",
      "fish", "Other"
    ],
    "Shopping": [
      "Shoppers", "WestSide", "Electronics", "Supermarket", "Amazon",
      "Flipkart", "Fashion", "Fabrics", "kart", "Mobiles", "lifestyle",
      "market", "more", "shop", "max", "zudio", "centro", "Other"
    ],
    "Travel": [
      "Fuel", "Petrol", "Ola", "Uber", "Metro", "Traffic polic", "puncture",
      "Mobility", "Travels", "Transport", "Filling", "Rapido", "Tgsrtc",
      "irctc", "Other"
    ],
    "Health": ["Medical", "Pharmacy", "Hospital", "Medplus", "Other"],
    "Bills": [
      "Electricity", "Water", "Gas", "Internet", "Mobile Recharge", "Rent",
      "DTH", "AIRTEL", "JIO", "Solutions", "godaddy", "hostinger", "bpcl", "Other"
    ],
    "Subscriptions": [
      "Netflix", "PrimeVideo", "Spotify", "Jio Hotstar", "appleServices",
      "disney", "Other"
    ],
    "Events": [
      "Weddings", "Birthday", "Festival", "Anniversary", "Flowers", "pubs",
      "Gift", "Other"
    ],
    "Personal care": ["Salon", "Spa", "Haircare", "Skincare", "Other"],
    "Services": [
      "Housemaid", "Carpenter", "Electrician", "Plumber", "Bike/Car Service",
      "Hardware/sanitary Workshop", "Events", "Service", "Bike", "Auto",
      "hardware", "sanitary", "communications", "traders", "Enterprises",
      "solutions", "Other"
    ],
    "EMI'S": ["Eazypay", "slice", "postpaid", "Other"],
    "Investment": ["MutualFund", "Stocks", "Gold", "Other"],
    "Insurance": ["Life Insurance", "Vehicle Insurance", "POLICYBAZAAR", "Other"],
    "Support": ["Charity", "Other"],
    "Current": ["TDS", "Other"],
    "Children": [
      "School Fees", "Tuitions", "Baby store", "miniklub", "uniforms",
      "baby care", "children", "Other"
    ],
    "Pet Care": ["Pet", "Other"],
    "Sports": ["Gym Membership", "Sports Equipment", "Snooker", "cricket", "box", "Other"],
    "Alcohol": ["Liquor", "Wine", "Cigarettes", "Other"],
    "Hobbies": ["Photography", "Gardening", "Other"],
    "Education": ["Stationary", "Fees", "institute", "college", "Other"],
    "Commerce": [
      "Amazon", "Flipkart", "Myntra", "Nykaa", "Blinkit", "zepto", "Grofers",
      "Bluedart", "ekart", "Other"
    ],
    "Snacks": [
      "juice", "Sweets", "Chai", "Biscuit", "Thickshake", "chocolate",
      "Ice cream", "chat", "mithai", "Bakes", "Bakery", "Cakes", "Tea",
      "chips", "confectioners", "cool drink", "Other"
    ],
    "Entertainment": [
      "Bookmyshow", "district", "gokarting", "gaming", "Entertainment", "pvr",
      "cinepolis", "imax", "Escape", "Adventures", "Other"
    ]
  };

  final Map<String, String> imageMapForHistory = {
    'food': 'food.svg',
    'shopping': 'shopping.svg',
    'travel': 'travel.svg',
    'health': 'health.svg',
    'bills': 'bills.svg',
    'subscriptions': 'subscription.svg',
    'events': 'events.svg',
    'personal care': 'personal_care.svg',
    'services': 'services.svg',
    'emi\'s': 'emis.svg',
    'investment': 'investment.svg',
    'insurance': 'insurance.svg',
    'support': 'support.svg',
    'current': 'current.svg',
    'children': 'children.svg',
    'pet care': 'pet_care.svg',
    'sports': 'sports.svg',
    'alcohol': 'alcohol.svg',
    'hobbies': 'hobbies.svg',
    'education': 'education.svg',
    'commerce': 'commerce.svg',
    'snacks': 'snacks.svg',
    'entertainment': 'entertainment.svg',
  };

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _swipeAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut),
    );
    
    _swipeAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _cardAnimationController.forward();
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        _swipeToNextCard();
        _startAutoSwipe();
      }
    });
  }

  void _swipeToNextCard() {
    setState(() {
      currentCardIndex = (currentCardIndex + 1) % transactionData.length;
    });
    _swipeAnimationController.reset();
    _swipeAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  String getIconUrl(String category) {
    final lowerCategory = category.toLowerCase();
    return imageMapForHistory[lowerCategory] != null
        ? "assets/icons/subCategoryIcons/${imageMapForHistory[lowerCategory]}"
        : "assets/icons/subCategoryIcons/other.svg";
  }

  IconData getTransactionIcon(String iconName) {
    switch (iconName) {
      case 'trending_up':
        return Icons.trending_up;
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color getAmountColor(String type) {
    return type == 'credit' ? Colors.green : Colors.red;
  }

  String getAmountPrefix(String type) {
    return type == 'credit' ? '+' : '-';
  }

  void onCategoryTap(String category) {
    setState(() {
      if (selectedCategory == category) {
        selectedCategory = null;
        selectedSubCategories = [];
      } else {
        selectedCategory = category;
        selectedSubCategories = categories[category] ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF9DD5EA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Animated Stacked Cards Section
              Expanded(
                flex: 2,
                child: Center(
                  child: GestureDetector(
                    onTap: _swipeToNextCard,
                    child: AnimatedBuilder(
                      animation: _cardAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _cardAnimation.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background cards for stacked effect
                              for (int i = 3; i >= 0; i--)
                                Transform.translate(
                                  offset: Offset(i * 4.0, -i * 4.0),
                                  child: Container(
                                    width: 300 + (i * 6),
                                    height: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2 + (i * 0.1)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              // Main animated card
                              SlideTransition(
                                position: _swipeAnimation,
                                child: _buildTransactionCard(transactionData[currentCardIndex]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Card indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  transactionData.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: currentCardIndex == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentCardIndex == index 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Tag Now Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: Text(
                      'Tag Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Categories Section
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: selectedCategory == null
                      ? _buildCategoriesGrid()
                      : _buildSubCategoriesGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Container(
      width: 300,
      height: 190,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: transaction['type'] == 'credit' 
                      ? Colors.green.withOpacity(0.1)
                      : Color(0xFF6B73FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getTransactionIcon(transaction['icon']),
                  color: transaction['type'] == 'credit' 
                      ? Colors.green 
                      : Color(0xFF6B73FF),
                  size: 24,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: transaction['status'] == 'Tagged' 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction['status'],
                  style: TextStyle(
                    fontSize: 10,
                    color: transaction['status'] == 'Tagged' 
                        ? Colors.green 
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            transaction['name'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${getAmountPrefix(transaction['type'])}₹ ${transaction['amount']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: getAmountColor(transaction['type']),
                ),
              ),
              SizedBox(width: 8),
              Text(
                transaction['type'] == 'credit' ? 'Credited from' : 'Debited to',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (transaction['type'] == 'credit') ...[
                SizedBox(width: 4),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          Text(
            transaction['time'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Narration',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      transaction['narration'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction['category'],
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categoryKeys = categories.keys.toList();
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
        ),
        itemCount: categoryKeys.length,
        itemBuilder: (context, index) {
          final category = categoryKeys[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () => onCategoryTap(category),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF6B73FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      getIconUrl(category),
                      width: 24,
                      height: 24,
                      color: Color(0xFF6B73FF),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategoriesGrid() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF6B73FF)),
                onPressed: () => onCategoryTap(selectedCategory!),
              ),
              Text(
                selectedCategory!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 16,
              ),
              itemCount: selectedSubCategories.length,
              itemBuilder: (context, index) {
                final subCategory = selectedSubCategories[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  child: GestureDetector(
                    onTap: () {
                      print('Selected: $subCategory');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF6B73FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SvgPicture.asset(
                            "assets/icons/subCategoryIcons/other.svg",
                            width: 24,
                            height: 24,
                            color: Color(0xFF6B73FF),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          subCategory,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}