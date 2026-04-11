export enum EmailType {
  RESET_PASSWORD,
  LOGIN_REQUEST,
  SET_PASSWORD,
  VERIFY_PHONE,
}

/**
 * Send an SMS message. Previously used AWS SNS.
 * Currently logs the message since SMS provider is being migrated.
 * TODO: Integrate a new SMS provider if needed (Twilio, etc.)
 */
export const sendMessage = async (
  otpOrLink: string,
  phone: string,
  type: EmailType
) => {
  let message: string;

  switch (type) {
    case EmailType.VERIFY_PHONE:
      message = `You have initiated a phone number change request. Please use the following OTP to verify it: ${otpOrLink}`;
      break;

    case EmailType.RESET_PASSWORD:
      message = `You are receiving this because you (or someone else) have requested the reset of the password for your account. Please use the following OTP to reset the password: ${otpOrLink}`;
      break;

    case EmailType.LOGIN_REQUEST:
      message = `You are receiving this because you (or someone else) have requested to log in to your account. Please use the following OTP to log in to your account: ${otpOrLink}`;
      break;

    default:
      throw new Error("Invalid message type");
  }

  // Log SMS for development - replace with actual SMS provider in production
  console.log(`[SMS] To: ${phone}, Message: ${message}`);
};
