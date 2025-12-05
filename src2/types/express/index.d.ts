import { AuthUser } from "../user/user";

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}
