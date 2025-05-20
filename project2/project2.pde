String[][] layout = {
  {"1","2","3","4","5","6","7","8","9","0","[","]","\\"},
  {"Q","W","E","R","T","Y","U","I","O","P"},
  {"A","S","D","F","G","H","J","K","L",";","'"},
  {"Z","X","C","V","B","N","M",",",".","/"}
};

int rows = layout.length;
int extraKeys = 3; // CAPS, SPACE, DEL

ArrayList<String> labelList;
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

  // flatten layout
  for (int r = 0; r < rows; r++) {
    int cols = layout[r].length;
    float startX = (width - cols * keyW) / 2 + keyW/2;
    float y = height * (0.2 + r * 0.15);
    for (int c = 0; c < cols; c++) {
      labelList.add(layout[r][c]);
      posList.add(new PVector(startX + c * keyW, y));
    }
  }

  // extra keys
  capsIndex = labelList.size();
  labelList.add("CAPS");
  posList.add(new PVector(width * 0.2, height * 0.85));
  labelList.add("SPACE");
  posList.add(new PVector(width * 0.5, height * 0.85));
  labelList.add("DEL");
  posList.add(new PVector(width * 0.8, height * 0.85));

  labels = labelList.toArray(new String[0]);
  positions = posList.toArray(new PVector[0]);
}

void draw() {
  background(245);
  hoveredIndex = findNearest(mouseX, mouseY);

  // draw text box
  fill(255);
  stroke(0);
  rect(50, 20, width - 100, 60, 8);

  // typed text and moving caret
  fill(0);
  textSize(24);
  textAlign(LEFT, CENTER);
  float txtX = 60, txtY = 50;
  text(buffer.toString(), txtX, txtY);
  if ((frameCount / blinkPeriod) % 2 == 0) {
    float cw = textWidth(buffer.toString());
    float cx = txtX + cw;
    line(cx, txtY - 20, cx,
