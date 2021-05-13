const fs = require("fs");
const ytdl = require("ytdl-core");
const ffmpeg = require("fluent-ffmpeg");

async function parseVideo(videoUrl) {
  const stream = fs.createWriteStream("video.mp4");

  let endWait = false;
  stream
    .on("finish", () => {
      endWait = true;
    })
    .on("end", () => {
      endWait = true;
    });

  ytdl(videoUrl).pipe(stream);
  console.log(endWait);

  await (async function wait() {
    await sleep(1000);
    if (!endWait) await wait();
  })();

  console.log("ytdl");

  console.log("converting");
  endWait = false;

  await convert("./video.mp4", "./output.mp3", function (err) {
    if (!err) {
      console.log("conversion complete");
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
