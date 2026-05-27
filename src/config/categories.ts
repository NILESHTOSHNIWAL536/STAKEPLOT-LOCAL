const categories = {
  Food: {
    FoodDelivery: ['Swiggy', 'Zomato', 'swiggyupi', 'payzomato'],

    Restaurants: [
      'PISTA HOUSE',
      'Shah Gouse',
      'bawarchi',
      'mehfil',
      'Santhosh Dhaba',
      'Punjabi Dhaba',
      'udupi',
      'hotel',
      'restau',
      'rasoi',
      'TINGLE BUDS',
      'AMAY FOOD COURT',
      'ARABIAN GRILL',
      'MAVAS KITCHEN',
      'ARABIAN',
    ],

    FastFood: ['Bistro', 'Mcdonalds', 'kfc', 'subway', 'dominos', 'Burger King', 'Taco Bell', 'kfcrestaurants', 'burgerking'],

    CafesAndBeverages: [
      'Cafe',
      'cafe',
      'Tea',
      'Chai',
      'coffee',
      'Tea Stall',
      'Coffee Shop',
      'juice',
      'SWISS DELIGHTS',
      'FROZEN BOTTLE',
    ],

    FoodItems: [
      'Pizza',
      'Burger',
      'Chicken',
      'fish',
      'milk',
      'Mithai',
      'Frankie',
      'mutton',
      'tiffins',
      'Tiffin',
      'meals',
      'Biryani',
      'Chinese',
      'Street Food',
      'Fast Food',
    ],

    GroceryAndDailyNeeds: ['kirana', 'General Store', 'Store', 'Dairy', 'Ration', 'Foods', 'FOODS'],

    DiningPlaces: ['Dhaba', 'canteen', 'Canteen', 'Mess', 'Sweet Shop', 'BAKERS'],

    CateringServices: ['cater', 'catering'],

    MiscFood: ['eats', 'Italia'],
  },

  Shopping: {
    Ecommerce: ['Amazon', 'Flipkart', 'avenuesupermart'],

    FashionAndLifestyle: [
      'Fashion',
      'Fabrics',
      'lifestyle',
      'max',
      'zudio',
      'centro',
      'Trends',
      'WestSide',
      'Aditya Birla',
      'rareandbasics',
      'Garments',
      'Footwear',
      'Jewellery',
      'Textiles',
      'trentzudio',
      'zudioaunitoftrent',
    ],

    Electronics: ['Electronics', 'Mobiles', 'THIRD EYE CCTV', 'CCTV'],

    RetailStores: [
      'Shoppers',
      'Mart',
      'Supermarket',
      'market',
      'shop',
      'Shop',
      'Retail',
      'Bazaar',
      'Merchant',
      'Store',
      'Centre',
      'Mall',
      'Purchase',
      'Buy',
      'shopping',
      'kart',
      'more',
      'VISHAL MEGA',
      'MR DIY',
      'ValueZone',
    ],

    HomeAndFurniture: ['Furniture', 'Hardware'],

    BooksAndStationery: ['Stationery', 'Bookstore'],

    PersonalCare: ['Salon', 'Spa', 'Laundry', 'Tailor'],

    BusinessStores: ['trading'],
  },

  Groceries: {
    Supermarkets: ["SPENCER'S", 'Ratnadeep', 'dmart', 'innovdmartts', 'METRO CASH', 'BAZAR'],

    QuickCommerce: [
      'ZEPTO',
      'ZEPTOONLINEybl',
      'ZeptoMarketplace',
      'cfzepto',
      'zeptopay',
      'blinkitrzp',
      'paytm-blinkit',
      'blinkit',
      'BIGBASKET',
      'INSTAMART',
    ],

    GroceryStores: ['SUPRDAILY', 'GROCERY', 'kirana', 'General Store', 'KANAKENTERPRISE'],

    FruitsAndVegetables: ['VEGETABLE', 'FRUIT', 'Veggie'],

    Dairy: ['milk'],
  },

  Travel: {
    Fuel: ['Fuel', 'Petrol', 'CNG', 'Diesel', 'PETROLEUM', 'Filling', 'HP FUELS', 'FILL', 'Pump'],

    CabServices: ['Ola', 'Uber', 'Rapido', 'Blusmart', 'OlaCabs'],

    PublicTransport: [
      'Metro',
      'Tgsrtc',
      'TSRTC',
      'Apsrtc',
      'irctc',
      'railways',
      'railway',
      'HYDMETROINAPP',
      'REDBUS',
      'CHALOTSRTCDQRybl',
      'IRCTCPGONLINEaxl',
      'IRCTCPGONLINEybl',
      'indianrailwaysutsb',
    ],

    TravelServices: ['Travels', 'Transport', 'Mobility', 'TRAVEL', 'airport', 'TRANSPORT'],

    ParkingAndTolls: ['Parking', 'Toll'],

    VehicleMaintenance: ['puncture', 'TVS'],

    TrafficAndFines: ['Traffic police'],
  },

  Health: {
    HospitalsAndClinics: ['Hospital', 'Clinic', 'Doctor', 'Treatment', 'Surgery', 'HOSPIT'],

    Pharmacy: ['Medical', 'Pharmacy', 'Medplus', 'Medicine', 'PHARMA', 'MEDICALS', 'Pharma', 'MEDIMORE', 'MEDI'],

    Diagnostics: ['Diagnostic', 'Lab', 'Test', 'Scan'],

    Wellness: ['Therapy', 'Dental', 'Ayurveda', 'Homeopathy', 'Wellness'],
  },

  Bills: {
    Utilities: ['Electricity', 'Water', 'Gas'],

    Telecom: ['Mobile Recharge', 'AIRTEL', 'JIO', 'IDEA', 'VI', 'BSNL', 'AIRTELPAYMENTS'],

    Internet: ['Internet', 'ACT', 'HATHWAY'],

    Housing: ['Rent', 'Housing', 'PG', 'Hostel', 'Flat', 'Apartment', 'Landlord'],

    DTH: ['DTH'],

    HostingAndDomains: ['godaddy', 'hostinger'],

    FuelBills: ['bpcl'],

    MiscBills: [
      'Solutions',
      'TATA',
      'charges',
      'chrg',
      'playstore',
      'SMSChrgs',
      'ANNUALFEE',
      'DCARDFE',
      'Debit Card AMC',
      'Debit Interest Capitalized',
      'BBPSBPaxl',
      'BBPSBPybl',
      'Euronet',
    ],
  },

  Subscriptions: {
    OTT: [
      'Netflix',
      'PrimeVideo',
      'Jio Hotstar',
      'HOTSTAR+',
      'ZEE5',
      'SONYLIV',
      'JIO CINEMA',
      'VOOT',
      'ALT BALAJI',
      'EPIC ON',
      'MUX PLAY',
      'disney',
      'JIOINAPPDIRECTybl',
    ],

    Music: ['Spotify', 'GAANA'],

    AppSubscriptions: [
      'appleServices',
      'Googleplay',
      'OpenAI',
      'openaillc',
      'Google India Digital',
      'Mandate',
      'MandateExecute',
    ],

    DeliverySubscriptions: ['Swiggy', 'Zomato', 'BLINKIT+'],
  },

  Events: {
    Celebrations: ['Weddings', 'Birthday', 'Festival', 'Anniversary'],

    GiftsAndDecor: ['Flowers', 'Gift'],

    PartyAndNightlife: ['pubs'],
  },

  PersonalCare: {
    Grooming: ['Salon', 'Haircare'],

    Wellness: ['Spa', 'Skincare'],
  },

  Services: {
    HomeServices: [
      'Housemaid',
      'Carpenter',
      'Electrician',
      'Plumber',
      'Sanitary',
      'hardware',
      'sanitary',
    ],

    VehicleServices: ['Bike Service', 'Car Service', 'Bike'],

    RepairsAndMaintenance: ['Hardware'],

    BusinessServices: [
      'communications',
      'traders',
      'Enterprises',
      'solutions',
      'Service',
      'Events',
      'AGENCIES',
      'CHEMICALS',
      'INDUSTRIES',
    ],
  },

  Emi: {
    LoanProviders: [
      'Eazypay',
      'slice',
      'mpocket',
      'mpokket',
      'BDECS-IDFC FIRST BANK',
      'SMFG India Cre',
      'MONEYVIEW',
      'BRANCHONLINEaxl',
      'branchapp',
      'neokred',
    ],

    LoanTypes: ['postpaid', 'loan', 'emi', 'finance', 'borrowrepayment', 'amazonpaylaterrepay'],
  },

  Investments: {
    MutualFunds: ['MutualFund', 'MutualFunds', 'Fund', 'SIP'],

    StocksAndTrading: ['Stocks', 'Equity', 'Trading', 'Brokerage', 'zerodhabroking'],

    Deposits: ['Fixed Deposit', 'FD', 'Recurring Deposit', 'RD'],

    Retirement: ['PPF', 'NPS', 'Pension'],

    GoldInvestments: ['Gold'],

    GeneralInvestments: [
      'Jar',
      'Investment',
      'Portfolio',
      'Dividend',
      'Bonds',
      'payout',
      'sweepout',
      'td',
    ],
  },

  Insurance: {
    InsuranceTypes: ['Life Insurance', 'Vehicle Insurance'],

    InsurancePlatforms: ['POLICYBAZAAR'],
  },

  Income: {
    BankCredits: ['NEFT', 'NEFT CR', 'credit', 'credit interest'],

    SalaryAndPayouts: ['Salary', 'PRINC PAYOUT', 'INT PAYOUT', 'payout'],

    Refunds: ['refund'],

    MiscIncome: ['BIL', 'INF'],
  },

  Support: {
    Donations: ['Charity', 'Donation', 'Help charity', 'THE GIVING HAN'],

    NGOsAndTrusts: ['Trust', 'ngo'],
  },

  Current: {
    Taxes: ['TDS'],
  },

  Children: {
    Education: ['School Fees', 'Tuitions', 'uniforms'],

    BabyCare: ['Baby store', 'baby care', 'miniklub'],

    ToysAndKidsStores: ['children', 'firstcry', 'TOY STORE', 'hamleys'],
  },

  PetCare: {
    PetServices: ['Pet'],
  },

  Sports: {
    GymsAndFitness: ['Gym Membership', 'FITPASS', 'GYMCRM', 'YOGA STUDIO'],

    SportsStores: ['Sports Equipment', 'DECATHLON', 'SPORTS360', 'CRICKET STORE'],

    SportsActivities: ['Snooker', 'cricket', 'box'],
  },

  Alcohol: {
    LiquorStores: ['Liquor', 'Wine', 'whiskey'],

    PubsAndBars: ['Pub'],
  },

  Hobbies: {
    CreativeHobbies: ['Photography'],

    OutdoorHobbies: ['Gardening'],
  },

  Education: {
    SchoolsAndColleges: ['School', 'college', 'University', 'Institute', 'institute'],

    CoachingAndTraining: ['Tuition', 'Coaching', 'Academy', 'Workshop', 'Seminar', 'NISM'],

    FeesAndAdmissions: ['Fees', 'Fee', 'Admission', 'Examination'],

    BooksAndStationery: ['Books', 'Stationary', 'Uniform', 'STUDENT XEROX'],

    Accommodation: ['Hostel'],
  },

  Commerce: {
    Ecommerce: ['Amazon', 'Flipkart', 'Myntra', 'Nykaa', 'amznlpa'],

    LogisticsAndDelivery: ['Bluedart', 'ekart', 'Delhivery', 'e cart', 'EKARTybl', 'paytm-delhivery', 'Shadowfax'],

    OnlinePharmacy: ['netmeds', '1mg'],

    OnlineGroceries: ['BIGBASKET', 'GROFERS', 'INSTAMART', 'blinkit'],
  },

  Snacks: {
    Bakery: ['Bakes', 'Bakery', 'Cakes', 'confectioners'],

    Beverages: ['juice', 'Chai', 'Tea', 'cool drink', 'Thickshake'],

    DessertsAndSweets: ['Sweets', 'mithai', 'Ice cream', 'chocolate'],

    QuickSnacks: ['Biscuit', 'chips', 'chat', 'CHAAT'],
  },

  Entertainment: {
    MoviesAndCinema: ['Bookmyshow', 'pvr', 'cinepolis', 'imax'],

    GamingAndActivities: ['gaming', 'gokarting', 'Escape', 'Adventures', 'PICKLE BALL', 'TOP SPIN', 'PLAYO'],

    GeneralEntertainment: ['district', 'Entertainment'],
  },

  PersonalTransfer: {
    CashWithdrawal: ['CASH WDL', 'ATM', 'Cash Withdrawal'],

    POSAndTransfers: ['POS', 'To:', 'CHQ PAID', 'UPI Lite', 'IMPS Transfer', 'UPI Payment'],
  },

  PersonalTransferReceived: {
    UPICredits: ['UPI-CR', 'UPI CR'],
  },

  BankCharges: {
    TransferCharges: ['NEFT CHARGE', 'IMPS CHARGE'],

    ATMCharges: ['ATM FEE'],

    ServiceCharges: [
      'SERVICE CHARGE',
      'ANNUAL FEE',
      'SMS ALERT CHARGE',
      'SMSChrgs',
      'Debit Card AMC',
      'Debit Interest Capitalized',
      'DCARDFE',
    ],

    BankingCharges: ['CHEQUE BOOK CHARGE'],
  },
};

export default categories;
