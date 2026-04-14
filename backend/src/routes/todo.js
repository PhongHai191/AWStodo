const router = require("express").Router();
const db = require("..db");
const redis = require("../redis");
const auth = require("../middleware/authMiddleware");

router.use(auth);

// GET TODOS
router.get("/", async (req, res) => {
  const key = `todos:${req.user.id}`;

  const cached = await redis.get(key);
  if (cached) return res.json(JSON.parse(cached));

  const result = await db.query(
    "SELECT id,text FROM todos WHERE user_id=$1",
    [req.user.id]
  );

  await redis.set(key, JSON.stringify(result.rows), { EX: 60 });

  res.json(result.rows);
});

// CREATE
router.post("/", async (req, res) => {
  const { text } = req.body;

  const result = await db.query(
    "INSERT INTO todos(text,user_id) VALUES($1,$2) RETURNING id,text",
    [text, req.user.id]
  );

  await redis.del(`todos:${req.user.id}`);

  res.status(201).json(result.rows[0]);
});

// DELETE
router.delete("/:id", async (req, res) => {
  await db.query(
    "DELETE FROM todos WHERE id=$1 AND user_id=$2",
    [req.params.id, req.user.id]
  );

  await redis.del(`todos:${req.user.id}`);

  res.sendStatus(204);
});

module.exports = router;