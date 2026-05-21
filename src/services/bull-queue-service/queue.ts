import Queue from 'bull';

// Deferred so process.env.REDIS_PASSWORD is populated by loadSecrets() before connection.
const getConnection = () => ({
  host: process.env.REDIS_HOST || '127.0.0.1',
  port: Number(process.env.REDIS_PORT) || 6379,
  password: process.env.REDIS_PASSWORD || undefined,
});

let _queue: InstanceType<typeof Queue> | null = null;

const getQueue = (): InstanceType<typeof Queue> => {
  if (!_queue) _queue = new Queue('email-scraping', { redis: getConnection() });
  return _queue;
};

const CreditCardQueue = new Proxy({} as InstanceType<typeof Queue>, {
  get(_target, prop: string) {
    const q = getQueue();
    const value = (q as any)[prop];
    return typeof value === 'function' ? value.bind(q) : value;
  },
});

export default CreditCardQueue;
