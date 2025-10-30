// const {
//   SecretsManagerClient,
//   GetSecretValueCommand,
// } = require("@aws-sdk/client-secrets-manager");

// module.exports = async () => {
//   const secret_name = "test-secret";
//   const client = new SecretsManagerClient({
//     region: "eu-north-1",
//   });
//   let response;
//   try {
// 	response = await client.send(
// 	  new GetSecretValueCommand({
// 		SecretId: secret_name,
// 		VersionStage: "AWSCURRENT",
// 	  })
// 	);
// 	const secret = response.SecretString;
// 	const secretsJSON = JSON.parse(secret);
// 	let secretsString = "";
// 	Object.keys(secretsJSON).forEach((key) => {
// 	  secretsString += `${key}=${secretsJSON[key]}\n`;
// 	});
// 	return secretsString
//   } catch (error) {
// 	throw error;
//   }
// };


