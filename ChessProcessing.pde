import processing.serial.*;

final int WIDTH = 720;
final int HEIGHT = 720;
final int LENGTH = 60;

final int HEIGHT_START = HEIGHT / 2 - LENGTH * 4;
final int HEIGHT_END = HEIGHT / 2 + LENGTH * 4;

final int WIDTH_START = WIDTH / 2 - LENGTH * 4;
final int WIDTH_END = WIDTH / 2 + LENGTH * 4;

boolean rectOver = false;
boolean exitOver = false;

String logString = "";

Serial myPort;

// * переменная хранит в себе то, что решил делать пользователь
UIChoice uiChoice = UIChoice.NOTHING; 

// * переменная, которая хранит в себе фигуру, которая перемещается
PShape fig;

// * переменная, которая хранит в себе тип перемещаемой фигуры
FigureType figureType;

// * массив игрового поля, симулирующий работу герконов
boolean[][] board = new boolean[8][8]; 

// * данный массив не участвует в обмене информацией с контроллером.
// * его задача просто запоминать, где какая фигура расположена для UI.
// * по сути это аналог физических фигур, так как запоминает, где какая фигура, но не передает это на контроллер
FigureType[][] UIboard = new FigureType[8][8];
PShape[] whiteFigures = new PShape[6];
PShape[] blackFigures = new PShape[6];

// * отслеживание нажатие кнопки
boolean pressedState = false;

color rectColor = color(19, 38, 35);
color rectHighlight = color(50, 89, 53);

// * расстановка фигур
void setup() {

    myPort  =  new Serial (this, "COM3",  9600);

    // TODO: вынести в функцию
    for(int i = 0; i < 8; i++) {
        for(int j = 0; j < 8; j++) {
            if (i < 2 || i > 5) {
                board[i][j] = true;
            }
            else {
                board[i][j] = false;
            }
        }
    }

    for(int i = 0; i < 8; i++) {
        for(int j = 0; j < 8; j++) {
            if(i == 0) {
                initUIBoard(UIboard, i, j);
            }
            else
            if (i == 1) {
                UIboard[i][j] = FigureType.BLACK_PAWN;
            }
            else 
            if(i == 7) {
                initUIBoard(UIboard, i, j);
            }
            else
            if (i == 6) {
                UIboard[i][j] = FigureType.WHITE_PAWN;
            }

            else 
                UIboard[i][j] = FigureType.NOTHING;
        }
    }

    String name = "";  
    for(int i = 0; i < 6; i++) {
        name = str(i + 1) + ".svg";
        whiteFigures[i] = loadShape("res/white/" + name);
        blackFigures[i] = loadShape("res/black/" + name);
    }
    fig = loadShape("res/black/" + name);
    figureType = FigureType.BLACK_QUEEN;

}

public void settings() {
    size(WIDTH, HEIGHT);
}

// * основаня функция рисования
void draw() {
    background(55, 55, 55);
    switch (uiChoice) {
        case START_GAME:
            fill(255,255,255);
            textFont(createFont("Arial", 14, true));
            text("Логирование", 20, 20);
            text(logString, 20, 40);
            textSize(35);
            drawBoard();
            drawFigures();
            if(pressedState) {
                shape(fig, mouseX, mouseY, LENGTH, LENGTH);
            }
            // TODO: рефакторинг 
            update(mouseX, mouseY);
            if (exitOver) {
                fill(rectHighlight);
            } else {
                fill(rectColor);
            }
            stroke(255);
            rect(WIDTH / 8  * 7, HEIGHT / 8 * 7 + HEIGHT / 32, WIDTH / 8 - 15 , HEIGHT / 16, 15);
            fill(255,255,255);
            textFont(createFont("Arial", 25, true));
            text("Выйти", WIDTH / 8  * 7, HEIGHT / 8 * 7 + HEIGHT / 16 + 8);
            break;

        case NOTHING:
            update(mouseX, mouseY);
            if (rectOver) {
                fill(rectHighlight);
            } else {
                fill(rectColor);
            }
            stroke(255);
            rect(HEIGHT / 2 - HEIGHT / 4, WIDTH / 2 - WIDTH / 8, HEIGHT / 2, WIDTH / 4, 15);
            fill(255,255,255);
            textFont(createFont("Arial", 40, true));
            text("Начать игру", WIDTH / 2  - 40 * 11 / 4, HEIGHT / 2 + 40 / 4);
            break; 
    }
}




void update(int x, int y) {
    if (overButton(WIDTH / 2 - WIDTH / 4, HEIGHT / 2 - HEIGHT / 8, HEIGHT / 2, WIDTH / 4) && uiChoice == UIChoice.NOTHING) {
        rectOver = true;
    } 
    else
    if (overButton(WIDTH / 8 * 7, HEIGHT / 8 * 7 + HEIGHT / 32, WIDTH / 8 - 15 , HEIGHT / 16) && uiChoice == UIChoice.START_GAME) {
        exitOver = true;
    }
    else {
        rectOver = false;
        exitOver = false;
    }
}


