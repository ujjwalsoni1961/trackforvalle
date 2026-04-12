/**
 * Open the signed contract HTML in a new browser tab with a print button.
 * The user can then use the browser's Save as PDF / Print functionality
 * which renders CSS perfectly (unlike html2canvas-based solutions).
 */
export async function downloadPdfFromHtml(htmlContent: string, filename: string): Promise<void> {
  // Open a new window with the contract HTML
  const printWindow = window.open('', '_blank');
  if (!printWindow) {
    // If popup blocked, try iframe approach
    const iframe = document.createElement('iframe');
    iframe.style.position = 'fixed';
    iframe.style.left = '0';
    iframe.style.top = '0';
    iframe.style.width = '100vw';
    iframe.style.height = '100vh';
    iframe.style.zIndex = '99999';
    iframe.style.border = 'none';
    iframe.style.background = 'white';
    document.body.appendChild(iframe);

    const iframeDoc = iframe.contentDocument || iframe.contentWindow?.document;
    if (iframeDoc) {
      iframeDoc.open();
      iframeDoc.write(htmlContent);
      iframeDoc.close();
    }
    return;
  }

  // Inject a print/download bar at the top of the page
  const printBar = `
    <div id="print-bar" style="
      position: fixed; top: 0; left: 0; right: 0; z-index: 10000;
      background: #1a1a2e; color: white; padding: 12px 24px;
      display: flex; align-items: center; justify-content: space-between;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
    ">
      <span style="font-size: 14px;">📄 ${filename.replace('.pdf', '')}</span>
      <div>
        <button onclick="document.getElementById('print-bar').style.display='none'; window.print(); document.getElementById('print-bar').style.display='flex';" style="
          background: #4CAF50; color: white; border: none; padding: 8px 20px;
          border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 500;
          margin-right: 8px;
        ">⬇ Save as PDF</button>
        <button onclick="window.close();" style="
          background: #666; color: white; border: none; padding: 8px 20px;
          border-radius: 6px; cursor: pointer; font-size: 14px;
        ">✕ Close</button>
      </div>
    </div>
  `;

  // Add padding to push content below the bar, and inject the bar
  const modifiedHtml = htmlContent.replace(
    '<body',
    '<body style="padding-top: 60px;"'
  );

  printWindow.document.write(modifiedHtml);
  printWindow.document.write(printBar);

  // Add print-specific CSS to hide the bar when printing
  const printCss = printWindow.document.createElement('style');
  printCss.textContent = `
    @media print {
      #print-bar { display: none !important; }
      body { padding-top: 0 !important; }
    }
  `;
  printWindow.document.head?.appendChild(printCss);
  printWindow.document.close();
}
