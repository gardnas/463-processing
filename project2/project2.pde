String[][] layout = {
  {"Q","W","E","R","T","Y","U","I","O","P"},
  {"A","S","D","F","G","H","J","K","L"},
  {"Z","X","C","V","B","N","M"}
};

int rows = layout.length;
int extraKeys = 3;

ArrayList<String> labelList;
PVector[] positions;
String[] labels;

StringBuilder buffer = new StringBuilder();
PFont font;
float keyW, keyH;
int hoveredIndex = -1;
int clickedIndex = -1;
int capsIndex;
boolean capsOn = false;
int blinkPeriod = 30;

void setup() {
  size(1000, 600);
  font = createFont("Arial", 18);
  textFont(font);
  noCursor();

  // determine max columns for sizing
  int colsMax = 0;
  for (int r = 0; r < rows; r++) {
    colsMax = max(colsMax, layout[r].length);
  }
  keyW = width / (colsMax + 2);
  keyH = height / 12;

  ArrayList<PVector> posList = new ArrayList<PVector>();
  labelList = new ArrayList<String>();

  // flatten layout with lowered rows to clear text box
  for (int r = 0; r < rows; r++) {
    int cols = layout[r].length;
    float startX = (width - cols * keyW) / 2 + keyW/2;
    float y = height * (0.3 + r * 0.15);  // moved down from 0.2 to 0.3
    for (int c = 0; c < cols; c++) {
      labelList.add(layout[r][c]);
      posList.add(new PVector(startX + c * keyW, y));
    }
  }

  // extra keys at bottom (unchanged)
  capsIndex = labelList.size();
  labelList.add("CAPS");
  posList.add(new PVector(width * 0.2, height * 0.80));
  labelList.add("SPACE");
  posList.add(new PVector(width * 0.5, height * 0.80));
  labelList.add("DEL");
  posList.add(new PVector(width * 0.8, height * 0.80));

  labels = labelList.toArray(new String[0]);
  positions = posList.toArray(new PVector[0]);
}

void draw() {
  background(245);
  hoveredIndex = findNearest(mouseX, mouseY);

  // example sentence area
  fill(230);
  stroke(0);
  rect(50, 20, width - 100, 40, 8);
  fill(0);
  textSize(18);
  textAlign(LEFT, CENTER);
  text("The quick fox jumps over the lazy dog", 60, 40);

  // input text box
  fill(255);
  stroke(0);
  rect(50, 70, width - 100, 60, 8);

  // typing text
  fill(0);
  textSize(24);
  textAlign(LEFT, CENTER);
  float txtX = 60;
  float txtY = 100;
  text(buffer.toString(), txtX, txtY);
  if ((frameCount / blinkPeriod) % 2 == 0) {
    float cw = textWidth(buffer.toString());
    float cx = txtX + cw;
    line(cx, txtY - 20, cx, txtY + 20);
  }

  // draw keys with special widths
  textSize(18);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < labels.length; i++) {
    PVector p = positions[i];
    float w;
    float h = keyH * 1.2;
    if (labels[i].equals("SPACE")) {
      w = keyW * 4.5;
    } else if (labels[i].equals("CAPS") || labels[i].equals("DEL")) {
      w = keyW * 1.5;
    } else {
      w = keyW * 0.9;
    }
    if (i == hoveredIndex) {
      w *= 1.15;
      h *= 1.15;
      fill(180, 215, 255);
    } else {
      fill(255);
    }
    if (i == capsIndex && capsOn) {
      stroke(0, 100, 200);
      strokeWeight(3);
    } else {
      stroke(80);
      strokeWeight(1);
    }
    rect(p.x - w/2, p.y - h/2, w, h, 6);

    fill(0);
    String lbl = labels[i];
    if (lbl.length() == 1 && !capsOn){
      lbl = lbl.toLowerCase();
    } 
    text(lbl, p.x, p.y);
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
  } else if (key.equals("DEL") && buffer.length() > 0) {
    buffer.deleteCharAt(buffer.length() - 1);
  } else {
    buffer.append(capsOn ? key : key.toLowerCase());
  }
}
