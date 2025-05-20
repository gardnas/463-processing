String[][] layout = {
  {"Q","W","E","R","T","Y","U","I","O","P"},
  {"A","S","D","F","G","H","J","K","L"},
  {"Z","X","C","V","B","N","M"}
};

int rows = layout.length;
int colsMax = 10;
int totalLetters = 26;
int extraKeys = 3; // CAPS, SPACE, DEL

PVector[] positions;
String[] labels;

StringBuilder buffer = new StringBuilder();
PFont font;
float keyW, keyH;
int hoveredIndex = -1;
int capsIndex;
boolean capsOn = false;
int blinkPeriod = 30;

void setup() {
  size(900, 600);
  font = createFont("Arial", 18);
  textFont(font);
  noCursor();

  // calculate key size based on layout
  keyW = width / (colsMax + 2);
  keyH = height / 12;

  // flatten labels and positions
  labels = new String[totalLetters + extraKeys];
  ArrayList<PVector> posList = new ArrayList<PVector>();

  int idx = 0;
  for (int r = 0; r < rows; r++) {
    int cols = layout[r].length;
    float startX = (width - cols*keyW) / 2 + keyW/2;
    float y = height * (0.3 + r*0.15);
    for (int c = 0; c < cols; c++) {
      labels[idx] = layout[r][c];
      posList.add(new PVector(startX + c*keyW, y));
      idx++;
    }
  }
  // CAPS, SPACE, DEL
  capsIndex = idx;
  labels[idx] = "CAPS";
  posList.add(new PVector(width*0.3, height*0.75));
  idx++;
  labels[idx] = "SPACE";
  posList.add(new PVector(width*0.5, height*0.75));
  idx++;
  labels[idx] = "DEL";
  posList.add(new PVector(width*0.7, height*0.75));

  positions = posList.toArray(new PVector[0]);
}

void draw() {
  background(245);
  hoveredIndex = findNearest(mouseX, mouseY);

  // draw text box
  fill(255);
  stroke(0);
  rect(50, 20, width - 100, 60, 8);
  fill(0);
  textSize(24);
  // left-align buffer text
  textAlign(LEFT, CENTER);
  float txtX = 60;
  float txtY = 50;
  text(buffer.toString(), txtX, txtY);

  // blinking caret moves with text
  if ((frameCount / blinkPeriod) % 2 == 0) {
    float txtWidth = textWidth(buffer.toString());
    float caretX = txtX + txtWidth;
    float y1 = txtY - 20;
    float y2 = txtY + 20;
    stroke(0);
    line(caretX, y1, caretX, y2);
  }

  // draw keys
  textSize(18);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < labels.length; i++) {
    PVector p = positions[i];
    float w = keyW * 0.9;
    float h = keyH * 1.2;
    if (i == hoveredIndex) {
      w *= 1.2;
      h *= 1.2;
    }
    fill(i == hoveredIndex ? color(180, 215, 255) : 255);

    // indicate caps state on CAPS key
    if (i == capsIndex && capsOn) {
      stroke(0, 100, 200);
      strokeWeight(3);
    } else {
      stroke(80);
      strokeWeight(1);
    }
    rect(p.x - w/2, p.y - h/2, w, h, 6);

    // draw label with case
    fill(0);
    String toDraw = labels[i];
    if (toDraw.length() == 1 && !capsOn) {
      toDraw = toDraw.toLowerCase();
    }
    text(toDraw, p.x, p.y);
  }
}

int findNearest(float x, float y) {
  int best = -1;
  float bd = Float.MAX_VALUE;
  for (int i = 0; i < positions.length; i++) {
    float d = dist(x, y, positions[i].x, positions[i].y);
    if (d < bd) {
      bd = d;
      best = i;
    }
  }
  return best;
}

void mousePressed() {
  if (hoveredIndex < 0) return;
  String key = labels[hoveredIndex];
  if (hoveredIndex == capsIndex) {
    capsOn = !capsOn;
  } else if (key.equals("SPACE")) {
    buffer.append(' ');
  } else if (key.equals("DEL")) {
    if (buffer.length() > 0) buffer.deleteCharAt(buffer.length()-1);
  } else {
    buffer.append(capsOn ? key : key.toLowerCase());
  }
}
