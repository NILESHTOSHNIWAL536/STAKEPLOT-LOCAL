const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');

const CLIENT_ID = process.env.CLIENT_ID;
const JWT_SECRET = process.env.JWT_SECRET;
const client = new OAuth2Client(CLIENT_ID);

const googleAuth = async (req, res) => {
  try {
    const { idToken } = req.body;

    // Verify Google ID token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: CLIENT_ID,
    });

    const payload = ticket.getPayload();

    const { sub: googleId, email, name, picture } = payload;
    const user = {
      googleId,
      email,
      name,
      picture,
    };

    // const userCreated = await UserService.createUser(user);

    // Example: Generate JWT
    const token = jwt.sign(user, JWT_SECRET, { expiresIn: '1h' });

    // Send response to Flutter
    res.status(200).json({
      message: 'Authentication successful',
      token,
      user,
    });
  } catch (error) {
    console.error('Error verifying token:', error);
    res.status(401).json({ message: 'Invalid Google token' });
  }
};


module.exports = googleAuth;