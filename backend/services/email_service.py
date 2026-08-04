import os
import logging
import resend
from dotenv import load_dotenv

# Load env variables if not already loaded
load_dotenv()

logger = logging.getLogger(__name__)

# Set the API key
RESEND_API_KEY = os.getenv("RESEND_API_KEY", "")
RESEND_FROM_EMAIL = os.getenv("RESEND_FROM_EMAIL", "onboarding@resend.dev")

if RESEND_API_KEY:
    resend.api_key = RESEND_API_KEY

class EmailService:
    @staticmethod
    def send_reset_email(to_email: str, code: str):
        """
        Sends a 6-digit OTP code using Resend Email API.
        """
        if not RESEND_API_KEY:
            logger.error("RESEND_API_KEY is not configured. Email not sent.")
            print("RESEND_API_KEY is not configured.", flush=True)
            return
            
        html_body = f"""
        <div style="font-family: 'Segoe UI', sans-serif; max-width: 480px; margin: auto; background: #f9fafb; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.08);">
          <div style="background: linear-gradient(135deg, #2E7D32, #4CAF50); padding: 32px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 24px; font-weight: 800;">🌿 AgroSentry</h1>
            <p style="color: rgba(255,255,255,0.8); margin: 8px 0 0; font-size: 14px;">AI-Powered Crop Health Platform</p>
          </div>
          <div style="padding: 32px; background: white;">
            <h2 style="color: #1a1a1a; font-size: 20px; margin: 0 0 8px;">Password Reset Request</h2>
            <p style="color: #6b7280; font-size: 14px; line-height: 1.6;">We received a request to reset the password for your AgroSentry account. Use the code below to proceed. This code expires in <strong>10 minutes</strong>.</p>
            <div style="background: #f0fdf4; border: 2px solid #86efac; border-radius: 12px; padding: 24px; text-align: center; margin: 24px 0;">
              <p style="color: #15803d; font-size: 12px; font-weight: 700; letter-spacing: 2px; margin: 0 0 8px; text-transform: uppercase;">Your Reset Code</p>
              <p style="color: #166534; font-size: 42px; font-weight: 900; letter-spacing: 10px; margin: 0; font-family: monospace;">{code}</p>
            </div>
            <p style="color: #9ca3af; font-size: 12px; line-height: 1.6;">If you did not request this, you can safely ignore this email. Your password will not be changed.</p>
          </div>
          <div style="padding: 16px 32px; background: #f9fafb; text-align: center;">
            <p style="color: #d1d5db; font-size: 11px; margin: 0;">© 2025 AgroSentry AI. All rights reserved.</p>
          </div>
        </div>
        """

        text_body = f"Password Reset Request\n\nYour reset code is: {code}\n\nThis code expires in 10 minutes.\n\n© 2025 AgroSentry AI."

        params = {
            "from": f"AgroSentry <{RESEND_FROM_EMAIL}>",
            "to": to_email,
            "subject": "🌿 AgroSentry — Your Password Reset Code",
            "html": html_body,
            "text": text_body
        }
        
        try:
            # Sync call to resend
            response = resend.Emails.send(params)
            print(f"OTP successfully sent to {to_email} via Resend. Response: {response}", flush=True)
            logger.info(f"OTP successfully sent to {to_email} via Resend. ID: {response.get('id')}")
        except Exception as e:
            print(f"Failed to send OTP email to {to_email} via Resend: {e}", flush=True)
            logger.error(f"Failed to send OTP email to {to_email}. Error: {str(e)}")
            
