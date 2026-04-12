/**
 * Launch a headless browser for PDF generation.
 * Uses @sparticuz/chromium for serverless environments (Vercel/AWS Lambda)
 * and puppeteer-core as the browser driver.
 */
export async function getBrowser(): Promise<any> {
  try {
    const chromium = await import("@sparticuz/chromium");
    const puppeteerCore = await import("puppeteer-core");

    const executablePath = await chromium.default.executablePath();

    return puppeteerCore.default.launch({
      args: chromium.default.args,
      defaultViewport: chromium.default.defaultViewport,
      executablePath,
      headless: chromium.default.headless,
    });
  } catch (error) {
    console.error("Chromium launch error:", error);
    throw new Error(
      "Failed to launch browser for PDF generation. " +
        "Ensure @sparticuz/chromium and puppeteer-core are installed."
    );
  }
}
