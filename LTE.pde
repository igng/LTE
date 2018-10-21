class Piece
{
    int x_des;
    int y_des;
    int x_curr;
    int y_curr;
    boolean bordered;
    PImage image;
    
    Piece(int x_f, int y_f, int x_0, int y_0, PImage piece)
    {
        x_des = x_f;
        y_des = y_f;
        x_curr = x_0;
        y_curr = y_0;
        bordered = false;
        image = piece;
    }
    
    void info()
    {
        println("Curr:", str(x_curr) + "," + str(y_curr)," | Des:", str(x_des) + "," + str(y_des));
        println("Width:", image.width, "| Height", image.height);
    }
    
    void display()
    {
        image(image, x_curr, y_curr);
    }
    
    void border()
    {
        if (bordered && !first)
        {
            stroke(255, 0, 0);
            noFill();
            rect(x_curr, y_curr, image.width, image.height);
            noStroke();
        }
        else
            bordered = false;
    }
};

PFont bold;
PImage whole;                // whole image
Piece[] Pieces;              // pieces of the puzzle
static int EASY = 16;        // 16 pieces
static int MEDIUM = 64;      // 64 pieces
static int HARD = 256;       // 256 pieces

boolean first = true;
boolean on_verify = false;
boolean puzzle_complete = false;
int complexity = EASY;
int rows, cols;
int W, H;
int i, j;
int[] picked = {0, 0};
int x_ver = 350;
int y_ver = 500;
int w_ver = 100;
int h_ver = 50;

/* shuffling variables */
int MAX_SHUFFLING_TIME = 5000;
boolean shuffled = false; 

void info_pieces()
{
    for (i = 0; i < rows; i++)
        for (j = 0; j < cols; j++)
        {
            print("Piece", i*rows + j, "\t");
            Pieces[i*rows + j].info();
        }
}

void display_pieces()
{
    for (i = 0; i < rows; i++)
        for (j = 0; j < cols; j++)
        {
            Pieces[i*rows + j].display();
            Pieces[i*rows + j].border();
        }
}

void swap_pieces(int p1, int p2)
{
    Piece temp = new Piece(0, 0, 0, 0, whole.get(0, 0, 0, 0));
    
    temp.x_des = Pieces[p1].x_des;
    temp.y_des = Pieces[p1].y_des;
    temp.image = Pieces[p1].image;
    
    Pieces[p1].x_des = Pieces[p2].x_des;
    Pieces[p1].y_des = Pieces[p2].y_des;
    Pieces[p1].image = Pieces[p2].image;
    
    Pieces[p2].x_des = temp.x_des;
    Pieces[p2].y_des = temp.y_des;
    Pieces[p2].image = temp.image;
}

void shuffle_pieces()
{   
    for (i = 0; i < rows; i++)
        for (j = 0; j < cols; j++)
            swap_pieces(i*rows + j, (int) random(rows*cols));
    
    shuffled = true;
}

void check_swapness()
{
    if (picked[0] != picked[1])
    {
        swap_pieces(picked[0], picked[1]);
        picked[0] = picked[1];
    }
}

void verify_puzzle()
{
    float dist;
    
    for (i = 0; i < rows; i++)
        for (j = 0; j < cols; j++)
        {
            dist = sqrt(pow((Pieces[i*rows + j].x_des - Pieces[i*rows + j].x_curr), 2) + pow((Pieces[i*rows + j].y_des - Pieces[i*rows + j].y_curr), 2));
            
            if (dist > 10)
            {
                puzzle_complete = false;
                return;
            }
        }
        
    puzzle_complete = true;
}

void ver_button()
{   
    fill(0, 255, 0);
    rect(x_ver, y_ver, w_ver, h_ver);
    fill(0);
    text("CHECK", x_ver + 30, y_ver + 30);
    noFill();   
    
    float dist = sqrt(pow((mouseX - x_ver), 2) + pow((mouseY - y_ver), 2));
    
    if (dist < 100)
        on_verify = true;
    else
        on_verify = false;
}

void info_of_image()
{
    fill(255);
    stroke(255);
    textFont(bold);
    text("Name: Pillars of Creation", 820, 77);
    text("Constellation: Serpens", 820, 100);
    text("RA: " + str(18) + "h " + str(18) + "m " + str(48) + "s", 820, 123);
    text("DEC: -" + str(13) + "° " + str(49) + "'", 820, 146);
    text("Taken by: Hubble Space Telescope", 820, 169);
    text("They are so named because the gas", 820, 252);
    text("and dust in the process of creating", 820, 275);
    text("new stars, while also being", 820, 298);
    text("eroded by the light from nearby", 820, 321);
    text("stars that have recently formed.", 820, 344);
    text("More info at ", 880, 480);
    fill(0, 0, 200);
    stroke(0, 0, 200);
    String s = "https://www.nasa.gov/image-feature/the-pillars-of-creation/";
    text(s, 620, 510);
    line(620, 515, 1160, 515);
}

void setup()
{
    size(1200, 600);
    background(0);
    bold = createFont("Arial Bold", 18);
    whole = loadImage("/home/usagi/pil_resize.jpg");
    //whole = loadImage("/home/usagi/ori_resize.jpg");
    Pieces = new Piece[complexity];
    rows = (int) sqrt(complexity);
    cols = (int) sqrt(complexity);
    y_ver = whole.height;
    W = whole.width/rows;
    H = whole.height/rows;
    
    for (i = 0; i < rows; i++)
        for (j = 0; j < cols; j++)
            Pieces[i*rows + j] = new Piece(i*W, j*H, i*W, j*H, whole.get(i*W, j*H, W, H));
}

void draw()
{
    if (millis() < MAX_SHUFFLING_TIME)
        image(whole, 0, 0);
    else
    {
        if (shuffled == false)
            shuffle_pieces();
        else
        {
            ver_button();
            check_swapness();
            display_pieces();
        }
    }
}

void mousePressed()
{   
    int x_sel, y_sel, row, col;
    
    if (on_verify)
    {
        verify_puzzle();
        
        if (puzzle_complete)
        {
            stroke(0);
            fill(0);
            rect(x_ver - 200, y_ver, 200, 100);
            fill(0, 255, 0);
            stroke(0, 255, 0);
            text("PUZZLE COMPLETE", x_ver - 200, y_ver + 30);
            info_of_image();
            stop();
        }
        else
        {
            fill(255, 0, 0);
            stroke(255, 0, 0);
            text("PUZZLE NOT COMPLETE", x_ver - 200, y_ver + 30);
        }
    }
    
    x_sel = W*(1 + (mouseX/W));
    y_sel = H*(1 + (mouseY/H));
    
    row = (x_sel/W) - 1;
    col = (y_sel/H) - 1;
    
    if ((row >= rows) || (col >= cols))
        return;
    
    // select piece to swap
    Pieces[row*rows + col].bordered = true;
    
    if (first)
        picked[0] = picked[1] = row*rows + col;
    else
        picked[1] = row*rows + col;
    
    first = !first;
}
