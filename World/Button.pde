public class Button {

  int bWidth;
  int bHeight;
  PVector textLocation;
  String text;
  color bColor;
  int textSize;
  PVector bLocation;
  
  public Button() {}
  
  public Button(int bWidth, int bHeight, PVector textLocation, String text, int textSize, PVector bLocation, color bColor) {
    this.bWidth = bWidth;
    this.bHeight = bHeight;
    this.textLocation = textLocation;
    this.text = text;
    this.bColor = bColor;
    this.textSize = textSize;
    this.bLocation = bLocation;
  }
  
  void display() {
    textMode(CENTER);
    rectMode(CENTER);
    rect(bLocation.x, bLocation.y, bWidth, bHeight);
    fill(bColor);
    textSize(textSize);
    text(text, textLocation.x, textLocation.y);
    fill(#FFFFFF);
  }

}
