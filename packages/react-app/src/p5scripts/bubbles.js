const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

var dho = [0.5, -0.5, 1, -1, 20];
var dhw = [10, 10, 6, 6, 1];
var csdh = dhw.reduce((a, x, i) => [...a, x + (a[i - 1] || 0)], []);

class Bubble {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.r = random((width + height) * 0.01, (width + height) * 0.04);
        this.h = random(360);
        this.dy = random(-1, 1);
        this.dx = random(-1, 1);

        var rnd = Math.random() * csdh.slice(-1);

        var r = 0;
        while (csdh[r] < rnd) {
            r++;
        }
        this.dh = dho[r];
        this.s = 35;
        this.t = false;
        this.c = 0;
    }



    display() {
        strokeWeight(3);
        stroke(0);
        fill(this.h, this.s, 100);
        ellipse(this.x, this.y, this.r);
    }

    update() {
        this.x += this.dx;
        this.y += this.dy;
        this.dx += random(-0.2, 0.2);
        this.dy += random(-0.2, 0.2);
        this.dx = clamp(this.dx, -1, 1);
        this.dy = clamp(this.dy, -1, 1);
        this.h = (this.h + this.dh + 360) % 360;
    }

    checkTime() {
        if (this.t == true) {
            this.c += 1;
        }
        if (this.c >= 600) {
            this.s = 35;
            this.c = 0;
            this.t = false;
        }
    }

    checkTouch() {
        let d = dist(mouseX, mouseY, this.x, this.y)
        if (d < this.r) {
            this.s = 0;
            this.t = true;
        }
    }

}