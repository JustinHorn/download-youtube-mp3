var express = require("express");
var router = express.Router();

const { parseVideo } = require("../download");

/* GET home page. */
router.get("/", function (req, res, next) {
  res.render("index", { title: "Express" });
});

router.get("/parseVideo/:videoUrl", async function (req, res, next) {
  const { videoUrl } = req.params;
  await parseVideo("https://www.youtube.com/watch?v=" + videoUrl);
  res.download("output.mp3").send("loadVideo");
});

module.exports = router;
