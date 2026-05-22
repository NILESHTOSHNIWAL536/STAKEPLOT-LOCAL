import axios, { AxiosResponse } from 'axios';

interface ApiClient {
  get<T = any>(url: string, token?: string): Promise<AxiosResponse<T>>;
  post<T = any>(url: string, token?: string | null, data?: any): Promise<AxiosResponse<T>>;
}

const apiClient: ApiClient = {
  async get(url, token) {
    return axios.get(url, {
      headers: {
        Authorization: token,
        'Content-Type': 'application/json',
      },
    });
  },

  async post(url, token, data) {
    return axios.post(url, data, {
      headers: {
        Authorization: token,
        'Content-Type': 'application/json',
      },
    });
  },
};

export default apiClient;
