import * as nodemailer from "nodemailer";
import dotenv from "dotenv";

dotenv.config();

const getTransporter = () => {
  return nodemailer.createTransport({
    service: "gmail",
    secure: true,
    auth: {
      user: process.env.EMAIL_USER || process.env.EMAIL_FROM,
      pass: process.env.EMAIL_PASS,
    },
  });
};

export async function sendSESEmail(
  email: string,
  subject: string,
  htmlContent: string
): Promise<void> {
  const transporter = getTransporter();
  const from = process.env.EMAIL_FROM || process.env.EMAIL_USER || "noreply@trackforvalle.com";

  try {
    await transporter.sendMail({
      from,
      to: email,
      subject,
      html: htmlContent,
    });
  } catch (error) {
    console.error("Error sending email:", error);
  }
}

export async function sendSESEmailWithAttachment(
  email: string,
  subject: string,
  htmlContent: string,
  attachmentBuffer: any,
  attachmentFilename: string = "Call_Summary.pdf"
): Promise<void> {
  const transporter = getTransporter();
  const from = process.env.EMAIL_FROM || process.env.EMAIL_USER || "noreply@trackforvalle.com";

  try {
    await transporter.sendMail({
      from,
      to: email,
      subject,
      html: htmlContent,
      attachments: [
        {
          filename: attachmentFilename,
          content: attachmentBuffer,
          contentType: "application/pdf",
        },
      ],
    });
    console.log("Email sent successfully");
  } catch (error) {
    console.error("Error sending email:", error);
  }
}

/**
 * Check if an email identity is verified.
 * With nodemailer/Gmail this always returns true since we don't have SES verification.
 */
export async function isSesIdentityVerified(email: string): Promise<boolean> {
  return true;
}
