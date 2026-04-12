import dotenv from "dotenv";
dotenv.config();

const DOCUSEAL_API_URL = process.env.DOCUSEAL_API_URL || "";
const DOCUSEAL_API_KEY = process.env.DOCUSEAL_API_KEY || "";

function getHeaders() {
  return {
    "X-Auth-Token": DOCUSEAL_API_KEY,
    "Content-Type": "application/json",
  };
}

export async function listTemplates() {
  const res = await fetch(`${DOCUSEAL_API_URL}/api/templates`, {
    headers: getHeaders(),
  });
  if (!res.ok) throw new Error(`DocuSeal listTemplates failed: ${res.status}`);
  return res.json();
}

export async function getTemplate(id: number) {
  const res = await fetch(`${DOCUSEAL_API_URL}/api/templates/${id}`, {
    headers: getHeaders(),
  });
  if (!res.ok) throw new Error(`DocuSeal getTemplate failed: ${res.status}`);
  return res.json();
}

export async function createSubmission(
  templateId: number,
  submitters: Array<{ email: string; name?: string; role?: string; fields?: any[] }>,
  metadata?: Record<string, any>
) {
  const body: any = {
    template_id: templateId,
    submitters,
  };
  if (metadata) {
    body.metadata = metadata;
  }
  const res = await fetch(`${DOCUSEAL_API_URL}/api/submissions`, {
    method: "POST",
    headers: getHeaders(),
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`DocuSeal createSubmission failed: ${res.status} - ${text}`);
  }
  return res.json();
}

export async function getSubmission(id: number) {
  const res = await fetch(`${DOCUSEAL_API_URL}/api/submissions/${id}`, {
    headers: getHeaders(),
  });
  if (!res.ok) throw new Error(`DocuSeal getSubmission failed: ${res.status}`);
  return res.json();
}

export async function listSubmissions(params?: { template_id?: number; limit?: number; after?: number }) {
  const url = new URL(`${DOCUSEAL_API_URL}/api/submissions`);
  if (params?.template_id) url.searchParams.set("template_id", String(params.template_id));
  if (params?.limit) url.searchParams.set("limit", String(params.limit));
  if (params?.after) url.searchParams.set("after", String(params.after));

  const res = await fetch(url.toString(), { headers: getHeaders() });
  if (!res.ok) throw new Error(`DocuSeal listSubmissions failed: ${res.status}`);
  return res.json();
}

export async function getSubmissionDocuments(submissionId: number) {
  // DocuSeal returns documents within the submission response
  const submission = await getSubmission(submissionId);
  return submission;
}

export async function downloadDocument(documentUrl: string): Promise<Buffer> {
  const res = await fetch(documentUrl, { headers: getHeaders() });
  if (!res.ok) throw new Error(`DocuSeal downloadDocument failed: ${res.status}`);
  const arrayBuffer = await res.arrayBuffer();
  return Buffer.from(arrayBuffer);
}

export async function archiveSubmission(id: number) {
  const res = await fetch(`${DOCUSEAL_API_URL}/api/submissions/${id}`, {
    method: "DELETE",
    headers: getHeaders(),
  });
  if (!res.ok) throw new Error(`DocuSeal archiveSubmission failed: ${res.status}`);
  return res.json();
}
