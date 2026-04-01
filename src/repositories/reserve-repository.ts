import { Reserve } from "../models/reserve-model";
import CrudRepository from "./crud-repository";

class ReserveRepository extends CrudRepository<typeof Reserve> {
  constructor() {
    super(Reserve);
  }

  async getReserves(userId: string) {
    return Reserve.find({ userId }).sort({ createdAt: -1 });
  }

  async getReserveById(rid: string) {
    return Reserve.findOne({ _id: rid });
  }

  async deleteReserves(userId: string) {
    return Reserve.deleteMany({ userId });
  }
}

export default ReserveRepository;