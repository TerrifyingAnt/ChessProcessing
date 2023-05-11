// https://helloacm.com

final int WIDTH = 500;
final int HEIGHT = 500;
final int LENGTH = 40;

void setup() {

}

public void settings() {
    size(512, 512);

}

// основаня функция рисования
void draw() {
    background(55, 55, 55);
    drawBoard();
}


// функция для рисования доски
void drawBoard() {
    color c = color(223, 255, 230);
    noStroke();
    for (int i = 96; i < 416; i += 40) {
        for (int j = 96; j < 416; j += 40) {
            if (((i + j) / 40 + 1) % 2 == 0) {
                c = color(255, 204, 153);
                fill(c);
            } else {
                c = color(191, 129, 75);
                fill(c);
            }
            if ((i - 96) / 40 == 0 && (j - 96) / 40 == 0) {
                rect(i, j, LENGTH, LENGTH, 15, 0, 0, 0);
            }
            else 
            if ((i - 96) / 40 == 0 && (j - 96) / 40 == 7) {
                rect(i, j, LENGTH, LENGTH, 0, 0, 0, 15);
            }
            else 
            if ((i - 96) / 40 == 7 && (j - 96) / 40 == 0) {
                rect(i, j, LENGTH, LENGTH, 0, 15, 0, 0);
            }
            else 
            if ((i - 96) / 40 == 7 && (j - 96) / 40 == 7) {
                rect(i, j, LENGTH, LENGTH, 0, 0, 15, 0);
            }
            else
            rect(i, j, LENGTH, LENGTH);     
        } 
    }
}