boolean overButton(int x, int y, int width, int height)  {
    if (mouseX >= x && mouseX <= x+width && 
        mouseY >= y && mouseY <= y+height) {
    return true;
    } else {
        return false;
    }
}


// * функция для рисования доски
void drawBoard() {
    color c = color(160, 160, 160);
    fill(c);
    rect(HEIGHT_START - LENGTH / 8, WIDTH_START - LENGTH / 8,  HEIGHT_END - HEIGHT_START + LENGTH / 4, HEIGHT_END - HEIGHT_START + LENGTH / 4, 20);
    noStroke();
    for (int i = HEIGHT_START; i < HEIGHT_END; i += LENGTH) {
        for (int j = WIDTH_START; j < WIDTH_END; j += LENGTH) {
            if (((i + j) / LENGTH + 1) % 2 == 0) {
                c = color(191, 129, 75);
                fill(c);
            } else {
                c = color(255, 204, 153);
                fill(c);
            }
            if ((i - HEIGHT_START) / LENGTH == 0 && (j - WIDTH_START) / LENGTH == 0) {
                rect(i, j, LENGTH, LENGTH, 15, 0, 0, 0);
            }
            else 
            if ((i - HEIGHT_START) / LENGTH == 0 && (j - WIDTH_START) / LENGTH == 7) {
                rect(i, j, LENGTH, LENGTH, 0, 0, 0, 15);
            }
            else 
            if ((i - HEIGHT_START) / LENGTH == 7 && (j - WIDTH_START) / LENGTH == 0) {
                rect(i, j, LENGTH, LENGTH, 0, 15, 0, 0);
            }
            else 
            if ((i - HEIGHT_START) / LENGTH == 7 && (j - WIDTH_START) / LENGTH == 7) {
                rect(i, j, LENGTH, LENGTH, 0, 0, 15, 0);
            }
            else
            rect(i, j, LENGTH, LENGTH);     
        } 
    }
}


// * функция рисования фигур
void drawFigures() {
    for(int i = 0; i < 8; i++) {
        for(int j = 0; j < 8; j++) {
            if(board[i][j]) {
                coordToShapes(UIboard[i][j], i, j);
            }
        }
    }
}

// * функция поднимает фигуру с доски
void mousePressed() {
    switch (uiChoice) {
        case START_GAME:
            if(mouseY - HEIGHT_START > 0 && mouseY < HEIGHT_END && mouseX - WIDTH_START > 0 && mouseX < WIDTH_END ) {
                int pressedCellX = (mouseX - WIDTH_START) / LENGTH;
                int pressedCellY = (mouseY - HEIGHT_START) / LENGTH;
                if(UIboard[pressedCellY][pressedCellX] != FigureType.NOTHING && !pressedState) {
                    println("Нажал на: " + UIboard[pressedCellY][pressedCellX]);
                    logString = "Нажал на: " + UIboard[pressedCellY][pressedCellX];
                    pressedState = !pressedState;
                    setClickedFigure(UIboard[pressedCellY][pressedCellX]);
                    UIboard[pressedCellY][pressedCellX] = FigureType.NOTHING;
                    board[pressedCellY][pressedCellX] = false;  
                    myPort.write(1);          
                }
                else {
                    println("Нажал на клетку: \ny:" + str(pressedCellY) + " \nx:" + str(pressedCellX));
                    // TODO удалить проверку на существование фигуры чуть позже
                    // в идеале, ее не должно быть, этот ход должен блокировать контроллер
                    if (pressedState && UIboard[pressedCellY][pressedCellX] == FigureType.NOTHING) {
                        pressedState = !pressedState;
                        board[pressedCellY][pressedCellX] = true;
                        UIboard[pressedCellY][pressedCellX] = figureType;
                        shape(fig, HEIGHT_START + pressedCellX * LENGTH, WIDTH_START + pressedCellY * LENGTH, LENGTH, LENGTH );
                        myPort.write(0);  
                    }
                }
            }
            else 
            if (overButton(mouseX, mouseY, HEIGHT / 8, WIDTH / 8)) {
                // TODO: обновлять фигуры после
                uiChoice = UIChoice.NOTHING;
            }
            else {
                println("Нажал не на поле");
                logString = "Нажал не на поле";
            }
            break;

        case NOTHING:
            if (rectOver) {
                uiChoice = UIChoice.START_GAME;
            }
            break;

    }
}

