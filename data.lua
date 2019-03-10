data:extend({
    {
        type = "custom-input",
        name = "qbie_import",
        order = "a",
        key_sequence = "CONTROL + SHIFT + I",
        consuming = "all"
    },
    {
        type = "custom-input",
        name = "qbie_export",
        order = "b",
        key_sequence = "CONTROL + SHIFT + E",
        consuming = "all"
    },

    {
        type = "shortcut",
        name = "qbie-import-quickbar",
        order = "d[quickbar]-a[import]",
        action = "lua",
        localised_name = {"shortcut.import-quickbar"},
        icon =
        {
            filename = "__quickbarimportexport__/icons/import-quickbar-x32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {"icon"}
        },
        small_icon =
        {
            filename = "__quickbarimportexport__/icons/import-quickbar-x24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {"icon"}
        },
        disabled_small_icon =
        {
            filename = "__quickbarimportexport__/icons/import-quickbar-x24-white.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {"icon"}
        }
    },
    {
        type = "shortcut",
        name = "qbie-export-quickbar",
        order = "d[quickbar]-b[export]",
        action = "lua",
        localised_name = {"shortcut.export-quickbar"},
        icon =
        {
            filename = "__quickbarimportexport__/icons/export-quickbar-x32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {"icon"}
        },
        small_icon =
        {
            filename = "__quickbarimportexport__/icons/export-quickbar-x24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {"icon"}
        },
        disabled_small_icon =
        {
            filename = "__quickbarimportexport__/icons/export-quickbar-x24-white.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {"icon"}
        }
    }
})