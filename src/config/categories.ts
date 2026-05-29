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
      'TINGLE BUDS F B',
      'HungerBox',
      'EatClub',
      'SOUTH INDIAN F',
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
      'SRI BALAJI JUICE CENTRE',
      'ROYAL JUICE CENTER',
      'Sai Tea Stall',
      'MANAM CAFE',
      'ABR CAFE AND BAKERS',
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
      'Food',
    ],

    GroceryAndDailyNeeds: [
      'kirana',
      'General Store',
      'Store',
      'Dairy',
      'Ration',
      'Foods',
      'FOODS',
      'AP FOODS',
      'OM BHAIRAVA KIRANA AND GENERAL STORES',
      'Jagdish Kirana Bhandar',
      'P LAXMIKANTH RAO AND SONS',
      'NLAXMAIAH BROS',
      'A KRISHNAIAHSONS',
    ],

    DiningPlaces: [
      'Dhaba',
      'canteen',
      'Canteen',
      'Mess',
      'Sweet Shop',
      'BAKERS',
      'SRI Venkatramana Bky',
      'CHAPPAN BHOG SWEETS',
      'PANCHRATAN DAIRY CONFECTIONERY',
    ],

    CateringServices: ['cater', 'catering'],

    MiscFood: ['eats', 'Italia'],
  },

  Shopping: {
    Ecommerce: ['Amazon', 'Flipkart', 'avenuesupermart', 'SHOPPERS P'],

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
      'South India Shopping Mall',
      'CMRNZMTXTL',
    ],

    Electronics: ['Electronics', 'Mobiles', 'THIRD EYE CCTV', 'CCTV', 'COMPUTER PERIPHERALS'],

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
      'A 1 BAZAR',
      'A1 BAZAR',
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
      'Zepto Mark',
      'ZEPTO MARK',
      'zeptomarketpla',
      'ZeptoMarketpla',
      'zptmktp',
      'cfzepto',
      'zeptopay',
      'blinkitrzp',
      'paytm-blinkit',
      'blinkit',
      'BIGBASKET',
      'INSTAMART',
    ],

    GroceryStores: [
      'SUPRDAILY',
      'GROCERY',
      'kirana',
      'General Store',
      'KANAKENTERPRISE',
      'Rice bill',
    ],

    FruitsAndVegetables: ['VEGETABLE', 'FRUIT', 'Veggie'],

    Dairy: ['milk'],
  },

  Travel: {
    Fuel: [
      'Fuel',
      'Petrol',
      'CNG',
      'Diesel',
      'PETROLEUM',
      'Filling',
      'HP FUELS',
      'FILL',
      'Pump',
      'PRAKASH FILLING STATION',
      'BP Petrol Pump',
      'Fuel Station',
      'SERVICE STATION',
      'Charminar Chou',
      'AADHYA AUTO SE',
    ],

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
      'IRCTC Rail APP',
      'Indian Rai',
      'Indian Railways UTS',
      'Hyderabad Metro',
      'MUMBAI MET',
      'MUMBAIMETRODIG',
      'TSRTC GHZ',
      'TELANGANA',
      'BZA BRK WVMS',
    ],

    TravelServices: ['Travels', 'Transport', 'Mobility', 'TRAVEL', 'airport', 'TRANSPORT'],

    ParkingAndTolls: ['Parking', 'Toll'],

    VehicleMaintenance: ['puncture', 'TVS', 'Prakash Auto Service', 'SUBHASH AUTOMOBILES'],

    TrafficAndFines: ['Traffic police'],
  },

  Health: {
    HospitalsAndClinics: [
      'Hospital',
      'Clinic',
      'Doctor',
      'Treatment',
      'Surgery',
      'HOSPIT',
      'Shalini Heart Hospital',
    ],

    Pharmacy: [
      'Medical',
      'Pharmacy',
      'Medplus',
      'Medicine',
      'PHARMA',
      'MEDICALS',
      'Pharma',
      'MEDIMORE',
      'MEDI',
      'SRI DWARAKAMAI HOPE MEDICAL HALL',
      'SHALINI MEDICAL',
      'SHIVA GANGA MEDICAL',
      'Priyanka Pharma',
      'Ms Ambe Pharmacy',
      'GANGA PARVATHI MEDICALS',
      'VM MEDICAL',
    ],

    Diagnostics: ['Diagnostic', 'Lab', 'Test', 'Scan', 'Prime Imaging'],

    Wellness: ['Therapy', 'Dental', 'Ayurveda', 'Homeopathy', 'Wellness'],
  },

  Bills: {
    Utilities: ['Electricity', 'Water', 'Gas'],

    Telecom: [
      'Mobile Recharge',
      'Recharge',
      'AIRTEL',
      'airtel',
      'JIO',
      'IDEA',
      'VI',
      'BSNL',
      'AIRTELPAYMENTS',
      'AIRTEL PAYMENTS BANK',
      'AirtelBroadbandBillPayment',
      'Valeasy',
      'cars',
    ],

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
      'Euronet Services',
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
      'Google Asi',
      'Mandate',
      'MandateExecute',
      'SPOTIFY',
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

    VehicleServices: ['Bike Service', 'Car Service', 'Bike', 'Auto Service', 'Automobiles'],

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
      'IDFC FIRST BANK',
      'SMFG India Cre',
      'MONEYVIEW',
      'BRANCHONLINEaxl',
      'branchapp',
      'Branch',
      'neokred',
    ],

    LoanTypes: ['postpaid', 'loan', 'emi', 'finance', 'borrowrepayment', 'amazonpaylaterrepay', 'MPOKKET FI'],
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
      'SweepIn',
      'AUTO SWEEPOUT TD',
      'Principal',
      'td',
    ],
  },

  Insurance: {
    InsuranceTypes: ['Life Insurance', 'Vehicle Insurance'],

    InsurancePlatforms: ['POLICYBAZAAR'],
  },

  Income: {
    BankCredits: ['NEFT', 'NEFT CR', 'credit', 'credit interest', 'Credit Interest Capitalised', 'IntPd'],

    SalaryAndPayouts: ['Salary', 'PRINC PAYOUT', 'INT PAYOUT', 'payout'],

    Refunds: ['refund', 'REVERSAL', 'REV-UPI'],

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
    SchoolsAndColleges: [
      'School',
      'college',
      'University',
      'Institute',
      'institute',
      'NEIL GOGTE INSTITUTE OF TECHNOLOGY',
    ],

    CoachingAndTraining: ['Tuition', 'Coaching', 'Academy', 'Workshop', 'Seminar', 'NISM'],

    FeesAndAdmissions: ['Fees', 'Fee', 'Admission', 'Examination', 'Exam fees'],

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
      'SMS ALERT',
      'SMS Charges',
      'CHRGS',
      'SMSChrgs',
      'Debit Card AMC',
      'Debit Interest Capitalized',
      'DCARDFE',
      'INTER-BRN CASH CHG',
      'Chqbk_Delv_Chgs',
    ],

    BankingCharges: ['CHEQUE BOOK CHARGE'],
  },
};

export default categories;
