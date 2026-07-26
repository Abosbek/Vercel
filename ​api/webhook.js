const { handleUpdate, setWebhook, DB } = require("../lib/bot.js");

function buildEnv() {
  return {
    BOT_TOKEN: process.env.BOT_TOKEN,
    OWNER_ID: process.env.OWNER_ID,
    WEBHOOK_SECRET: process.env.WEBHOOK_SECRET,
    DB,
  };
}

module.exports = async (req, res) => {
  const env = buildEnv();

  // https://SIZNING-SAYT.vercel.app/api/webhook?setup=1 — webhookni ulash uchun (bir marta ochiladi)
  if (req.method === "GET" && req.query.setup === "1") {
    const proto = req.headers["x-forwarded-proto"] || "https";
    const host = req.headers["host"];
    const webhookUrl = `${proto}://${host}/api/webhook`;
    try {
      const result = await setWebhook(env, webhookUrl);
      res.status(200).json(result);
    } catch (err) {
      res.status(500).json({ ok: false, error: err.message });
    }
    return;
  }

  if (req.method !== "POST") {
    res.status(200).send("Uzbek Test Bot ishlayapti (Vercel).");
    return;
  }

  const secret = req.headers["x-telegram-bot-api-secret-token"];
  if (secret !== process.env.WEBHOOK_SECRET) {
    res.status(403).send("Forbidden");
    return;
  }

  try {
    await handleUpdate(req.body, env);
  } catch (err) {
    console.log("Webhook xatosi:", err.stack || err.message);
  }

  res.status(200).send("ok");
};

