const mongoose = require('mongoose');

const bankLogoSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  logoUrl: {
    type: String,
    required: true,
  },
}, 
);

module.exports = mongoose.model('BankLogo', bankLogoSchema);