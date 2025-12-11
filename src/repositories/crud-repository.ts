import { Model } from 'mongoose';
import AppError from '../utils/errors/app-error';
import { StatusCodes } from 'http-status-codes';
import { Types } from 'mongoose';

class CrudRepository<T extends Model<any>> {
  protected model: T;

  constructor(model: T) {
    this.model = model;
  }

  async create(data: any) {
    return this.model.create(data);
  }

  async deleteOne(query: any) {
    return this.model.deleteOne(query);
  }

  async deleteMany(query: any) {
    return this.model.deleteMany(query);
  }

  async get(query: any, options: any = {}) {
    let queryBuilder = this.model.find(query);

    if (options?.populate) {
      queryBuilder = queryBuilder.populate(options.populate);
    }

    if (options?.sort) {
      queryBuilder = queryBuilder.sort(options.sort);
    }

    if (options?.limit) {
      queryBuilder = queryBuilder.limit(options.limit);
    }

    if (options?.lean) {
      queryBuilder = queryBuilder.lean();
    }

    const response = await queryBuilder.exec();
    if (!response) {
      throw new AppError('Not able to find resource', StatusCodes.NOT_FOUND);
    }
    return response;
  }

  async getOne(query: any) {
    const response = await this.model.findOne(query);
    if (!response) throw new AppError('Not able to find resource', StatusCodes.NOT_FOUND);
    return response;
  }

  async getById(query: any) {
    const response = await this.model.findById(query);
    if (!response) throw new AppError('Not able to find resource', StatusCodes.NOT_FOUND);
    return response;
  }

  async getByIdAndUpdate(id: string, data: any) {
    const response = await this.model.findByIdAndUpdate(id, data, {
      new: true,
      runValidators: true,
    });
    if (!response) throw new AppError('Not able to find and update resource', StatusCodes.NOT_FOUND);
    return response;
  }

  async getAndDelete(query: any) {
    const response = await this.model.findOneAndDelete(query);
    if (!response) throw new AppError('Not able to find and update resource', StatusCodes.NOT_FOUND);
    return response;
  }

  async updateOne(query: any, data: any) {
    const response = await this.model.findOneAndUpdate(query, { $set: data }, { new: true }).exec();
    if (!response) throw new AppError('Source not found or you are not the author', StatusCodes.NOT_FOUND);
    return response;
  }

  async updateMany(query: any, data: any) {
    const response = await this.model.updateMany(query, { $set: data }, { new: true }).exec();
    if (!response) throw new AppError('Source not found or you are not the author', StatusCodes.NOT_FOUND);
    return response;
  }
}

export default CrudRepository;
