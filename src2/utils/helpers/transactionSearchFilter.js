const mongoose = require("mongoose");
const { Transaction } = require("../../models/index");

const buildSearchFilter =  (searchText) => {
  const trimmedText = searchText.trim() === "empty" ? "" : searchText.trim();
  const searchFilter = [];

  if (trimmedText) {
    const regex = new RegExp(trimmedText, "i");

    if (!isNaN(trimmedText)) {
      searchFilter.push({ amount: Number(trimmedText) });
    }else if(trimmedText=="debit" || trimmedText=="credit" || trimmedText=="CREDIT" || trimmedText=="DEBIT"){
      searchFilter.push({ type: regex });
    } else {
      searchFilter.push(
        { category: regex },
        { narration: regex },
        { subcategory: regex }
      );
    }
  }

  return searchFilter;
};

const escapeRegex = (str) => {
  return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); // Escape special regex chars
};

const getMatchedKeywords = async (userId, searchText) => {
  if (!searchText || searchText.trim() === "" || searchText.trim() === "empty") return [];

  const trimmedSearch = searchText.trim().toLowerCase();
  const regex = new RegExp("^" + escapeRegex(trimmedSearch), "i"); // Case-insensitive prefix match
  const objectUserId = new mongoose.Types.ObjectId(userId);

  // Project only fields we care about
  const projectionFields = {
    narration: 1,
    category: 1,
    subcategory: 1,
  };

  // Get only those documents where any of the fields contain the search text somewhere
  const matchedDocs = await Transaction.find(
    {
      userId: objectUserId,
      Hidden: false,
      $or: [
        { narration: { $regex: regex } },
        { category: { $regex: regex } },
        { subcategory: { $regex: regex } },
      ],
    },
    projectionFields
  ).lean();

  const matchedKeywordsSet = new Set();

  matchedDocs.forEach((doc) => {
    ['narration', 'category', 'subcategory'].forEach((field) => {
      if (doc[field]) {
        const words = doc[field].split(/\s+/); // split by space
        words.forEach((word) => {
          const cleanWord = word.replace(/[^a-zA-Z0-9]/g, "").toLowerCase(); // remove special characters
          if (regex.test(cleanWord)) {
            matchedKeywordsSet.add(cleanWord); // Add matching word
          }
        });
      }
    });
  });

  return [...matchedKeywordsSet];
};


module.exports = {buildSearchFilter, getMatchedKeywords};
