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
 * Generate a PDF from HTML string and trigger download
 */
export async function downloadPdfFromHtml(htmlContent: string, filename: string): Promise<void> {
  await loadHtml2Pdf();

  // Create a temporary container
  const container = document.createElement('div');
  container.innerHTML = htmlContent;
  container.style.position = 'absolute';
  container.style.left = '-9999px';
  container.style.top = '0';
  container.style.width = '210mm'; // A4 width
  document.body.appendChild(container);

  try {
    const opt = {
      margin: [10, 10, 10, 10],
      filename: filename.endsWith('.pdf') ? filename : `${filename}.pdf`,
      image: { type: 'jpeg', quality: 0.98 },
      html2canvas: { scale: 2, useCORS: true, allowTaint: true },
      jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
    };

    await html2pdf().set(opt).from(container).save();
  } finally {
    document.body.removeChild(container);
  }
}
