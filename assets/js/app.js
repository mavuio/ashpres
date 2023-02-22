import Alpine from 'alpinejs'

import "phoenix_html"
import {
    Socket
} from "phoenix"
import NProgress from "nprogress"
import {
    LiveSocket
} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

import "regenerator-runtime/runtime.js";



const RootHook = {
    mounted() {
        this.handleEvent("root.console_log", (payload) => console.log(payload.msg, payload.data))
        this.handleEvent("root.console_error", (payload) => console.error(payload.msg, payload.data))
    },
};


const PhxContextHook = {
    mounted() {
        window.PhxContext = this;
        this.handleEvent("reload_page", function () {
            window.location.reload();
        });
    }
};


window.Alpine = Alpine
Alpine.start()

window.Hooks = {
    PhxContextHook,
    RootHook,
};

if (typeof window.LocalHooks !== "undefined") {
    window.Hooks = {
        ...window.Hooks,
        ...window.LocalHooks,
    };
}



window["setWaiting"] = function (enable) {
    var container = document.getElementById("maincontent");
    if (enable) {
        NProgress.start();
        container.classList.add(["phx-loading"]);
    } else {
        NProgress.done();
        container.classList.remove([
            ["phx-loading"]
        ]);
    }
};


let liveSocket = new LiveSocket("/live", Socket, {
    dom: {
        // onBeforeNodeAdded(node) {
        //     if (node.id) {
        //         console.log(`#log 9521 will add node ${node.id}`, node);
        //     }
        //     return true;

        // },

        onBeforeElUpdated(from, to) {
            if (from.isEqualNode(to)) {
                return false;
            }
            if (from._x_dataStack) {
                // console.log('#cloned alpine component', from.id);
                window.Alpine.clone(from, to)
            }
        },
        onNodeAdded: function (node) {
            //     if (node.id) {
            //         console.log(`#log 9521 added node ${node.id}`, node);
            //     }
            if (node.nodeName === 'SCRIPT') {
                var script = document.createElement('script');
                //copy over the attributes
                [...node.attributes].forEach(attr => {
                    script.setAttribute(attr.nodeName, attr.nodeValue)
                })
                script.innerHTML = node.innerHTML;
                node.replaceWith(script)
            }
        },
    },
    params: {
        _csrf_token: csrfToken
    },
    hooks: window.Hooks //mwuits
})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