// * функция логов при перемещении
void mouseMoved() {
    if (pressedState) {
        println("Перемещения би лайк: ");
        println("y: " + str(mouseY) + "\nx: " + str(mouseX));
        logString = "Перемещения би лайк: \n" + "y: " + str(mouseY) + "\nx: " + str(mouseX);
    }
}


// ? вспомогательная функция для отрисовки фигур
void drawShapes(PShape pieces[], int i, int j) {
    if(j == 0 || j == 7) {
        shape(pieces[3], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
    }
    if (j == 1 || j == 6) {
        shape(pieces[1], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
    }
    if (j == 2 || j == 5) {
        shape(pieces[2], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
    }
    if (j == 3) {
        shape(pieces[4], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
    }
    if (j == 4) {
        shape(pieces[5], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
    }
}

// ? вспомогательная функция для запоминания положения фигур ТОЛЬКО ДЛЯ UI
void initUIBoard(FigureType[][] UIboard, int i, int j) {
    if(i == 0) {
        if(j == 0 || j == 7) {
            UIboard[i][j] = FigureType.BLACK_ROCK;
        }
        if (j == 1 || j == 6) {
            UIboard[i][j] = FigureType.BLACK_KNIGHT;
        }
        if (j == 2 || j == 5) {
            UIboard[i][j] = FigureType.BLACK_BISHOP;
        }
        if (j == 3) {
            UIboard[i][j] = FigureType.BLACK_QUEEN;
        }
        if (j == 4) {
            UIboard[i][j] = FigureType.BLACK_KING;
        }
    }
    else
        if(i == 7) {
            if(j == 0 || j == 7) {
                UIboard[i][j] = FigureType.WHITE_ROCK;
            }
            if (j == 1 || j == 6) {
                UIboard[i][j] = FigureType.WHITE_KNIGHT;
            }
            if (j == 2 || j == 5) {
                UIboard[i][j] = FigureType.WHITE_BISHOP;
            }
            if (j == 3) {
                UIboard[i][j] = FigureType.WHITE_QUEEN;
            }
            if (j == 4) {
                UIboard[i][j] = FigureType.WHITE_KING;
            }
        }
}

// * функция устанавливает значение для отрисовки фигур
void setClickedFigure(FigureType type) {
    switch(type) {
        case WHITE_PAWN:
            fig = whiteFigures[0];
            figureType = FigureType.WHITE_PAWN;
            break;
        case WHITE_KNIGHT:
            fig = whiteFigures[1];
            figureType = FigureType.WHITE_KNIGHT;
            break;
        case WHITE_BISHOP:
            fig = whiteFigures[2];
            figureType = FigureType.WHITE_BISHOP;
            break;
        case WHITE_ROCK:
            fig = whiteFigures[3];
            figureType = FigureType.WHITE_ROCK;
            break;
        case WHITE_KING:
            fig = whiteFigures[4];
            figureType = FigureType.WHITE_KING;
            break;
        case WHITE_QUEEN:
            fig = whiteFigures[5];
            figureType = FigureType.WHITE_QUEEN;
            break;
        
        case BLACK_PAWN:
            fig = blackFigures[0];
            figureType = FigureType.BLACK_PAWN;
            break;
        case BLACK_KNIGHT:
            fig = blackFigures[1];
            figureType = FigureType.BLACK_KNIGHT;
            break;
        case BLACK_BISHOP:
            fig = blackFigures[2];
            figureType = FigureType.BLACK_BISHOP;
            break;
        case BLACK_ROCK:
            fig = blackFigures[3];
            figureType = FigureType.BLACK_ROCK;
            break;
        case BLACK_KING:
            fig = blackFigures[4];
            figureType = FigureType.BLACK_KING;
            break;
        case BLACK_QUEEN:
            fig = blackFigures[5];
            figureType = FigureType.BLACK_QUEEN;
            break;
    }
    
}


// * функция рисует фигуры на доске
void coordToShapes(FigureType type, int i, int j) {
    switch (type) {
        case WHITE_PAWN:
            shape(whiteFigures[0], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case WHITE_KNIGHT:
            shape(whiteFigures[1], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case WHITE_BISHOP:
            shape(whiteFigures[2], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case WHITE_ROCK:
            shape(whiteFigures[3], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case WHITE_KING:
            shape(whiteFigures[4], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case WHITE_QUEEN:
            shape(whiteFigures[5], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case BLACK_PAWN:
            shape(blackFigures[0], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case BLACK_KNIGHT:
            shape(blackFigures[1], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case BLACK_BISHOP:
            shape(blackFigures[2], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case BLACK_ROCK:
            shape(blackFigures[3], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case BLACK_KING:
            shape(blackFigures[4], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
        case BLACK_QUEEN:
            shape(blackFigures[5], HEIGHT_START + j * LENGTH, WIDTH_START + i * LENGTH, LENGTH, LENGTH);
            break;
    }
}