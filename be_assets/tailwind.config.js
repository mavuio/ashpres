const defaultTheme = require('tailwindcss/defaultTheme')

const colors = require('tailwindcss/colors')
const plugin = require("tailwindcss/plugin")

module.exports = {
    future: {},
    content: [
        "../lib/my_app_be/**/*eex",
        "../lib/my_app_be/**/*.html.ex",
        "../lib/my_app_be/**/(live|views)/**/*.ex",
        "../lib/my_app_be/**/*live*/**/*.ex",
        "../lib/my_app_be/**/ce/*.ex",
        "./js/**/*.js",
        "../deps/mavu*/**/*eex",
        "../linked/mavu*/**/*eex",
    ],
    theme: {
        container: {
            center: true,
            padding: {
                DEFAULT: '1rem',
                sm: '0',
            }
        },
        extend: {
            screens: {
                'xs': {
                    'max': '639px'
                },
                'print': {
                    'raw': 'print'
                },
            },
            colors: {
                'primary': colors.purple
            },
        }
    },
    plugins: [
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography'),
        require('@tailwindcss/aspect-ratio'),
        plugin(({addVariant}) => addVariant("is-active", [".is-active&", ".is-active &"])),
        plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
        plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
        plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
        plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"]))    
    ]


}
