import ReserveRepository from "../repositories/reserve-repository";

const reserveRepo = new ReserveRepository();

export class ReserveService {
  static async createReserve(data: any) {
    return await reserveRepo.create(data);
  }

  static async getReserves(userId: string) {
    return await reserveRepo.getReserves(userId);
  }

  static async getReserveById(userId: string, rid: string) {
    return await reserveRepo.getReserveById(rid, userId);
  }

  static async deleteReserve(userId: string, rid: string) {
    return await reserveRepo.deleteOne({ _id: rid, userId });
  }
}
