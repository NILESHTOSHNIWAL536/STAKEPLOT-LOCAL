const axios = require("axios");

const apiClient = {
    get: async (url, token) => {
        return await axios.get(url, { headers: { Authorization: token, "Content-Type": "application/json" } });
    },
    post: async (url, token, data) => {
        return await axios.post(url, data, { headers: { Authorization: token, "Content-Type": "application/json" } });
    },
};

module.exports = apiClient;
