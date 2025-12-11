import { Request } from "express";

const r = {} as Request;
r.user._id;   // should NOT error
