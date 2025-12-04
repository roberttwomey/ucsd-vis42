let a=0;

function preload(){
  sound = loadSound('https://p5js.org/assets/piano-loop.mp3');
}

function setup() {
  let cnv = createCanvas(400, 400);
  cnv.mouseClicked(toggleSound);
  amplitude = new p5.Amplitude();
  angleMode(DEGREES);
}

function draw() {
  // background(220, 150);
  textAlign(CENTER);
  noStroke();
  text('tap to play', width/2, 20);

  let level = amplitude.getLevel();
  let size = map(level, 0, 0.1, 0, 255);
  stroke(255-size);
  line(width/2, height/2, width/2+sin(a)*size, height/2+cos(a)*size);
  a++;
  if(a>360) {
    a=0;
  }
}

function toggleSound(){
  if (sound.isPlaying()) {
    sound.stop();
  } else {
    sound.loop();
  }
}