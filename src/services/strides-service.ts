import mongoose from 'mongoose';
import { Strides } from '@/models';

class StridesService {
  static async ensure(userId: string | mongoose.Types.ObjectId) {
    return Strides.findOneAndUpdate(
      { userId },
      { $setOnInsert: { userId } },
      { upsert: true, new: true }
    );
  }

  static async add(
    userId: string | mongoose.Types.ObjectId,
    points: number,
    reason: string,
    referenceId?: string,
    metadata: Record<string, any> = {}
  ) {
    if (!points) return this.ensure(userId);
    const userStrides: any = await this.ensure(userId);
    userStrides.total = Math.max(0, (userStrides.total || 0) + points);
    userStrides.events.push({ reason, points, referenceId, metadata });
    await userStrides.save();
    return userStrides;
  }

  static async addOnce(
    userId: string | mongoose.Types.ObjectId,
    points: number,
    reason: string,
    milestoneKey: string,
    referenceId?: string,
    metadata: Record<string, any> = {}
  ) {
    const userStrides: any = await this.ensure(userId);
    const alreadyAwarded = userStrides.milestones.some((m: any) => m.key === milestoneKey);
    if (alreadyAwarded) return userStrides;
    userStrides.milestones.push({ key: milestoneKey });
    userStrides.total = Math.max(0, (userStrides.total || 0) + points);
    userStrides.events.push({ reason, points, referenceId, metadata });
    await userStrides.save();
    return userStrides;
  }

  static async recordTaggedTransaction(userId: string | mongoose.Types.ObjectId, transactionId: string) {
    const userStrides: any = await this.ensure(userId);
    const transactionKey = `tagged-transaction:${transactionId}`;
    if (userStrides.milestones.some((m: any) => m.key === transactionKey)) return userStrides;

    userStrides.milestones.push({ key: transactionKey });
    const taggedCount = userStrides.milestones.filter((m: any) => String(m.key).startsWith('tagged-transaction:')).length;
    if (taggedCount % 3 === 0) {
      userStrides.total += 1;
      userStrides.events.push({ reason: 'TAGGED_THREE_TRANSACTIONS', points: 1, referenceId: transactionId, metadata: { taggedCount } });
    }

    await userStrides.save();
    return userStrides;
  }
}

export default StridesService;
