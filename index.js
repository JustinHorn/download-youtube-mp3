const fs = require('fs');
const ytdl = require('ytdl-core');

ytdl('https://www.youtube.com/watch?v=EHsW37g2uGU').pipe(
  fs.createWriteStream('video.mp4')
);

const ffmpeg = require('fluent-ffmpeg');

function convert(input, output, callback) {
  ffmpeg(input)
    .output(output)
    .on('end', function () {
      console.log('conversion ended');
      callback(null);
    })
    .on('error', function (e) {
      console.error(e);
    })
    .run();
}

convert('./video.mp4', './output.mp3', function (err) {
  if (!err) {
    console.log('conversion complete');
  }
});
