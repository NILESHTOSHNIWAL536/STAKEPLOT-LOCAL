import { Reserve } from "../models/reserve-model";
import CrudRepository from "./crud-repository";

class ReserveRepository extends CrudRepository<typeof Reserve> {
  constructor() {
    super(Reserve);
  }

  async getReserves(userId: string) {
    return Reserve.find({ userId }).sort({ createdAt: -1 });
  }

  async getReserveById(rid: string, userId?: string) {
    const query: any = { _id: rid };
    if (userId) query.userId = userId;
    return Reserve.findOne(query);
  }

  async deleteReserves(userId: string) {
    return Reserve.deleteMany({ userId });
  }
}

export default ReserveRepository;
