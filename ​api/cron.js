// Tashqi cron xizmati (masalan cron-job.org) har daqiqada shu manzilni chaqiradi:
// https://SIZNING-SAYT.vercel.app/api/cron?secret=CRON_SECRET
const { runScheduledTasks, DB } = require("../lib/bot.js");

module.exports = async (req, res) => {
  if (!process.env.CRON_SECRET || req.query.secret !== process.env.CRON_SECRET) {
    res.status(403).json({ ok: false, error: "Forbidden" });
    return;
  }
  const env = {
    BOT_TOKEN: process.env.BOT_TOKEN,
    OWNER_ID: process.env.OWNER_ID,
    WEBHOOK_SECRET: process.env.WEBHOOK_SECRET,
    DB,
  };
  try {
    await runScheduledTasks(env);
    res.status(200).json({ ok: true });
  } catch (err) {
    console.log("Cron xatosi:", err.stack || err.message);
    res.status(500).json({ ok: false, error: err.message });
  }
};
