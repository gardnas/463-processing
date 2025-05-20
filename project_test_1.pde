// Global variables
String typedText = "";
PFont mainFont;
PFont keyTextFont;

// Keyboard layout (QWERTY-like)
String[] row0Chars = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="};
String[] row1Chars = {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]"};
String[] row2Chars = {"A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'"};
String[] row3Chars = {"Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"};
LetterKey[][] letterKeyRows = new LetterKey[4][];

// Special keys
LetterKey spaceButton;
LetterKey deleteButton;
LetterKey shiftButton; 

// Dimensions and positions
float displayBoxX, displayBoxY, displayBoxW; 
final float DISPLAY_BOX_H_CONST = 75; 
float baseKeySize = 55; 
float keyPadding = 2;   
float rowStartY;

// Snapped key state
LetterKey currentlySnappedKey = null; 
float keyScaleFactor = 1.10; 

boolean shiftActive = false;

void settings() {
  int maxKeysHorizontal = 0;
  if (row0Chars.length > 0) { 
      maxKeysHorizontal = row0Chars.length;
  } else if (row1Chars.length > 0) {
      maxKeysHorizontal = row1Chars.length; 
  }
  String[][] allRowsForWidth = {row0Chars, row1Chars, row2Chars, row3Chars};
  int trueMaxKeysHorizontal = 0;
  for(String[] row : allRowsForWidth) {
      if (row.length > trueMaxKeysHorizontal) {
          trueMaxKeysHorizontal = row.length;
      }
  }
  float shiftKeyWidthEst = baseKeySize * 2.2f;
  float spaceBarWidthEst = baseKeySize * 6.5f; 
  float deleteKeyWidthEst = baseKeySize * 2.5f; 
  float specialKeysRowWidthEst = shiftKeyWidthEst + keyPadding + spaceBarWidthEst + keyPadding + deleteKeyWidthEst;
  float estimatedKeyboardContentWidth = trueMaxKeysHorizontal * (baseKeySize + keyPadding) - keyPadding; 
  estimatedKeyboardContentWidth = max(estimatedKeyboardContentWidth, specialKeysRowWidthEst); 
  float estimatedKeyboardWidth = estimatedKeyboardContentWidth + baseKeySize * 1.5f; 
  float estimatedKeyboardHeight = DISPLAY_BOX_H_CONST + 70 + 
                                 4 * (baseKeySize + keyPadding + 5) + 
                                 (baseKeySize + 20 + 50); 
  size(int(max(980, estimatedKeyboardWidth + 60)), int(max(620, estimatedKeyboardHeight))); 
}

void setup() {
  noCursor(); // Hide the system mouse cursor. This should be effective when the sketch window is active.

  mainFont = createFont("Arial", 26); 
  keyTextFont = createFont("Arial", 20); 

  displayBoxX = 30;
  displayBoxY = 30;
  displayBoxW = width - 60;

  rowStartY = displayBoxY + DISPLAY_BOX_H_CONST + 50; 

  String[][] allKeyChars = {row0Chars, row1Chars, row2Chars, row3Chars};
  float[] rowHorizontalOffsets = {0, baseKeySize * 0.35f, baseKeySize * 0.65f, baseKeySize * 0.95f}; 

  for (int r = 0; r < allKeyChars.length; r++) {
    letterKeyRows[r] = new LetterKey[allKeyChars[r].length];
    float currentRowY = rowStartY + r * (baseKeySize + keyPadding + 5); 
    float totalRowWidth = allKeyChars[r].length * baseKeySize + (allKeyChars[r].length - 1) * keyPadding;
    float keysInitialX = ((width - totalRowWidth) / 2) + rowHorizontalOffsets[r]; 

    for (int c = 0; c < allKeyChars[r].length; c++) {
      letterKeyRows[r][c] = new LetterKey(allKeyChars[r][c], 
                                        keysInitialX + c * (baseKeySize + keyPadding), 
                                        currentRowY, 
                                        baseKeySize, baseKeySize, keyTextFont);
    }
  }

  float specialButtonHeight = baseKeySize; 
  float specialButtonsY = rowStartY + 4 * (baseKeySize + keyPadding + 5) + 20; 
  float shiftKeyWidth = baseKeySize * 2.2f;
  float spaceBarWidth = baseKeySize * 6.5f; 
  float deleteKeyWidth = baseKeySize * 2.5f; 
  float totalBottomRowWidth = shiftKeyWidth + keyPadding + spaceBarWidth + keyPadding + deleteKeyWidth;
  float bottomRowStartX = (width - totalBottomRowWidth) / 2;

  shiftButton = new LetterKey("SHIFT", bottomRowStartX, specialButtonsY, shiftKeyWidth, specialButtonHeight, keyTextFont);
  spaceButton = new LetterKey("SPACE", bottomRowStartX + shiftKeyWidth + keyPadding, specialButtonsY, spaceBarWidth, specialButtonHeight, keyTextFont);
  deleteButton = new LetterKey("DELETE", bottomRowStartX + shiftKeyWidth + keyPadding + spaceBarWidth + keyPadding, specialButtonsY, deleteKeyWidth, specialButtonHeight, keyTextFont);

  // Default snapped key: Set to the first key in the first row.
  if (letterKeyRows.length > 0 && letterKeyRows[0] != null && letterKeyRows[0].length > 0) {
    currentlySnappedKey = letterKeyRows[0][0];
  } else if (shiftButton != null) { // Fallback if letter rows are somehow empty
      currentlySnappedKey = shiftButton;
  }
}

