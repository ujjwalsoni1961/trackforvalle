import { GoogleGenAI } from "@google/genai";

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "";

interface ParsedLead {
  customerName: string;
  email: string;
  phone: string;
  streetAddress: string;
  city: string;
  state: string;
  postalCode: string;
  country: string;
  comments: string;
}

interface ParseExcelResult {
  leads: ParsedLead[];
  headerRow: number;
  detectedColumns: { original: string; mappedTo: string }[];
}

export class GeminiService {
  private ai: GoogleGenAI;

  constructor() {
    this.ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY });
  }

  async parseExcelData(rawRows: any[][]): Promise<ParseExcelResult> {
    // Send first few rows for header detection, then all data
    const sampleForAnalysis = rawRows.slice(0, Math.min(rawRows.length, 8));
    const allRows = rawRows;

    const prompt = `You are an expert data parser. I have spreadsheet data that contains address/lead information.
The data comes from Finnish sales teams and may have Finnish column names.

Here are the first rows of the spreadsheet (each row is a JSON array):
${sampleForAnalysis.map((row, i) => `Row ${i + 1}: ${JSON.stringify(row)}`).join("\n")}

TASK 1 - HEADER DETECTION:
Identify which row (1-based) contains the column headers. Title rows (with just one non-empty cell) are NOT headers. The header row has multiple meaningful column names.

TASK 2 - COLUMN MAPPING:
Map each column header to one of these system fields:
- customerName (person's name)
- email
- phone 
- streetAddress (street name + number)
- city
- state (province/region)
- postalCode (zip code)
- country
- comments (notes, remarks)
- skip (columns not useful for lead import, like contact dates)

TASK 3 - PARSE ALL DATA:
Now parse ALL the following data rows into clean lead records.
${allRows.map((row, i) => `Row ${i + 1}: ${JSON.stringify(row)}`).join("\n")}

CRITICAL RULES:
- Skip completely empty rows
- Skip the title row(s) and header row
- If a cell contains a full address (e.g., "Hiirihaukankuja 2, 16320 Orimattila"), split it into streetAddress, postalCode, and city
- If a comments/notes cell contains an email address, extract it into the email field
- If a comments/notes cell contains a phone number (Finnish format: 04xx, 050x, +358), extract it into the phone field  
- If a comments/notes cell contains a person's name (e.g., "Tuomo", "Tanja Hämäläinen"), extract it into customerName
- Postal codes must be strings (e.g., "16320" not 16320 or 16320.0)
- If a value looks like a date or "ev" (Finnish: ei vastannut = no answer), it's not useful data for the lead - skip or put in comments
- Keep the remaining text in comments after extracting email/phone/name
- For country, default to "Finland" if not specified
- Return ONLY valid data rows as lead objects

Respond with ONLY valid JSON (no markdown, no backticks, no explanation) in this exact format:
{
  "headerRow": <1-based row number>,
  "detectedColumns": [{"original": "column name", "mappedTo": "systemField or skip"}],
  "leads": [
    {
      "customerName": "",
      "email": "",
      "phone": "",
      "streetAddress": "",
      "city": "",
      "state": "",
      "postalCode": "",
      "country": "",
      "comments": ""
    }
  ]
}`;

    try {
      const response = await this.ai.models.generateContent({
        model: "gemini-2.5-pro",
        contents: prompt,
        config: {
          temperature: 0.1,
          maxOutputTokens: 65536,
        },
      });

      const text = response.text || "";
      
      // Clean up response - remove markdown code blocks if present
      let cleanText = text.trim();
      if (cleanText.startsWith("```json")) {
        cleanText = cleanText.slice(7);
      } else if (cleanText.startsWith("```")) {
        cleanText = cleanText.slice(3);
      }
      if (cleanText.endsWith("```")) {
        cleanText = cleanText.slice(0, -3);
      }
      cleanText = cleanText.trim();

      const parsed = JSON.parse(cleanText) as ParseExcelResult;
      
      // Validate and clean the results
      parsed.leads = parsed.leads
        .filter(lead => lead.streetAddress && lead.streetAddress.trim() !== "")
        .map(lead => ({
          customerName: (lead.customerName || "").trim(),
          email: (lead.email || "").trim(),
          phone: (lead.phone || "").trim(),
          streetAddress: (lead.streetAddress || "").trim(),
          city: (lead.city || "").trim(),
          state: (lead.state || "").trim(),
          postalCode: (lead.postalCode || "").toString().replace(/\.0*$/, "").trim(),
          country: (lead.country || "Finland").trim(),
          comments: (lead.comments || "").trim(),
        }));

      return parsed;
    } catch (error: any) {
      console.error("Gemini parsing error:", error);
      throw new Error(`AI parsing failed: ${error.message}`);
    }
  }
}
