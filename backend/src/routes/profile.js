const router = require("express").Router();
const { getUploadUrl, getAvatarUrl } = require("../utils/s3");
const db = require("../db");
const auth = require("../middleware/authMiddleware");

router.use(auth);

router.get("/", async (req, res) => {
  const result = await db.query(
    "SELECT username,email,fullname,phone,avatar FROM users WHERE id=$1",
    [req.user.id]
  );
  const user = result.rows[0];
   console.log("DB avatar:", user.avatar);
  let avatarUrl = null;
  if (user.avatar) {
    avatarUrl = await getAvatarUrl(user.avatar);
  }
  console.log("Signed URL:", avatarUrl);
  res.json({
    ...user,
    avatar: avatarUrl 
  });
});



router.put("/", async (req, res) => {
  const { fullname, email, phone } = req.body;

  await db.query(
    "UPDATE users SET fullname=$1,email=$2,phone=$3 WHERE id=$4",
    [fullname, email, phone, req.user.id]
  );

  res.sendStatus(200);
});



router.get("/upload-url", async (req, res) => {
  const { filename, type } = req.query;

  if (!filename || !type) {
    return res.status(400).json({ error: "Missing filename or type" });
  }

  const data = await getUploadUrl(filename, type);

  res.json(data); 
  // { uploadUrl, key }
});



router.post("/avatar", async (req, res) => {
  const { key } = req.body;

  if (!key) {
    return res.status(400).json({ error: "Missing key" });
  }

  await db.query(
    "UPDATE users SET avatar=$1 WHERE id=$2",
    [key, req.user.id]
  );

  res.sendStatus(200);
});

module.exports = router;