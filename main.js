try {
  var seed = Math.floor(Math.random() * 2147483647);
  var flags = { seed: seed, window_width: window.innerWidth, window_height: window.innerHeight }
  var app = Elm.Main.init({ node: document.getElementById("elm"), flags: flags });
}
catch (e)
{
  // display initialization errors (e.g. bad flags, infinite recursion)
  var header = document.createElement("h1");
  header.style.fontFamily = "monospace";
  header.innerText = "Initialization Error";
  var pre = document.getElementById("elm");
  document.body.insertBefore(header, pre);
  pre.innerText = e;
  throw e;
}