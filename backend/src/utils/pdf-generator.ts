import { PDFDocument, rgb, StandardFonts, PDFImage } from "pdf-lib";
import axios from "axios";

/**
 * Strip HTML tags and decode entities for plain text extraction
 */
function stripHtml(html: string): string {
  return html
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<\/p>/gi, "\n\n")
    .replace(/<\/h[1-6]>/gi, "\n\n")
    .replace(/<\/li>/gi, "\n")
    .replace(/<\/tr>/gi, "\n")
    .replace(/<\/div>/gi, "\n")
    .replace(/<[^>]+>/g, "")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&nbsp;/g, " ")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

/**
 * Extract key sections from the styled contract HTML
 */
function extractContractSections(html: string): {
  title: string;
  date: string;
  body: string;
  hasSigned: boolean;
  signedDate: string;
  signatureImageUrl: string;
} {
  // Extract title
  const titleMatch = html.match(
    /<div[^>]*class="contract-title"[^>]*>([\s\S]*?)<\/div>/
  );
  const title = titleMatch ? stripHtml(titleMatch[1]) : "Contract";

  // Extract date
  const dateMatch = html.match(/Document Generated:[\s\S]*?<\/div>/);
  const date = dateMatch ? stripHtml(dateMatch[0]) : "";

  // Extract contract body (the rendered_html part)
  const bodyMatch = html.match(
    /<div[^>]*class="contract-body"[^>]*>([\s\S]*?)<\/div>[\s]*(?:<div[^>]*class="signature|<\/div>[\s]*<\/div>[\s]*<div[^>]*class="footer)/
  );
  const body = bodyMatch ? stripHtml(bodyMatch[1]) : "";

  // Check for signature
  const hasSigned = html.includes("✓ Verified") || html.includes("Verified");
  const signedMatch = html.match(/Signed:\s*([^<]+)/);
  const signedDate = signedMatch ? signedMatch[1].trim() : "";

  // Extract signature image URL (skip SVG data URIs)
  const imgMatches = html.match(/<img[^>]+src="(https?:\/\/[^"]+)"/g) || [];
  let signatureImageUrl = "";
  for (const imgTag of imgMatches) {
    const srcMatch = imgTag.match(/src="(https?:\/\/[^"]+)"/);
    if (srcMatch && srcMatch[1].includes("signature")) {
      signatureImageUrl = srcMatch[1];
      break;
    }
  }
  // Fallback: any non-SVG https image
  if (!signatureImageUrl) {
    for (const imgTag of imgMatches) {
      const srcMatch = imgTag.match(/src="(https?:\/\/[^"]+)"/);
      if (srcMatch) {
        signatureImageUrl = srcMatch[1];
        break;
      }
    }
  }

  return { title, date, body: body || stripHtml(html), hasSigned, signedDate, signatureImageUrl };
}

/**
 * Word-wrap text to fit within a given width
 */
function wrapText(
  text: string,
  font: any,
  fontSize: number,
  maxWidth: number
): string[] {
  const lines: string[] = [];
  const paragraphs = text.split("\n");

  for (const paragraph of paragraphs) {
    if (paragraph.trim() === "") {
      lines.push("");
      continue;
    }
    const words = paragraph.split(/\s+/);
    let currentLine = "";

    for (const word of words) {
      const testLine = currentLine ? `${currentLine} ${word}` : word;
      const width = font.widthOfTextAtSize(testLine, fontSize);

      if (width > maxWidth && currentLine) {
        lines.push(currentLine);
        currentLine = word;
      } else {
        currentLine = testLine;
      }
    }
    if (currentLine) {
      lines.push(currentLine);
    }
  }
  return lines;
}

/**
 * Generate a PDF Buffer from the styled contract HTML.
 * Uses pdf-lib (pure JS, no browser needed, works on Vercel serverless).
 */
