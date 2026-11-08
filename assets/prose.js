// Wide tables scroll inside their own box on a narrow screen, so the page
// itself never scrolls sideways. The box takes keyboard focus so it can be
// scrolled with the arrow keys, and it is named for VoiceOver.
document.querySelectorAll(".prose table").forEach(function (table, i) {
  var box = document.createElement("div");
  box.className = "table-scroll";
  box.tabIndex = 0;
  box.setAttribute("role", "region");
  box.setAttribute("aria-label", tableName(table, i));
  table.parentNode.insertBefore(box, table);
  box.appendChild(table);
});

// Names a table after the heading above it, for example "Who receives data (table)".
function tableName(table, i) {
  for (var el = table.previousElementSibling; el; el = el.previousElementSibling) {
    if (/^H[1-6]$/.test(el.tagName)) return el.textContent.trim() + " (table)";
  }
  return "Table " + (i + 1);
}
