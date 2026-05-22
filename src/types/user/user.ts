export interface AuthUser {
  _id: string;
  token?: string;
  roles?: string[];
  scopes?: string[];
}

