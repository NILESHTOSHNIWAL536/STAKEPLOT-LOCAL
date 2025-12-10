import { Types } from "mongoose";

export interface SearchFilters {
  minAmount?: number;
  maxAmount?: number;
  startDate?: Date;
  endDate?: Date;
  keywords?: string;
  accountId?: Types.ObjectId;
  isCash?: boolean;
}

export interface SearchPipelineInput {
  userId: Types.ObjectId;
  searchFilter?: any[];
  accountId?: Types.ObjectId;
  minAmount?: number;
  maxAmount?: number;
  startDate?: Date;
  endDate?: Date;
  isCash: boolean;
}
