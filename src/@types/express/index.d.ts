import { AuthUser } from "../../types/user/user";

declare global {
  namespace Express {
    interface Request {
      user: AuthUser;
    }
  }
}

export {};
