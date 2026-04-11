import { createClient, SupabaseClient } from "@supabase/supabase-js";
import dotenv from "dotenv";

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl) {
  throw new Error("SUPABASE_URL is not defined in environment variables");
}

// Service role client for backend operations (storage, admin auth)
let serviceClient: SupabaseClient | null = null;

export const getSupabaseServiceClient = (): SupabaseClient => {
  if (!serviceClient) {
    const key = supabaseServiceRoleKey || supabaseAnonKey;
    if (!key) {
      throw new Error(
        "Neither SUPABASE_SERVICE_ROLE_KEY nor SUPABASE_ANON_KEY is defined"
      );
    }
    serviceClient = createClient(supabaseUrl, key, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });
  }
  return serviceClient;
};

// Anon client for auth operations (signUp, signIn, getUser)
let anonClient: SupabaseClient | null = null;

export const getSupabaseAnonClient = (): SupabaseClient => {
  if (!anonClient) {
    if (!supabaseAnonKey) {
      throw new Error("SUPABASE_ANON_KEY is not defined");
    }
    anonClient = createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });
  }
  return anonClient;
};

// Storage bucket names
export const STORAGE_BUCKETS = {
  CONTRACT_SIGNATURES: "contract-signature-images",
  VISIT_LOGS: "visit-logs-images",
} as const;
