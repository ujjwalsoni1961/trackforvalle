declare const html2pdf: any;

/**
 * Load html2pdf.js from CDN if not already loaded
 */
function loadHtml2Pdf(): Promise<void> {
  return new Promise((resolve, reject) => {
    if (typeof html2pdf !== 'undefined') {
      resolve();
      return;
    }
    const script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.2/html2pdf.bundle.min.js';
    script.onload = () => resolve();
    script.onerror = () => reject(new Error('Failed to load html2pdf.js'));
    document.head.appendChild(script);
  });
}

/**
 * Extract styles and body from a full HTML document string
 */
function extractContent(htmlDoc: string): { styles: string; body: string } {
  // Extract all <style> content
  const styleMatches = htmlDoc.match(/<style[^>]*>([\s\S]*?)<\/style>/gi) || [];
  const styles = styleMatches.map(s => {
    const match = s.match(/<style[^>]*>([\s\S]*?)<\/style>/i);
    return match ? match[1] : '';
  }).join('\n');

  // Extract <body> content, or fall back to everything
  const bodyMatch = htmlDoc.match(/<body[^>]*>([\s\S]*?)<\/body>/i);
  const body = bodyMatch ? bodyMatch[1] : htmlDoc;

  return { styles, body };
}

/**
 * Generate a PDF from HTML string and trigger download.
 * Handles full HTML documents (with <html>, <head>, <style>, <body>)
 * by extracting styles and injecting them into the render container.
 */
export async function downloadPdfFromHtml(htmlContent: string, filename: string): Promise<void> {
  await loadHtml2Pdf();

  const { styles, body } = extractContent(htmlContent);

  // Create a temporary container with extracted styles
  const container = document.createElement('div');
  if (styles) {
    const styleEl = document.createElement('style');
    styleEl.textContent = styles;
    container.appendChild(styleEl);
  }

  const contentDiv = document.createElement('div');
  contentDiv.innerHTML = body;
  container.appendChild(contentDiv);

  // Position off-screen but still renderable by html2canvas
  container.style.position = 'fixed';
  container.style.left = '0';
  container.style.top = '0';
  container.style.width = '210mm';
  container.style.zIndex = '-1000';
  container.style.opacity = '0';
  container.style.background = 'white';
  document.body.appendChild(container);

  // Wait for images to load
  const images = container.querySelectorAll('img');
  if (images.length) {
    await Promise.all(
      Array.from(images).map(
        (img) =>
          new Promise<void>((resolve) => {
            if (img.complete) {
              resolve();
            } else {
              img.onload = () => resolve();
              img.onerror = () => resolve();
            }
          })
      )
    );
  }

  // Small delay for styles to apply
  await new Promise((resolve) => setTimeout(resolve, 200));

  try {
    const opt = {
      margin: [5, 5, 5, 5],
      filename: filename.endsWith('.pdf') ? filename : `${filename}.pdf`,
      image: { type: 'jpeg', quality: 0.98 },
      html2canvas: {
        scale: 2,
        useCORS: true,
        allowTaint: true,
        logging: false,
        backgroundColor: '#ffffff',
      },
      jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' },
    };

    await html2pdf().set(opt).from(container).save();
  } finally {
    document.body.removeChild(container);
  }
}
