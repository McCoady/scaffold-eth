
let canvas;
let bubbles = [];

function setup() {
    canvas = createCanvas(windowWidth, windowHeight);
    canvas.position(0, 0);
    colorMode(HSB, 360, 100, 100);
    frameRate(60);
    for (let i = 0; i < 50; i++) {
        bub = new Bubble(random(width), random(height))
        bubbles.push(bub);
    }
}

function draw() {
    background(255);

    for (let i = 0; i < bubbles.length; i++) {
        bubbles[i].update();
        bubbles[i].checkTouch();
        bubbles[i].checkTime();
        bubbles[i].display();

    }
}