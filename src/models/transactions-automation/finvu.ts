import mongoose from 'mongoose';

const FinvuSchema = new mongoose.Schema(
  {
    sessionId: { type: String, required: true, unique: true },
    custId: { type: String, required: true },
    consentId: { type: String, required: true },
    isUpdate: { type: Boolean, required: true },
    handleId: { type: String, required: true },
    data: { type: Object, default: {} },
    userId: { type: mongoose.Types.ObjectId, },
    expiresAt: {
      type: Date,
      default: () => new Date(Date.now() + 24 * 60 * 60 * 1000),
      index: { expires: '1d' },
    },
  },
  { timestamps: true }
);

const Finvu = mongoose.model('Finvu', FinvuSchema);
export default Finvu;
