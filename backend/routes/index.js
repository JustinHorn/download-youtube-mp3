var express = require("express");
var router = express.Router();
const ytdl = require("ytdl-core");

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

router.get("/info/:videoCode", async function (req, res, next) {
  try {
    const { videoCode } = req.params;

    let info = await ytdl.getInfo(videoCode);
    let videoDetails = info.videoDetails;
    let thumbnail = videoDetails.thumbnails[0].url;
    let title = videoDetails.title;
    let lengthSeconds = videoDetails.lengthSeconds;

    let audios = info.formats.filter(
      (x) =>
        x.mimeType.includes("audio/mp4") || x.mimeType.includes("audio/mp3")
    );

    let audio = audios.length > 0 ? audios[0].url : undefined;

    const infoData = { title, thumbnail, lengthSeconds, audio };
    res.json(infoData);
  } catch (e) {
    next(e);
  }
});

module.exports = router;
