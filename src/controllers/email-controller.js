const { StatusCodes } = require('http-status-codes');
const { SuccessResponse, ErrorResponse } = require('../utils/api-response');


// Google authentication
async function googleEmailAuthToken(req, res) {
  try {
    const userId = req.user._id;
    const { idToken } = req.body;
    const result = await EmailScrapingService.handleGoogleEmailAuth(userId, idToken);
    SuccessResponse.data = result;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    console.log(error);
    ErrorResponse.error = error.response.data.error || error;
    return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
  }
}   


module.exports = {
  googleEmailAuthToken,
};