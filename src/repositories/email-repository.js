async function upsertGoogleToken(userId, email, refresh_token) {
  const { encryptedData, iv, authTag } = await encryptToken(refresh_token);
  return await GoogleToken.findOneAndUpdate(
    { userId, email }, // filter by User ID and email
    {
      $set: {
        refreshToken: { encryptedData, iv, authTag },
      },
    },
    {
      upsert: true, // create a new document if not exists
      new: true, // return the updated document (optional)
    }
  );
}
