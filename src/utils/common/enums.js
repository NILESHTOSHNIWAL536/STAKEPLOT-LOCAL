
const categories = [
  "income",
  "restaurant",
  "hospital",
  "drinks",
  "shopping",
  "transport",
  "household",
  "education",
  "smoke",
  "gifting",
  "bills",
  "snacks",
  "movies",
  "subscriptions",
  "rent",
  "electricity",
  "emis",
  "clothing-shoes",
  "wifi-dth",
  "credit bills",
  "sports",
  "theatre",
  "repairs",
  "electronics",
  "beauty",
  "skin care",
  "Spotify",
  "pet",
  "trips",
  "miscellaneous",
  "accessories",
  "investments",
  "others",
  "Pet",
  "POLICYBAZAAR",
  "Petrol",
  "Fees",
  "Liquor"
];
const postType = ["feed", "explore"];

const requestType = {
  POST: "POST",
  GET: "GET",
  PATCH: "PATCH",
  DELETE: "DELETE",
  PUT: "PUT",
};

const scoreToAdd = {
  Post: 5,
  Bill: 3,
  Transaction: 2,
  ClearBill: 5,
  Tag:1,
};

const scoreToGetReward = {
  Transaction: 2,
  Tag:2,
  Claim:3
};

const iconsJson = {
  keys: [
    {
      url: "assets/images/restaurant.svg",
      name: "restaurant",
      count: 0,
    },
    {
      url: "assets/images2/hospital.svg",
      name: "hospital",
      count: 0,
    },
    {
      url: "assets/images2/drinks.svg",
      name: "drinks",
      count: 0,
    },
    {
      url: "assets/images2/Shopping.svg",
      name: "shopping",
      count: 0,
    },
    {
      url: "assets/images2/Transport.svg",
      name: "transport",
      count: 0,
    },
    {
      url: "assets/images/Household.svg",
      name: "household",
      count: 0,
    },
    {
      url: "assets/images2/education.svg",
      name: "education",
      count: 0,
    },
    {
      url: "assets/images2/Smoke.svg",
      name: "smoke",
      count: 0,
    },
    {
      url: "assets/images2/gift.svg",
      name: "gifting",
      count: 0,
    },
    {
      url: "assets/images/Bills.svg",
      name: "bills",
      count: 0,
    },
    {
      url: "assets/images2/snacks.svg",
      name: "snacks",
      count: 0,
    },
    {
      url: "assets/images2/others.svg",
      name: "others",
      count: 0,
    },
    {
      url: "assets/images2/subscriptions.svg",
      name: "subscriptions",
      count: 0,
    },
  ],
  userId: "",
};

const otpHeadersConstants = {
  contentType: "content-type",
  ContentType: "Content-Type",
  ApplicationJson: "application/json",
  X_RapidAPI_Host: "X-RapidAPI-Host",
  X_RapidAPI_Key: "X-RapidAPI-Key",
};

const pollType = ["room", "casual"];
const needs = [
  "rent",
  "electricity",
  "emis",
  "clothing/shoes",
  "pet",
  "education",
  "wifi/dth",
  "creditbills",
];

const wants = [
  "sports",
  "theatre",
  "repairs",
  "transport",
  "electronics",
  "accessories",
];

const leisure = [
  "beauty",
  "trips",
  "drinks",
  "skincare",
  "subscriptions",
  "restaurant",
  "investments",
];

const avatars = [
  "assets/avatar/menp1.svg",
  "assets/avatar/menp2.svg",
  "assets/avatar/menp3.svg",
  "assets/avatar/menp4.svg",
  "assets/avatar/womenp1.svg",
  "assets/avatar/womenp2.svg",
  "assets/avatar/womenp3.svg",
  "assets/avatar/womenp4.svg",
];

module.exports = {
  categories,
  requestType,
  otpHeadersConstants,
  postType,
  pollType,
  iconsJson,
  needs,
  wants,
  leisure,
  avatars,
  scoreToAdd,
  scoreToGetReward
};