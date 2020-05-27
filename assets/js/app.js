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
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"
import Ace from "ace-builds"
import "ace-builds/webpack-resolver";

let Hooks = {}
Hooks.LinkEditor = {
  mounted() {
    let language = this.el.dataset.language
    let mode = `ace/mode/${language.toLowerCase()}`;
    let editor = Ace.edit(this.el, {
      maxLines: 50,
      minLines: 10,
      mode: mode,
      theme: "ace/theme/solarized_light"
    })
    let id = this.el.dataset.id
    editor.getSession().setTabSize(2)
    editor.getSession().on("change", e => {
      let content = editor.getSession().getValue();
      this.pushEventTo(`#editor-${id}`, "update", { node: { id, content } })
    })
  }

}

Hooks.AutoFocus = {
  mounted() {
    this.el.focus()
  }
}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
