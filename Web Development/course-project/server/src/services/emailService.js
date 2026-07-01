const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  jsonTransport: true,
});

async function sendVerificationEmail({ to, link }) {
  const info = await transporter.sendMail({
    from: "no-reply@resource-center.local",
    to,
    subject: "Verify your account",
    html: `<p>Welcome to Resource Center.</p><p>Click <a href=\"${link}\">this link</a> to verify your email.</p>`,
  });

  return info.message;
}

module.exports = {
  sendVerificationEmail,
};
