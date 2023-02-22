async function loadModule(message) {
    const {
        default: myModule
    } = await import(
        /* webpackChunkName: "tinymce" */
        "./tinymce"
    );
    return myModule;
}

const TinyMceHook = {
    async mounted() {
        if (!window.tinymce) {
            console.log('#log 8761 load tinymce hook ...');
            window.tinymce = await loadModule();
            console.log('#log 8761 loaded tinymce hook ✔', window.tinymce);
            if (window.tinymce_waitlist) {
                for (const callback of window.tinymce_waitlist) {
                    callback();
                }
                delete window.tinymce_waitlist;
            }
        }
    },
    beforeDestroy() {
        console.log('#log 9515 destroy tinymce');
        delete window.tinymce;
        delete window.tinymce_waitlist;
    },

};

export default TinyMceHook;
