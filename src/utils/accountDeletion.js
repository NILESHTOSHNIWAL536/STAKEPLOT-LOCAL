const {AccountDeletion, User} = require("../models/index");

const accountDeletion = async (req, res) => {
  try {
    const data = req.body;

    const emailResponse = await User.find({ email: data.email });
    if (emailResponse.length === 0) {
      return res.status(400).json({ error: "Email not found" });
    }

    const result = await AccountDeletion.create(data);

    return res.status(200).json({ message: "Account deletion request created successfully", result });
  } catch (error) {
    console.error("Error during account deletion:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
};

module.exports = accountDeletion;
