export const categories: string[] = [
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
  "Liquor",
];

export const postType: string[] = ["feed", "explore"];

export interface RequestType {
  POST: "POST";
  GET: "GET";
  PATCH: "PATCH";
  DELETE: "DELETE";
  PUT: "PUT";
}

export const requestType: RequestType = {
  POST: "POST",
  GET: "GET",
  PATCH: "PATCH",
  DELETE: "DELETE",
  PUT: "PUT",
};

export interface ScoreToAdd {
  Post: number;
  Bill: number;
  Transaction: number;
  ClearBill: number;
  Tag: number;
}

export const scoreToAdd: ScoreToAdd = {
  Post: 5,
  Bill: 3,
  Transaction: 2,
  ClearBill: 5,
  Tag: 1,
};

export interface ScoreToGetReward {
  Transaction: number;
  Tag: number;
  Claim: number;
}

export const scoreToGetReward: ScoreToGetReward = {
  Transaction: 2,
  Tag: 2,
  Claim: 3,
};

export interface IconKey {
  url: string;
  name: string;
  count: number;
}

export interface IconsJson {
  keys: IconKey[];
  userId: string;
}

export const iconsJson: IconsJson = {
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

export interface OtpHeadersConstants {
  contentType: string;
  ContentType: string;
  ApplicationJson: string;
  X_RapidAPI_Host: string;
  X_RapidAPI_Key: string;
}

export const otpHeadersConstants: OtpHeadersConstants = {
  contentType: "content-type",
  ContentType: "Content-Type",
  ApplicationJson: "application/json",
  X_RapidAPI_Host: "X-RapidAPI-Host",
  X_RapidAPI_Key: "X-RapidAPI-Key",
};

export const pollType: string[] = ["room", "casual"];

export const needs: string[] = [
  "rent",
  "electricity",
  "emis",
  "clothing/shoes",
  "pet",
  "education",
  "wifi/dth",
  "creditbills",
];

export const wants: string[] = [
  "sports",
  "theatre",
  "repairs",
  "transport",
  "electronics",
  "accessories",
];

export const leisure: string[] = [
  "beauty",
  "trips",
  "drinks",
  "skincare",
  "subscriptions",
  "restaurant",
  "investments",
];

export const avatars: string[] = [
  "assets/avatar/menp1.svg",
  "assets/avatar/menp2.svg",
  "assets/avatar/menp3.svg",
  "assets/avatar/menp4.svg",
  "assets/avatar/womenp1.svg",
  "assets/avatar/womenp2.svg",
  "assets/avatar/womenp3.svg",
  "assets/avatar/womenp4.svg",
];
