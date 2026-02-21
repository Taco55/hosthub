type SupabaseAdminClient = {
  auth: {
    admin: {
      deleteUser(
        userId: string,
      ): Promise<{ error: { message: string } | null }>;
      updateUserById(
        userId: string,
        payload: Record<string, string>,
      ): Promise<{ error: { message: string } | null }>;
    };
  };
};

export async function deleteAuthUser(
  client: SupabaseAdminClient,
  userId: string,
) {
  const { error } = await client.auth.admin.deleteUser(userId);
  if (error) throw new Error(error.message);
}

export async function updateAuthUser(
  client: SupabaseAdminClient,
  userId: string,
  email?: string,
  password?: string,
) {
  const payload: Record<string, string> = {};
  if (email && typeof email === "string") payload.email = email;
  if (password && typeof password === "string") payload.password = password;
  if (Object.keys(payload).length === 0) return;
  const { error } = await client.auth.admin.updateUserById(userId, payload);
  if (error) throw new Error(error.message);
}
