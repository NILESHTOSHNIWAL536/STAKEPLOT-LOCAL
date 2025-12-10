import { Model } from 'mongoose';
import TransactionRepository from './transaction-repository';
import NotificationRepository from './notification-repository';
import AutoTransactionRepository from './autoTransactions-repository/transaction';
import SummaryRepository from './autoTransactions-repository/summary';
import AccountRepository from './autoTransactions-repository/account';
import FipRepository from './autoTransactions-repository/bank';
import ProfileRepository from './autoTransactions-repository/profile';
import GetCustomDatesTransactions from './autoTransactions-repository/get-custom-transactions';

import { Transaction, TransactionRule, RecurringPayment } from '@/models';

const autoTransactionRepo = new AutoTransactionRepository(Transaction, TransactionRule, RecurringPayment, FipRepository);

export {
  TransactionRepository,
  NotificationRepository,
  autoTransactionRepo,
  SummaryRepository,
  AccountRepository,
  FipRepository,
  ProfileRepository,
  GetCustomDatesTransactions,
};
