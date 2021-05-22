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

    const info = await ytdl.getInfo(videoCode);
    const videoDetails = info.videoDetails;
    const thumbnail = videoDetails.thumbnails[0].url;
    const title = videoDetails.title;
    const seconds = parseInt(videoDetails.lengthSeconds);

    const audios = info.formats.filter(
      (x) =>
        x.mimeType.includes("audio/mp4") || x.mimeType.includes("audio/mp3")
    );

    const audioURL = audios.length > 0 ? audios[0].url : undefined;

    const infoData = {
      code: videoCode,
      title,
      thumbnail,
      seconds,
      audioURL,
    };
    res.json(infoData);
  } catch (e) {
    next(e);
  }
});

module.exports = router;
