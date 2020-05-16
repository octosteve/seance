// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"
import "bootstrap"
import $ from 'jquery';

window.jQuery = $;
window.$ = $;

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import Ace from "ace-builds"
import "ace-builds/webpack-resolver";

let Hooks = {}
Hooks.LinkEditor = {
  mounted() {
    console.log("WE EHRE")
    console.log(this)
    let id = this.el.getAttribute("id")
    this.editor = Ace.edit(id, {
      maxLines: 50,
      minLines: 10,
      mode: "ace/mode/elixir",
    })
    this.editor.setTheme("ace/theme/twilight");
    this.editor.session.setMode("ace/mode/elixir");
  }
}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
