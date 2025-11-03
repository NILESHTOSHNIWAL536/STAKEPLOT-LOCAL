const { User, sendingNotification, UserActivity } = require('../../models');

async function getFriendsWithUserId(id) {
  const user = await User.findOne({ _id: id });
  const friendsList = user.friendsList;

  const deviceIds = [];

  for (const friend of friendsList) {
    deviceIds.push(friend._id);
  }

  if (deviceIds) return deviceIds;
  return [];
}

async function getDeviceIdsFriends(id) {
  const user = await User.findOne({ _id: id });
  const friendsList = user.friendsList;
  const deviceIds = [];

  // Fetch deviceIds of friendsList of the User
  for (const friend of friendsList) {
    const friendNotification = await sendingNotification.findOne({ userId: friend._id });
    if (friendNotification) {
      friendNotification.deviceLogins.forEach((device) => {
        deviceIds.push(device.deviceId);
      });
    }
  }
  if (deviceIds) return deviceIds;
  return [];
}

async function getDeviceIdsByUserId(userId) {
  const deviceIds = [];
  const friendNotification = await sendingNotification.findOne({ userId });
  if (!friendNotification) return [];
  friendNotification.deviceLogins.forEach((device) => {
    deviceIds.push(device.deviceId);
  });
  if (deviceIds) return deviceIds;
  return [];
}

async function getDeviceIdsofCupons() {
  try {
    const users = await UserActivity.find({ unclaimedCount: { $gt: 0 } }, { userId: 1, _id: 0 }).lean();

    const userIds = [...new Set(users.map((u) => u.userId))];
    let allDeviceIds = [];

    for (const userId of userIds) {
      if (userId != 'deviceData.value') {
        const deviceIds = await getDeviceIdsByUserId(userId);
        allDeviceIds.push(...deviceIds);
      }
    }
    const uniqueDeviceIds = [...new Set(allDeviceIds)];
    if (uniqueDeviceIds) return uniqueDeviceIds;
    return [];
  } catch (e) {
    return [];
  }
}

module.exports = {
  getDeviceIdsFriends,
  getDeviceIdsByUserId,
  getFriendsWithUserId,
  getDeviceIdsofCupons,
};
