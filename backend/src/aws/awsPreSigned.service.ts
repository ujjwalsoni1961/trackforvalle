import { getSupabaseServiceClient } from "../config/supabase";

/**
 * Extract bucket name and object path from a Supabase Storage public URL.
 * URL format: https://<project>.supabase.co/storage/v1/object/public/<bucket>/<path>
 */
const extractBucketAndPath = (
  objectUrl: string
): { bucket: string; path: string } => {
  const url = new URL(objectUrl);
  const publicPrefix = "/storage/v1/object/public/";
  const idx = url.pathname.indexOf(publicPrefix);

  if (idx === -1) {
    // Not a public URL – treat entire pathname as path in a default bucket
    return { bucket: "visit-logs-images", path: url.pathname.substring(1) };
  }

  const rest = url.pathname.substring(idx + publicPrefix.length);
  const slashIdx = rest.indexOf("/");
  if (slashIdx === -1) {
    return { bucket: rest, path: "" };
  }
  return { bucket: rest.substring(0, slashIdx), path: rest.substring(slashIdx + 1) };
};

/**
 * Generates a signed URL for accessing a file in Supabase Storage.
 * For public buckets this returns the public URL directly.
 * For private buckets it creates a time-limited signed URL.
 *
 * @param objectUrl - The full public URL or storage path of the object.
 * @param expiresIn - Expiration time in seconds (default 36000 = 10 hours).
 * @returns The signed or public URL string.
 */
export const generatePresignedUrl = async (
  objectUrl: string,
  expiresIn = 36000
): Promise<string> => {
  if (
    !objectUrl ||
    typeof objectUrl !== "string" ||
    objectUrl.trim() === ""
  ) {
    throw new Error(
      "Invalid object URL. It cannot be empty or undefined."
    );
  }

  const supabase = getSupabaseServiceClient();
  const { bucket, path } = extractBucketAndPath(objectUrl);

  // Try to create a signed URL (works for both public and private buckets)
  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrl(path, expiresIn);

  if (error) {
    // If signed URL fails, return the original URL as fallback (public bucket)
    console.warn("Signed URL generation failed, returning original URL:", error.message);
    return objectUrl;
  }

  return data.signedUrl;
};
