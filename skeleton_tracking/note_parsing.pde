class note {
  float timestamp;
  Float left;
  Float right;
  
  note(float timestamp, Float left, Float right) {
    this.timestamp = timestamp;
    this.left = left;
    this.right = right;
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
  for (int i = 0; i < json.size(); i++) {
    JSONArray noteData = json.getJSONArray(i);
    note n = new note(noteData.getFloat(0), noteData.getFloat(1), noteData.getFloat(2));
    notes.add(n);
  }
  return notes;
}
