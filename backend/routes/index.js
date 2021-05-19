var express = require("express");
var router = express.Router();

const { parseVideo } = require("../download");

router.get("/", function (req, res, next) {
  res.render("index", { title: "Express" });
});

router.get("/parseVideo/:videoCode", async function (req, res, next) {
  try {
    const { videoCode } = req.params;
    console.log("got request");

    await parseVideo(videoCode);
    res.download(videoCode + ".mp3");
  } catch (e) {
    next(e);
    res.status(400).send("error");
  }
});

module.exports = router;
