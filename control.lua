require("mod-gui")
require("util")

script.on_configuration_changed(function()
    for _, player in pairs(game.players) do
        gui_init(player)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    gui_init(player)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    local player = game.players[event.player_index]

    if event.setting == "qbie_display_gui_button" then
        local value = settings.get_player_settings(player)["qbie_display_gui_button"].value
        mod_gui.get_frame_flow(player)["qbie_flow_choose_action"].visible = value
    end
end)


script.on_event("qbie_import", function(event)
    local player = game.players[event.player_index]
    toggle_main_window(player, "import")
end)

script.on_event("qbie_export", function(event)
    local player = game.players[event.player_index]
    toggle_main_window(player, "export")
end)


script.on_event(defines.events.on_gui_click, function(event)
    local player = game.players[event.player_index]

    if event.element.name == "qbie_button_show_options" then
        show_actions(player)
    elseif event.element.name == "qbie_button_import" then
        create_main_window(player, "import")
    elseif event.element.name == "qbie_button_export" then
        create_main_window(player, "export")
    elseif event.element.name == "qbie_button_close_window" then
        close_main_window(player, "close")
    elseif event.element.name == "qbie_button_submit_window" then
        close_main_window(player, "submit")
    else
        hide_actions(player)
    end
end)


function gui_init(player)
    local frame_flow = mod_gui.get_frame_flow(player)
    if not frame_flow["qbie_flow_choose_action"] then
        local flow = frame_flow.add{type="flow", name="qbie_flow_choose_action", direction="horizontal"}
        flow.visible = settings.get_player_settings(player)["qbie_display_gui_button"].value
        flow.add{type="button", name="qbie_button_show_options", caption="QBIE", tooltip={"tooltip.action_tip"},
          style=mod_gui.button_style}
    end
end


function show_actions(player)
    if player.gui.left["qbie_frame_main_window"] == nil then
        local flow = mod_gui.get_frame_flow(player)["qbie_flow_choose_action"]
        flow["qbie_button_show_options"].visible = false
        flow.add{type="button", name="qbie_button_import",  caption={"label.import"}, style=mod_gui.button_style}
        flow.add{type="button", name="qbie_button_export",  caption={"label.export"}, style=mod_gui.button_style}
    end
end

function hide_actions(player)
    local flow = mod_gui.get_frame_flow(player)["qbie_flow_choose_action"]
    flow["qbie_button_show_options"].visible = true
    if flow["qbie_button_import"] then flow["qbie_button_import"].destroy() end
    if flow["qbie_button_export"] then flow["qbie_button_export"].destroy() end
end


function create_main_window(player, type)
    hide_actions(player)

    local window = player.gui.left.add{type="frame", name="qbie_frame_main_window", direction="vertical"}
    window.caption = {"label." .. type}

    local error_message = window.add{type="label", name="qbie_label_error_message", caption=""}
    error_message.style.font_color = {r = 1, g = 0.2, b = 0.2}
    error_message.style.bottom_margin = 4
    error_message.style.single_line = false
    error_message.visible = false

    local text_box = window.add{type="text-box", name="qbie_text-box_quickbar_string"}
    text_box.style.width = 450
    text_box.style.height = 200
    text_box.style.bottom_margin = 6
    text_box.word_wrap = true

    if type == "export" then
        text_box.text = generate_export_string(player)
    end
    text_box.focus()

    local button_bar = window.add{type="flow", name="qbite_flow_button_bar", direction="horizontal"}
    button_bar.add{type="button", name="qbie_button_close_window", caption={"label.close"}}
    local spacer = button_bar.add{type="flow", name="qbie_flow_spacer", direction="horizontal"}
    spacer.style.horizontally_stretchable = true

    if type == "import" then
        button_bar.add{type="button", name="qbie_button_submit_window", caption={"label.submit"}}
    end
end

function close_main_window(player, action)
    local window = player.gui.left["qbie_frame_main_window"]

    if action == "submit" then
        local import_string = window["qbie_text-box_quickbar_string"].text
        local success, error = pcall(apply_import_string, player, import_string)
        if not success then
            local error_message_label = window["qbie_label_error_message"]
            error_message_label.visible = true
            if string.find(error, "^Unknown item name:.*") then 
                error_message_label.caption = {"label.error_invalid_item"}
            else
                error_message_label.caption = {"label.error_invalid_string"}
            end
            return
        end
    end

    window.destroy()
end

function toggle_main_window(player, type)
    local window = player.gui.left["qbie_frame_main_window"]
    if window == nil then
        create_main_window(player, type)
    else
        local current_type = window.caption[1]:sub(7)
        if (current_type == "import" and type == "export") or
          (current_type == "export" and type == "import") then
            close_main_window(player, "close")
            create_main_window(player, type)
        elseif (current_type == "import" and type == "import") or
          (current_type == "export" and type == "export") then
          close_main_window(player, "close")
        end
    end
end


function generate_export_string(player)
    local quickbar_names = {}
    for i=1, 100 do
        local slot = player.get_quick_bar_slot(i)
        if slot ~= nil then
            table.insert(quickbar_names, slot.name)
        else
            table.insert(quickbar_names, "")
        end
    end
    return util.encode(game.table_to_json(quickbar_names))
end

function apply_import_string(player, string)
    local quickbar_names = game.json_to_table(util.decode(string))
    for index, name in ipairs(quickbar_names) do
        if name ~= "" then
            player.set_quick_bar_slot(index, name)
        else
            player.set_quick_bar_slot(index, nil)
        end
    end
end