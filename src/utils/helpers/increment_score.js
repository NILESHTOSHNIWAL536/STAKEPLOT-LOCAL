const { UserActivity } = require("../../models/index");
const logger = require("../common/logger");
const moment = require("moment");
const { scoreToAdd } = require("../common/enums");
const getCurrentDate = () => moment().format("YYYY-MM-DD");
const WebSocketService = require("../../services/websocket-service");
const jwt = require("jsonwebtoken");
const axios = require("axios");

const baseUrl = process.env.REWARD_BASE_URL;

const generateServiceToken = () => {
  const token = jwt.sign(
    {
      service: "mobile-backend",
    },
    process.env.SERVICE_JWT_SECRET,
    { expiresIn: "10m" }
  );

  return token;
};

const incrementScore = async (userId, scoreToAdd) => {
  try {
    let user = await UserActivity.findOne({ userId });

    if (!user) {
      user = new UserActivity({ userId });
    }

    user.score += scoreToAdd;

     if (!user.hasReached50 &&  user.score >= 50) {
      user.hasReached50 = true;
      user.unclaimedCount += 1;
    }

    user.lastActivityDate = getCurrentDate();
    await user.save();

    return user.score;
  } catch (error) {
    logger.error(`failed for inc score ${error.message}`);
  }
};




const getCouponsCount = async () => {
    try{
       const token = generateServiceToken();
        const response = await axios.get(
          `${baseUrl}/coupon/get-unclaimed-coupons-count`,
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
        );
        return response;
    }catch(e){
        return {'data':0};
    }
}

const postScoreCounter = async (userId, postId, isDelete) => {
  try {
    let user = await UserActivity.findOne({ userId });

    if (!user) {
      user = new UserActivity({ userId });
    }

    if (isDelete) {
      const matchedPost = user.pendingPosts.find(
        (post) => post.postId.toString() === postId.toString()
      );
      if (!matchedPost) return;
      const now = new Date();
      const postAgeHours = (now - matchedPost.createdAt) / (1000 * 60 * 60);
      if (postAgeHours <= 48) {
        user.score -= scoreToAdd.Post;
      }
    } else {
      user.pendingPosts.push({
        postId,
        createdAt: new Date(),
        processed: false,
      });
    }
    user.lastActivityDate = getCurrentDate();
    await user.save();
  } catch (error) {
    logger.error(`failed for inc score ${error.message}`);
  }
};




const handleDailyCounter = async (
  userId,
  counterField,
  scoreToAdd,
  objectId,
  incScoreCount,
  countBreak
) => {
  try {
    // Initialize counter array if it doesn't exist
    const currentDate = getCurrentDate();
    let user = await UserActivity.findOne({ userId });

    if (!user) {
      user = new UserActivity({ userId });
      await user.save();
    }

    if (!user[counterField]) {
      user[counterField] = [];
    }

    let transactionList = user.transactionIdList;
    // Find or create daily counter record
    let dailyCounter = user[counterField].find(
      (counter) => counter.date === currentDate
    );
    if (!dailyCounter) {
      dailyCounter = { date: currentDate, count: 0 };
      user[counterField].push(dailyCounter);
    }
    
    let dailyClaimCountString="dailyClaimCount";
    if (!user[dailyClaimCountString]) 
    {
      user[dailyClaimCountString] = [];
    }

    let dailyClaimCount = user[dailyClaimCountString].find(
      (counter) => counter.date === currentDate
    );

    if (!dailyClaimCount)
    {
      dailyClaimCount = { date: currentDate, count: 0 };
      user[dailyClaimCountString].push(dailyClaimCount);
    }


    const find =
      objectId == "" ||
      transactionList?.some((id) => id?.toString() === objectId?.toString());
    dailyCounter.count += objectId == "" || !find ? scoreToAdd : 0;
    if (!find) user.transactionIdList.push(objectId);
   

    if (dailyCounter.count >= countBreak) {
      try {
        const response= await getCouponsCount();
       
        if (response.data > 0 ) {
          user.unclaimedCount++;
          dailyCounter.count = 0;
          if(dailyClaimCount.count<2)
            {
              setTimeout(() => {
                WebSocketService.sendMessage(userId, "addUserToSocket", {
                  type: "Reward",
                  data: {
                    count: user.unclaimedCount,
                  }, 
                });
              }, 1000); 
            }
        }

        
      } catch (e) {
      }
    }
    if (objectId == "" || !find) await incrementScore(userId, incScoreCount);
    user[counterField].find((tag) => tag.date === currentDate).count =
      dailyCounter.count;
    await user.save();
    return dailyCounter.count;
  } catch (error) {
    throw new Error(
      `Failed to handle daily counter for ${counterField}: ${error.message}`
    );
  }
};

const handleDailyClaimCount = async (
  userId,
  counterField,
  countBreak
) => {
  try {
    const currentDate = getCurrentDate();
    let user = await UserActivity.findOne({ userId });

    if (!user)
    {
      user = new UserActivity({ userId });
      await user.save();
    }

    if (!user[counterField]) {
      user[counterField] = [];
    }

    let dailyCounter = user[counterField].find(
      (counter) => counter.date === currentDate
    );

    if (!dailyCounter)
    {
      dailyCounter = { date: currentDate, count: 0 };
      user[counterField].push(dailyCounter);
    }

    dailyCounter.count += 1;

    if (dailyCounter.count <= countBreak)
    {
       await user.save();
    }
    return dailyCounter.count;
  } catch (error) {
    throw new Error(
      `Failed to handle daily counter for ${counterField}: ${error.message}`
    );
  }
};

module.exports = {
  incrementScore,
  handleDailyCounter,
  getCurrentDate,
  postScoreCounter,
  handleDailyClaimCount,
  getCouponsCount
};
