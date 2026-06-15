const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: process.env.SMTP_SECURE === 'true', // true for port 465, false for other ports
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

const sendVerificationEmail = async (email, otp) => {
  const htmlTemplate = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Xác thực đặt lại mật khẩu</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 20px auto; padding: 20px; border: 1px solid #dddddd; border-radius: 8px; background-color: #f9f9f9; }
        .header { text-align: center; border-bottom: 2px solid #FF5600; padding-bottom: 10px; }
        .header h2 { color: #FF5600; margin: 0; }
        .content { padding: 20px 0; }
        .otp-box { font-size: 24px; font-weight: bold; letter-spacing: 4px; text-align: center; padding: 15px; margin: 20px 0; background-color: #ffebe0; border: 1px dashed #FF5600; border-radius: 6px; color: #FF5600; }
        .footer { font-size: 12px; color: #777777; text-align: center; border-top: 1px solid #dddddd; padding-top: 10px; margin-top: 20px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h2>SPORT ENERGY</h2>
        </div>
        <div class="content">
          <p>Xin chào,</p>
          <p>Bạn nhận được email này vì bạn (hoặc ai đó) đã yêu cầu đặt lại mật khẩu cho tài khoản của bạn trên ứng dụng Sport Energy.</p>
          <p>Mã xác thực (OTP) của bạn là:</p>
          <div class="otp-box">${otp}</div>
          <p>Mã xác thực này có hiệu lực trong vòng <strong>10 phút</strong>. Vui lòng không chia sẻ mã này với bất kỳ ai.</p>
          <p>If you did not request a password reset, please ignore this email.</p>
        </div>
        <div class="footer">
          <p>© 2026 Sport Energy. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const mailOptions = {
    from: `"Sport Energy" <${process.env.SMTP_USER || 'no-reply@sportenergy.com'}>`,
    to: email,
    subject: 'Mã xác thực đặt lại mật khẩu - Sport Energy',
    html: htmlTemplate,
  };

  return transporter.sendMail(mailOptions);
};

const sendPasswordChangedEmail = async (email) => {
  const htmlTemplate = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Mật khẩu đã được thay đổi</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 20px auto; padding: 20px; border: 1px solid #dddddd; border-radius: 8px; background-color: #f9f9f9; }
        .header { text-align: center; border-bottom: 2px solid #FF5600; padding-bottom: 10px; }
        .header h2 { color: #FF5600; margin: 0; }
        .content { padding: 20px 0; }
        .warning-box { padding: 15px; background-color: #fff9e6; border-left: 4px solid #ffcc00; margin: 20px 0; border-radius: 4px; }
        .footer { font-size: 12px; color: #777777; text-align: center; border-top: 1px solid #dddddd; padding-top: 10px; margin-top: 20px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h2>SPORT ENERGY</h2>
        </div>
        <div class="content">
          <p>Xin chào,</p>
          <p>Chúng tôi xin thông báo rằng mật khẩu cho tài khoản Sport Energy của bạn đã được thay đổi thành công.</p>
          <div class="warning-box">
            <strong>Cảnh báo bảo mật:</strong> Nếu bạn không thực hiện thay đổi này, hãy liên hệ ngay với ban quản trị hoặc bộ phận hỗ trợ của Sport Energy để bảo vệ tài khoản của bạn.
          </div>
        </div>
        <div class="footer">
          <p>© 2026 Sport Energy. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const mailOptions = {
    from: `"Sport Energy" <${process.env.SMTP_USER || 'no-reply@sportenergy.com'}>`,
    to: email,
    subject: 'Cập nhật bảo mật: Mật khẩu tài khoản đã thay đổi - Sport Energy',
    html: htmlTemplate,
  };

  return transporter.sendMail(mailOptions);
};

module.exports = {
  sendVerificationEmail,
  sendPasswordChangedEmail,
};
