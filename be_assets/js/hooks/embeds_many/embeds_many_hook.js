import Sortable from 'sortablejs';

const defineComponent = () => {
    Alpine.data('embeds_many_component', ({target,event,form_as,field}) => ({
        target,
        event,
        form_as,
        field,
        init() {
            this.setupSortable()
        },
        setupSortable() {
            Sortable.create(this.$refs.items, {
                handle: '.drag-handle',
                animation: 150,
                onUpdate: () => this.syncSortOrder()
            });
        },
        syncSortOrder() {
            let new_order = [...this.$refs.items.children]
                .map(item => {
                    let hiddenInput = item.querySelector('input[name$="[id]"]')
                    return hiddenInput ? hiddenInput.value : null
                })
                .filter( item => item!==null );
            this.sendData(new_order);
        },
        sendData(new_order) {
            let encoded_data = this.serializeForm(this.$root.closest('form'));
            window.PhxContext.pushEventTo(this.target, this.event, {
                encoded_data,
                new_order,
                field: this.field,
                form_as: this.form_as
            });
        },
        serializeForm(form, meta = {}) {
            // adapted from: deps/phoenix_live_view/assets/js/phoenix_live_view/view.js :
            let formData = new FormData(form)
            let toRemove = []

            formData.forEach((val, key, _index) => {
                if (val instanceof File) {
                    toRemove.push(key)
                }
            })

            // Cleanup after building fileData
            toRemove.forEach(key => formData.delete(key))

            let params = new URLSearchParams()
            for (let [key, val] of formData.entries()) {
                params.append(key, val)
            }
            for (let metaKey in meta) {
                params.append(metaKey, meta[metaKey])
            }

            return params.toString()
        },
    }));
};
document.addEventListener('alpine:init', defineComponent);

const EmbedsManyHook = {};
export default EmbedsManyHook;