export async function generateContractPdf(
  styledHtml: string
): Promise<Buffer> {
  const pdfDoc = await PDFDocument.create();
  const helvetica = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const helveticaBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);

  const pageWidth = 595; // A4
  const pageHeight = 842;
  const margin = 50;
  const contentWidth = pageWidth - 2 * margin;

  const { title, date, body, hasSigned, signedDate, signatureImageUrl } =
    extractContractSections(styledHtml);

  // Try to download and embed signature image
  let signatureImage: PDFImage | null = null;
  if (signatureImageUrl) {
    try {
      const imgResponse = await axios.get(signatureImageUrl, { responseType: "arraybuffer", timeout: 10000 });
      const imgBytes = new Uint8Array(imgResponse.data);
      // Detect image type from first bytes
      if (imgBytes[0] === 0x89 && imgBytes[1] === 0x50) {
        signatureImage = await pdfDoc.embedPng(imgBytes);
      } else {
        signatureImage = await pdfDoc.embedJpg(imgBytes);
      }
    } catch (imgErr) {
      console.error("Could not embed signature image:", imgErr);
    }
  }

  let page = pdfDoc.addPage([pageWidth, pageHeight]);
  let y = pageHeight - margin;

  // Helper: add new page if needed
  const ensureSpace = (needed: number) => {
    if (y - needed < margin) {
      page = pdfDoc.addPage([pageWidth, pageHeight]);
      y = pageHeight - margin;
    }
  };

  // --- Header bar ---
  page.drawRectangle({
    x: 0,
    y: pageHeight - 60,
    width: pageWidth,
    height: 60,
    color: rgb(0.1, 0.1, 0.18), // #1A1A2E
  });

  page.drawText("TRACK", {
    x: margin,
    y: pageHeight - 40,
    size: 20,
    font: helveticaBold,
    color: rgb(1, 1, 1),
  });

  page.drawText("Sales Agreement", {
    x: pageWidth - margin - helveticaBold.widthOfTextAtSize("Sales Agreement", 14),
    y: pageHeight - 38,
    size: 14,
    font: helveticaBold,
    color: rgb(0.7, 0.7, 0.8),
  });

  y = pageHeight - 80;

  // --- Date ---
  if (date) {
    page.drawText(date, {
      x: margin,
      y,
      size: 9,
      font: helvetica,
      color: rgb(0.5, 0.5, 0.5),
    });
    y -= 25;
  }

  // --- Title ---
  ensureSpace(30);
  page.drawText(title, {
    x: margin,
    y,
    size: 18,
    font: helveticaBold,
    color: rgb(0.1, 0.1, 0.1),
  });
  y -= 10;

  // Underline
  page.drawLine({
    start: { x: margin, y },
    end: { x: pageWidth - margin, y },
    thickness: 1,
    color: rgb(0.8, 0.8, 0.8),
  });
  y -= 20;

  // --- Body ---
  const bodyLines = wrapText(body, helvetica, 11, contentWidth);
  for (const line of bodyLines) {
    ensureSpace(16);
    if (line === "") {
      y -= 8;
      continue;
    }
    page.drawText(line, {
      x: margin,
      y,
      size: 11,
      font: helvetica,
      color: rgb(0.15, 0.15, 0.15),
    });
    y -= 16;
  }

  // --- Signature section ---
  if (hasSigned) {
    y -= 20;
    const sigBoxHeight = signatureImage ? 160 : 80;
    ensureSpace(sigBoxHeight);

    // Signature box
    page.drawRectangle({
      x: margin,
      y: y - sigBoxHeight + 10,
      width: contentWidth,
      height: sigBoxHeight,
      borderColor: rgb(0.7, 0.2, 0.2),
      borderWidth: 1,
      color: rgb(1, 0.98, 0.98),
    });

    page.drawText("DIGITAL SIGNATURE", {
      x: margin + 10,
      y: y - 5,
      size: 10,
      font: helveticaBold,
      color: rgb(0.3, 0.3, 0.3),
    });

    // Embed signature image
    if (signatureImage) {
      const imgDims = signatureImage.scale(1);
      const maxImgWidth = contentWidth - 40;
      const maxImgHeight = 80;
      const scale = Math.min(maxImgWidth / imgDims.width, maxImgHeight / imgDims.height, 1);
      const imgWidth = imgDims.width * scale;
      const imgHeight = imgDims.height * scale;

      page.drawImage(signatureImage, {
        x: margin + 15,
        y: y - 25 - imgHeight,
        width: imgWidth,
        height: imgHeight,
      });

      page.drawText("Customer Signature", {
        x: margin + 10,
        y: y - 25 - imgHeight - 15,
        size: 8,
        font: helvetica,
        color: rgb(0.5, 0.5, 0.5),
      });
    }

    // Verified status
    const verifiedY = signatureImage ? y - sigBoxHeight + 40 : y - 25;
    page.drawText("Status: Verified", {
      x: margin + 10,
      y: verifiedY,
      size: 11,
      font: helveticaBold,
      color: rgb(0.1, 0.6, 0.1),
    });

    if (signedDate) {
      page.drawText(`Signed: ${signedDate}`, {
        x: margin + 10,
        y: verifiedY - 16,
        size: 9,
        font: helvetica,
        color: rgb(0.4, 0.4, 0.4),
      });
    }

    y -= sigBoxHeight;
  }

  // --- Footer ---
  const footerText =
    "All signatures and agreements contained herein are legally binding and enforceable.";
  page.drawText(footerText, {
    x: margin,
    y: margin - 20,
    size: 8,
    font: helvetica,
    color: rgb(0.5, 0.5, 0.5),
  });

  const pdfBytes = await pdfDoc.save();
  return Buffer.from(pdfBytes);
}
