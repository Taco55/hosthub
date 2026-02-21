export function env(name: string, fallback?: string): string | undefined {
  const value = Deno.env.get(name);
  if (value !== undefined) return value;

  if (fallback) {
    const fallbackValue = Deno.env.get(fallback);
    if (fallbackValue !== undefined) return fallbackValue;
  }

  return undefined;
}
