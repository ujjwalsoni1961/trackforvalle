import multer from "multer";
import path from "path";
import dotenv from "dotenv";
import {
  getSupabaseServiceClient,
  STORAGE_BUCKETS,
} from "../config/supabase";

dotenv.config();

// Use memory storage - files are buffered in memory then uploaded to Supabase
const memoryStorage = multer.memoryStorage();

/**
 * Helper to upload a file buffer to Supabase Storage and attach a `location`
 * property (public URL) to the multer file object, keeping the same interface
 * that controllers/services expect from the old S3 multer setup.
 */
async function uploadToSupabase(
  file: Express.Multer.File,
  bucket: string,
  keyPrefix: string = ""
): Promise<void> {
  const supabase = getSupabaseServiceClient();
  const uniqueName = `${keyPrefix}${Date.now().toString()}_${path.basename(
    file.originalname
  )}`;

  const { error } = await supabase.storage
    .from(bucket)
    .upload(uniqueName, file.buffer, {
      contentType: file.mimetype,
      upsert: false,
    });

  if (error) {
    throw new Error(`Supabase Storage upload failed: ${error.message}`);
  }

  const {
    data: { publicUrl },
  } = supabase.storage.from(bucket).getPublicUrl(uniqueName);

  // Attach the public URL as `location` so existing code (signatureFile.location, p.location) works unchanged
  (file as any).location = publicUrl;
  (file as any).key = uniqueName;
  (file as any).bucket = bucket;
}

/**
 * Multer middleware for visit photos → uploads to Supabase "visit-logs-images" bucket.
 * After multer parses the file into memory, a post-processing step uploads it.
 */
export const upload = multer({ storage: memoryStorage });

/**
 * Multer middleware for contract signature images → memory storage.
 */
export const uploadContractImage = multer({ storage: memoryStorage });

/**
 * Multer middleware for contract PDFs → memory storage with PDF-only filter.
 */
export const uploadContractPdf = multer({
  storage: memoryStorage,
  fileFilter: (req, file, cb) => {
    if (file.mimetype === "application/pdf") {
      cb(null, true);
    } else {
      cb(new Error("Only PDF files are allowed"));
    }
  },
});

/**
 * Middleware to upload parsed files to Supabase Storage.
 * Call this AFTER multer parses the files but BEFORE the controller.
 */
export function supabaseUploadMiddleware(bucket: string, keyPrefix: string = "") {
  return async (req: any, res: any, next: any) => {
    try {
      // Handle single file
      if (req.file) {
        await uploadToSupabase(req.file, bucket, keyPrefix);
      }
      // Handle array of files
      if (req.files && Array.isArray(req.files)) {
        for (const file of req.files) {
          await uploadToSupabase(file, bucket, keyPrefix);
        }
      }
      next();
    } catch (error: any) {
      console.error("Supabase upload middleware error:", error);
      return res.status(500).json({ message: `File upload failed: ${error.message}` });
    }
  };
}

/**
 * Upload a raw buffer to Supabase Storage. Returns the public URL.
 */
export const uploadFileBufferToS3 = async (
  buffer: Buffer,
  key: string
): Promise<{ publicUrl: string }> => {
  const supabase = getSupabaseServiceClient();
  const bucket = STORAGE_BUCKETS.VISIT_LOGS;

  const { error } = await supabase.storage.from(bucket).upload(key, buffer, {
    upsert: false,
  });

  if (error) {
    throw new Error(`Supabase Storage upload failed: ${error.message}`);
  }

  const {
    data: { publicUrl },
  } = supabase.storage.from(bucket).getPublicUrl(key);

  return { publicUrl };
};

/**
 * Delete a file from Supabase Storage by its public URL.
 */
export const deleteFileFromS3 = async (objectUrl: string): Promise<void> => {
  const supabase = getSupabaseServiceClient();

  // Extract bucket and path from the Supabase public URL
  // URL format: https://<project>.supabase.co/storage/v1/object/public/<bucket>/<path>
  const url = new URL(objectUrl);
  const pathParts = url.pathname.split("/storage/v1/object/public/");
  if (pathParts.length < 2) {
    throw new Error("Invalid Supabase Storage URL");
  }

  const [bucket, ...rest] = pathParts[1].split("/");
  const objectPath = rest.join("/");

  const { error } = await supabase.storage.from(bucket).remove([objectPath]);

  if (error) {
    throw new Error(`Supabase Storage delete failed: ${error.message}`);
  }
};
