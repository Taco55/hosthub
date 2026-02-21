type TokenBucket = {
  tokens: number;
  lastRefill: number;
};

const buckets = new Map<string, TokenBucket>();

export function checkRateLimit(
  key: string,
  options: { capacity?: number; refillPerMinute?: number } = {},
) {
  const capacity = options.capacity ?? 120;
  const refillPerMinute = options.refillPerMinute ?? 120;
  const now = Date.now();
  const bucket = buckets.get(key) ?? { tokens: capacity, lastRefill: now };

  const elapsedMinutes = (now - bucket.lastRefill) / 60000;
  if (elapsedMinutes > 0) {
    bucket.tokens = Math.min(capacity, bucket.tokens + elapsedMinutes * refillPerMinute);
    bucket.lastRefill = now;
  }

  if (bucket.tokens < 1) {
    buckets.set(key, bucket);
    return false;
  }

  bucket.tokens -= 1;
  buckets.set(key, bucket);
  return true;
}
