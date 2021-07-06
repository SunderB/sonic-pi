let themes = {
  "light": "Light",
  "dark": "Dark",
  "high_contrast": "High Contrast"
};

function switch_theme(new_theme = "light") {
  if (new_theme in themes) {
    window.localStorage.setItem('theme', new_theme);

    for (t in themes) {
      var link = document.getElementById(`css-theme-${t}`);
      if (t == new_theme) {
        link.disabled = false;
      } else {
        link.disabled = true;
      }
    }
  } else {
    console.error(`Unknown theme '${new_theme}'`);
  }
}

function generate_buttons() {
  for (var [id, name] of Object.entries(themes)) {
    var theme_switcher = document.getElementById("theme-switcher");

    // Create button
    var button = document.createElement("button");
    button.setAttribute("onclick", `switch_theme("${id}")`);
    button.innerHTML = name;
    theme_switcher.appendChild(button);
  }
}

function setup_themes() {
  // Add event listeners to the radio buttons
  var theme_switcher = document.getElementsByClassName("theme-switcher")[0];
  var radio_buttons = theme_switcher.querySelectorAll("input[type='radio']");
  if (radio_buttons.length == 0) {
    console.error("Theme buttons not detected!")
  }
  for (var i = 0; i < radio_buttons.length; i++) {
    var theme = radio_buttons[i].getAttribute("value");
    console.log(theme)
    radio_buttons[i].setAttribute("onclick", `switch_theme("${theme}")`);
  }

  // Set theme to the user set value on page load
  var current_theme = window.localStorage.getItem("theme");
  if (current_theme == null) {
    // Default to light theme
    current_theme = "light";
  }
  theme_switcher.querySelectorAll(`#option-theme-${current_theme}`)[0].setAttribute("checked", true);
  switch_theme(current_theme);
}

window.addEventListener("load", setup_themes, false);
