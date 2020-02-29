class pos {
  float x;
  float y;
  
  pos(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  pos(JSONObject data) {
    this(data.getFloat("x"), data.getFloat("y"));
  }
}

class note {
  float timestamp;
  pos left;
  pos right;
  
  note(float timestamp, pos left, pos right) {
    this.timestamp = timestamp;
    this.left = left;
    this.right = right;
  }
  
  note(JSONObject data) {
    this(
      data.getFloat("timestamp"),
      data.isNull("left") ? null : new pos(data.getJSONObject("left")),
      data.isNull("right") ? null : new pos(data.getJSONObject("right"))
    );
  }
  
  boolean hasLeft() {
    return this.left != null;
  }
  
  boolean hasRight() {
    return this.right != null;
  }
  
  boolean hasBoth() {
    return this.hasLeft() && this.hasRight();
  }
}

ArrayList<note> parseNotes() {
  JSONArray json = loadJSONArray("notes.json");
  ArrayList<note> notes = new ArrayList<note>(json.size());
  for (int i = 0; i < json.size(); i++)
    notes.add(new note(json.getJSONObject(i)));
  return notes;
}
