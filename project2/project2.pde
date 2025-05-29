String[][] layout = {
  {"Q","W","E","R","T","Y","U","I","O","P","DEL"},
  {"A","S","D","F","G","H","J","K","L"},
  {"Z","X","C","V","B","N","M"}
};

String[] sentences = {
  "She packed twelve blue pens in her small bag",
  "Every bird sang sweet songs in the quiet dawn",
  "They watched clouds drift across the golden sky",
  "A clever mouse slipped past the sleepy cat",
  "Green leaves danced gently in the warm breeze",
  "He quickly wrote notes before the test began",
  "The tall man wore boots made of soft leather",
  "Old clocks ticked loudly in the silent room",
  "She smiled while sipping tea on the front porch",
  "We found a hidden path behind the old barn",
  "Sunlight streamed through cracks in the ceiling",
  "Dogs barked at shadows moving through the yard",
  "Rain tapped softly against the window glass",
  "Bright stars twinkled above the quiet valley",
  "He tied the package with ribbon and string",
  "A sudden breeze blew papers off the desk",
  "The curious child opened every single drawer",
  "Fresh apples fell from the heavy tree limbs",
  "The artist painted scenes from her memory",
  "They danced all night under the glowing moon",
};

int rows = layout.length;
int extraKeys = 3; // CAPS, SPACE, ENTER

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
float hoverScale = 1.1;
float clickScale = 0.9;

// timer varibales
int curTrial = 0;
boolean isTimeRunning = false;
int startTime = 0;
int ellapseTime = 0;


// writer

PrintWriter out;

void setup() {
  size(1000, 600);
  font = createFont("Arial", 18);
  textFont(font);
  noCursor();

  // key dimensions
  int colsMax = 0;
  for (int r = 0; r < rows; r++) colsMax = max(colsMax, layout[r].length);
  keyW = width / (colsMax + 2);
  keyH = height / 12;

  ArrayList<PVector> posList = new ArrayList<PVector>();
  labelList = new ArrayList<String>();

  for (int r = 0; r < rows; r++) {
    int cols = layout[r].length;
    float startX = (width - cols * keyW) / 2 + keyW/2;
    float y = height * (0.3 + r * 0.15);
    for (int c = 0; c < cols; c++) {
      labelList.add(layout[r][c]);
      posList.add(new PVector(startX + c * keyW, y));
    }
  }
  //caps, space, and enter
  capsIndex = labelList.size();
  labelList.add("CAPS");
  posList.add(new PVector(width * 0.2, height * 0.80));
  labelList.add("SPACE");
  posList.add(new PVector(width * 0.5, height * 0.80));
  labelList.add("ENTER");
  posList.add(new PVector(width * 0.8, height * 0.80));

  labels = labelList.toArray(new String[0]);
  positions = posList.toArray(new PVector[0]);


  //writer 
  out = createWriter("testing.csv");
}

void draw() {
  background(245);
  hoveredIndex = findNearest(mouseX, mouseY);

  // top example
  fill(230);
  stroke(0);
  rect(50, 20, width - 100, 40, 8);
  fill(0);
  textSize(18);
  textAlign(LEFT, CENTER);
  text(sentences[curTrial], 60, 40);

  // input box
  fill(255);
  stroke(0);
  rect(50, 70, width - 100, 60, 8);
  fill(0);
  textSize(24);
  textAlign(LEFT, CENTER);
  float txtX = 60, txtY = 100;
  text(buffer.toString(), txtX, txtY);
  if ((frameCount / blinkPeriod) % 2 == 0) {
    float cw = textWidth(buffer.toString());
    line(txtX + cw, txtY - 20, txtX + cw, txtY + 20);
  }

  // draw keys
  textSize(18);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < labels.length; i++) {
    PVector p = positions[i];
    String lab = labels[i];
    // base width
    float baseW = (lab.equals("SPACE") ? keyW*5 : (lab.equals("CAPS") || lab.equals("ENTER") ? keyW*1.5 : keyW*0.9));
    // scale
    float s = (i==clickedIndex ? clickScale : (i==hoveredIndex ? hoverScale : 1));
    float w = baseW * s;
    float h = keyH*1.2 * s;
    // fill
    fill(i==clickedIndex ? color(118,165,222) : (i==hoveredIndex ? color(180,215,255) : 255));
    // stroke for CAPS
    if (i==capsIndex && capsOn) { stroke(0,100,200); strokeWeight(3); }
    else { stroke(80); strokeWeight(1); }
    rect(p.x - w/2, p.y - h/2, w, h, 6);
    // label
    fill(0);
    String dl = lab;
    if (dl.length()==1 && !capsOn) dl = dl.toLowerCase();
    text(dl, p.x, p.y);
  }

  textSize(16);
  textAlign(RIGHT, TOP);
  if (isTimeRunning) {
    ellapseTime = millis() - startTime;
  }
  
  text(ellapseTime / 1000, width - 60, 30);
}

int findNearest(float x, float y) {
  int best=-1; float bd=1e6;
  for (int i=0; i<positions.length; i++) {
    float d = dist(x,y,positions[i].x,positions[i].y);
    if (d<bd) { bd=d; best=i; }
  }
  return best;
}

void mousePressed() {
  clickedIndex = hoveredIndex;
  if (hoveredIndex<0) return;
  String key = labels[hoveredIndex];

  if (!isTimeRunning && !key.equals("ENTER")) {
    startTime = millis();
    isTimeRunning = true;
  }

  if (isTimeRunning && key.equals("ENTER")) {
    startTime = 0;
    isTimeRunning = false;
  }

  if (hoveredIndex==capsIndex) capsOn=!capsOn;
  else if (key.equals("SPACE")) buffer.append(' ');
  else if (key.equals("DEL")) { if(buffer.length()>0) buffer.deleteCharAt(buffer.length()-1); }
  else if (key.equals("ENTER")) {
    saveResultToFile();
    buffer.setLength(0);
    if (curTrial == sentences.length) {
      curTrial = 0;
    } else {
      curTrial++;
    }
  } else {
    buffer.append(capsOn?key:key.toLowerCase());
    saveResultToFile();
  }
}

void mouseReleased() {
  clickedIndex = -1;
}

void saveResultToFile() {
  String row = ellapseTime + "," + buffer.toString() + "," + sentences[curTrial];
  out.println(row);
  out.flush();
}