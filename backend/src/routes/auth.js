const router = require("express").Router();
const db = require("../db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const redis = require("../redis");

// REGISTER
router.post("/register", async (req, res) => {
  const { username, password, email, fullname, phone } = req.body;

  if (!username || !password) {
    return res.status(400).json({ error: "Missing username/password" });
  }

  try {
    const hash = await bcrypt.hash(password, 10);

    const result = await db.query(
      `
      INSERT INTO users(username, password, email, fullname, phone)
      VALUES($1, $2, $3, $4, $5)
      RETURNING id, username, email, fullname, phone
      `,
      [
        username,
        hash,
        email || null,
        fullname || null,
        phone || null
      ]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {
    if (err.code === "23505") {
      return res.status(400).json({ error: "Username already exists" });
    }

    res.status(500).json({ error: "Server error" });
  }
});

// LOGIN
router.post("/login", async (req, res) => {
  const { username, password } = req.body;


  const result = await db.query(
    "SELECT * FROM users WHERE username=$1",
    [username]
  );

  const user = result.rows[0];
  if (!user) {
    console.log(" USER NOT FOUND");
    return res.sendStatus(401);
  }

  const valid = await bcrypt.compare(password, user.password);

  if (!valid) {
    console.log("WRONG PASSWORD");
    return res.sendStatus(401);
  }

  console.log("LOGIN SUCCESS");

  const accessToken = jwt.sign(
    { id: user.id },
    process.env.JWT_ACCESS_SECRET,
    { expiresIn: process.env.ACCESS_EXPIRE }
  );

  const refreshToken = jwt.sign(
    { id: user.id },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.REFRESH_EXPIRE }
  );

  await redis.set(`refresh:${user.id}`, refreshToken);

  res.json({ accessToken, refreshToken });
});
// LOGOUT
router.post("/logout", async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) return res.sendStatus(400);

  try {
    const decoded = jwt.verify(
      refreshToken,
      process.env.JWT_REFRESH_SECRET
    );

    // xóa refresh token trong Redis
    await redis.del(`refresh:${decoded.id}`);

    res.sendStatus(200);
  } catch {
    // token sai vẫn cho logout (best practice)
    res.sendStatus(200);
  }
});

// REFRESH TOKEN
router.post("/refresh", async (req, res) => {
  const { refreshToken } = req.body;

  try {
    const decoded = jwt.verify(
      refreshToken,
      process.env.JWT_REFRESH_SECRET
    );

    const stored = await redis.get(`refresh:${decoded.id}`);
    if (stored !== refreshToken) return res.sendStatus(403);

    const newAccess = jwt.sign(
      { id: decoded.id },
      process.env.JWT_ACCESS_SECRET,
      { expiresIn: process.env.ACCESS_EXPIRE }
    );

    res.json({ accessToken: newAccess });
  } catch {
    res.sendStatus(403);
  }
});


module.exports = router;