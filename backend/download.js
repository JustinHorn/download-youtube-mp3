const fs = require("fs");
const ytdl = require("ytdl-core");
const ffmpeg = require("fluent-ffmpeg");

async function parseVideo(videoCode) {
  const base = "https://www.youtube.com/watch?v=";
  try {
    const stream = fs.createWriteStream(videoCode + ".mp4");

    let endWait = false;
    stream
      .on("finish", () => {
        endWait = true;
      })
      .on("end", () => {
        endWait = true;
      });

    ytdl(base + videoCode).pipe(stream);
    console.log("downloading");
    await (async function wait() {
      await sleep(1000);
      if (!endWait) await wait();
    })();

    console.log("converting");
    endWait = false;

    await convert(`./${videoCode}.mp4`, `./${videoCode}.mp3`, function (err) {
      if (!err) {
        console.log("process complete");
      } else {
        console.log(error);
        console.error(err);
      }
      endWait = true;
    });

    await (async function wait() {
      await sleep(1000);
      if (!endWait) await wait();
    })();
  } catch (e) {
    throw e;
  }
}

async function convert(input, output, callback) {
  ffmpeg(input)
    .output(output)

    .on("end", function () {
      console.log("conversion ended");
      callback(null);
    })
    .on("error", function (e) {
      console.error(e);
    })
    .run();
}

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

module.exports = { parseVideo };