void draw() {
  background(210, 215, 220); 

  updateSnappedKeyState(); 

  fill(255); 
  stroke(100); 
  strokeWeight(1.5f);
  rect(displayBoxX, displayBoxY, displayBoxW, DISPLAY_BOX_H_CONST, 8); 
  
  textFont(mainFont);
  fill(20); 
  textAlign(LEFT, CENTER);
  text(typedText, displayBoxX + 20, displayBoxY + DISPLAY_BOX_H_CONST / 2);

  for (int r = 0; r < letterKeyRows.length; r++) {
    if (letterKeyRows[r] != null) {
      for (int c = 0; c < letterKeyRows[r].length; c++) {
        if (letterKeyRows[r][c] != null) {
          letterKeyRows[r][c].render(letterKeyRows[r][c] == currentlySnappedKey, keyScaleFactor, shiftActive);
        }
      }
    }
  }
  
  if (shiftButton != null) shiftButton.render(shiftButton == currentlySnappedKey, keyScaleFactor, shiftActive);
  if (spaceButton != null) spaceButton.render(spaceButton == currentlySnappedKey, keyScaleFactor, false); 
  if (deleteButton != null) deleteButton.render(deleteButton == currentlySnappedKey, keyScaleFactor, false); 
}

void updateSnappedKeyState() {
  // Check if mouse is directly over any key. If so, update currentlySnappedKey.
  // If not, currentlySnappedKey remains as it was (sticky snap).

  for (int r = 0; r < letterKeyRows.length; r++) {
    if (letterKeyRows[r] != null) {
      for (int c = 0; c < letterKeyRows[r].length; c++) {
        if (letterKeyRows[r][c] != null && letterKeyRows[r][c].isPointerOverOriginalBounds()) {
          currentlySnappedKey = letterKeyRows[r][c];
          return; // New key snapped, exit
        }
      }
    }
  }

  if (shiftButton != null && shiftButton.isPointerOverOriginalBounds()) {
    currentlySnappedKey = shiftButton;
    return;
  }
  if (spaceButton != null && spaceButton.isPointerOverOriginalBounds()) {
    currentlySnappedKey = spaceButton;
    return;
  }
  if (deleteButton != null && deleteButton.isPointerOverOriginalBounds()) {
    currentlySnappedKey = deleteButton;
    return;
  }
  
  // If we reach here, the mouse is not directly over any key.
  // currentlySnappedKey will retain its previous value, achieving the "sticky" effect.
  // If currentlySnappedKey is somehow still null (shouldn't happen after setup default), ensure a default.
  if (currentlySnappedKey == null) {
      if (letterKeyRows.length > 0 && letterKeyRows[0] != null && letterKeyRows[0].length > 0) {
        currentlySnappedKey = letterKeyRows[0][0];
      } else if (shiftButton != null) {
          currentlySnappedKey = shiftButton;
      }
  }
}

void mousePressed() {
  if (currentlySnappedKey != null) {
    // Check if the click is on the visually snapped key
    if (currentlySnappedKey.isPointerOverVisualBounds(true, keyScaleFactor)) {
      if (currentlySnappedKey == shiftButton) {
        shiftActive = !shiftActive; 
      } else if (currentlySnappedKey == spaceButton) {
        typedText += " ";
        if (shiftActive && !isShiftSticky()) shiftActive = false; 
      } else if (currentlySnappedKey == deleteButton) {
        if (typedText.length() > 0) {
          typedText = typedText.substring(0, typedText.length() - 1);
        }
        if (shiftActive && !isShiftSticky()) shiftActive = false; 
      } else { 
        String charToType = currentlySnappedKey.getDisplayChar(shiftActive);
        typedText += charToType;
        if (shiftActive && !isShiftSticky()) shiftActive = false; 
      }
    }
  }
}

boolean isShiftSticky() {
  return false; 
}

class LetterKey {
  String baseCharLabel; 
  String shiftCharLabel; 
  float xPos, yPos, keyWidth, keyHeight; 
  PFont kFont; 

  color defaultFill = color(240, 240, 245); 
  color highlightFill = color(190, 215, 255); 
  color shiftActiveFill = color(170, 200, 230); 
  color keyStrokeColor = color(140);       
  color keyFontColor = color(10, 10, 20);  
  float keyCornerRadius = 7;              

