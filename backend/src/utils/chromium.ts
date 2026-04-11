/**
 * Launch a headless browser for PDF generation.
 * Puppeteer is loaded dynamically - install it separately if PDF generation is needed:
 *   npm install puppeteer
 */
export async function getBrowser(): Promise<any> {
  try {
    // @ts-ignore - puppeteer is an optional dependency
    const puppeteer = await import("puppeteer");
    return puppeteer.default.launch({
      headless: true,
      args: [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-dev-shm-usage",
        "--disable-web-security",
        "--allow-running-insecure-content",
      ],
    });
  } catch (error) {
    throw new Error(
      "Puppeteer is not available. PDF generation requires puppeteer to be installed. " +
        "Install it with: npm install puppeteer"
    );
  }
}