  LetterKey(String label, float x, float y, float w, float h, PFont fontToUse) {
    baseCharLabel = label.toLowerCase(); 
    if (label.equalsIgnoreCase("SHIFT") || label.equalsIgnoreCase("SPACE") || label.equalsIgnoreCase("DELETE")) {
        baseCharLabel = label; 
        shiftCharLabel = label;
    } else if (label.matches("[a-z]")) {
        shiftCharLabel = label.toUpperCase();
    } else {
        switch(label) {
            case "1": shiftCharLabel = "!"; break;
            case "2": shiftCharLabel = "@"; break;
            case "3": shiftCharLabel = "#"; break;
            case "4": shiftCharLabel = "$"; break;
            case "5": shiftCharLabel = "%"; break;
            case "6": shiftCharLabel = "^"; break;
            case "7": shiftCharLabel = "&"; break;
            case "8": shiftCharLabel = "*"; break;
            case "9": shiftCharLabel = "("; break;
            case "0": shiftCharLabel = ")"; break;
            case "-": shiftCharLabel = "_"; break;
            case "=": shiftCharLabel = "+"; break;
            case "[": shiftCharLabel = "{"; break;
            case "]": shiftCharLabel = "}"; break;
            case ";": shiftCharLabel = ":"; break;
            case "'": shiftCharLabel = "\""; break;
            case ",": shiftCharLabel = "<"; break;
            case ".": shiftCharLabel = ">"; break;
            case "/": shiftCharLabel = "?"; break;
            default: shiftCharLabel = label.toUpperCase(); 
        }
    }
    if (label.equalsIgnoreCase("SPACE")) baseCharLabel = "SPACE"; 
    if (label.equalsIgnoreCase("DELETE")) baseCharLabel = "DELETE";
    if (label.equalsIgnoreCase("SHIFT")) baseCharLabel = "SHIFT";

    xPos = x;
    yPos = y;
    keyWidth = w;
    keyHeight = h;
    kFont = fontToUse;
  }

  String getDisplayChar(boolean isShiftCurrentlyActive) {
    if (baseCharLabel.equals("SHIFT") || baseCharLabel.equals("SPACE") || baseCharLabel.equals("DELETE")) {
        return baseCharLabel; 
    }
    return isShiftCurrentlyActive ? shiftCharLabel : baseCharLabel;
  }

  void render(boolean isSnapped, float scaleFactor, boolean isShiftSystemActive) {
    float displayX = xPos;
    float displayY = yPos;
    float displayWidth = keyWidth;
    float displayHeight = keyHeight;
    
    color currentFill = defaultFill;
    if (isSnapped) {
      currentFill = highlightFill;
    }
    if (baseCharLabel.equals("SHIFT") && isShiftSystemActive) {
        currentFill = shiftActiveFill; 
    }

    if (isSnapped) {
      displayWidth = keyWidth * scaleFactor;
      displayHeight = keyHeight * scaleFactor;
      displayX = xPos - (displayWidth - keyWidth) / 2;
      displayY = yPos - (displayHeight - keyHeight) / 2;
    }
    
    fill(currentFill);
    stroke(keyStrokeColor);
    strokeWeight(1.3f);
    rect(displayX, displayY, displayWidth, displayHeight, keyCornerRadius);

    textFont(kFont); 
    fill(keyFontColor);
    textAlign(CENTER, CENTER);
    
    float currentTextSize = kFont.getSize(); 
    String charToDisplayOnKey = getDisplayChar(isShiftSystemActive);

    if (charToDisplayOnKey.equals("SPACE")) {
      currentTextSize *= 0.70; 
    } else if (charToDisplayOnKey.equals("DELETE") || charToDisplayOnKey.equals("SHIFT")) {
      currentTextSize *= 0.75; 
    } else if (charToDisplayOnKey.length() > 1 && keyWidth < baseKeySize * 1.5) { 
      currentTextSize *= 0.80;
    } else if (charToDisplayOnKey.length() == 1) { 
        currentTextSize *= 1.1; 
    }
    textSize(currentTextSize);

    text(charToDisplayOnKey, displayX + displayWidth / 2, displayY + displayHeight / 2);
  }

  boolean isPointerOverOriginalBounds() {
    return mouseX >= xPos && mouseX <= xPos + keyWidth &&
           mouseY >= yPos && mouseY <= yPos + keyHeight;
  }

  boolean isPointerOverVisualBounds(boolean isCurrentlyScaledAsSnapped, float scaleFactor) {
    float currentVisualX = xPos;
    float currentVisualY = yPos;
    float currentVisualWidth = keyWidth;
    float currentVisualHeight = keyHeight;

    if (isCurrentlyScaledAsSnapped) { 
      currentVisualWidth = keyWidth * scaleFactor;
      currentVisualHeight = keyHeight * scaleFactor;
      currentVisualX = xPos - (currentVisualWidth - keyWidth) / 2;
      currentVisualY = yPos - (currentVisualHeight - keyHeight) / 2;
    }
    
    return mouseX >= currentVisualX && mouseX <= currentVisualX + currentVisualWidth &&
           mouseY >= currentVisualY && mouseY <= currentVisualY + currentVisualHeight;
  }
}
