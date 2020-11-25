local mod_gui = require("mod-gui")

script.on_configuration_changed(function()
    for _, player in pairs(game.players) do
        gui_reset(player)
        gui_init(player)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    gui_init(player)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting == "qbie_display_gui_button" then
        local player = game.get_player(event.player_index)
        local value = settings.get_player_settings(player)["qbie_display_gui_button"].value
        mod_gui.get_button_flow(player)["qbie_flow_choose_action"].visible = value
    end
end)


script.on_event("qbie_import", function(event)
    local player = game.get_player(event.player_index)
    toggle_main_window(player, "import", "close")
end)

script.on_event("qbie_export", function(event)
    local player = game.get_player(event.player_index)
    toggle_main_window(player, "export", "close")
end)


script.on_event(defines.events.on_gui_confirmed, function(event)
    local player = game.get_player(event.player_index)
    if event.element.name == "qbie_textfield_quickbar_string" then
        close_main_window(player, "submit")
    end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    local player = game.get_player(event.player_index)
    if event.prototype_name == "qbie-import-quickbar" then
        toggle_main_window(player, "import", "close")
    elseif event.prototype_name == "qbie-export-quickbar" then
        toggle_main_window(player, "export", "close")
    end
end)


script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)

    if event.element.type == "textfield" then
        event.element.select_all()

    elseif event.element.name == "qbie_button_show_options" then
        show_actions(player)
    elseif event.element.name == "qbie_button_import" then
        toggle_main_window(player, "import", "close")
    elseif event.element.name == "qbie_button_export" then
        toggle_main_window(player, "export", "close")
    elseif event.element.name == "qbie_button_close_window" then
        toggle_main_window(player, nil, "close")
    elseif event.element.name == "qbie_button_submit_window" then
        toggle_main_window(player, nil, "submit")
    else
        hide_actions(player)
    end
end)


function gui_init(player)
    local frame_flow = mod_gui.get_button_flow(player)
    if not frame_flow["qbie_flow_choose_action"] then
        local flow = frame_flow.add{type="flow", name="qbie_flow_choose_action", direction="horizontal"}
        flow.visible = settings.get_player_settings(player)["qbie_display_gui_button"].value
    end

    local flow = frame_flow["qbie_flow_choose_action"]
    if not flow["qbie_button_show_options"] then
        flow.add{type="sprite-button", name="qbie_button_show_options", sprite="utility/import_slot",
          tooltip={"tooltip.action_tip"}, style=mod_gui.button_style}
    end
end

function gui_reset(player)
    local button_flow = mod_gui.get_button_flow(player)["qbie_flow_choose_action"]
    if button_flow then button_flow.clear() end
    local window = mod_gui.get_frame_flow(player)["qbie_frame_main_window"]
    if window then window.destroy() end
end


function show_actions(player)
    if mod_gui.get_frame_flow(player)["qbie_frame_main_window"] == nil then
        local flow = mod_gui.get_button_flow(player)["qbie_flow_choose_action"]
        flow["qbie_button_show_options"].visible = false
        flow.add{type="button", name="qbie_button_import", caption={"label.import"}, style=mod_gui.button_style}
        flow.add{type="button", name="qbie_button_export", caption={"label.export"}, style=mod_gui.button_style}
    else
        toggle_main_window(player, nil, "close")
    end
end

function hide_actions(player)
    local flow = mod_gui.get_button_flow(player)["qbie_flow_choose_action"]
    flow["qbie_button_show_options"].visible = true
    if flow["qbie_button_import"] then flow["qbie_button_import"].destroy() end
    if flow["qbie_button_export"] then flow["qbie_button_export"].destroy() end
end


function toggle_main_window(player, type, action)
    local window = mod_gui.get_frame_flow(player)["qbie_frame_main_window"]
    if window == nil then
        create_main_window(player, type)
    else
        local current_type = window.caption[1]:sub(7)
        if type == nil then
            close_main_window(player, action)
        elseif (current_type == "import" and type == "export") or
          (current_type == "export" and type == "import") then
            close_main_window(player, action)
            create_main_window(player, type)
        elseif (current_type == "import" and type == "import") or
          (current_type == "export" and type == "export") then
            close_main_window(player, action)
        end
    end
end

function create_main_window(player, type)
    hide_actions(player)

    local window = mod_gui.get_frame_flow(player).add{type="frame", name="qbie_frame_main_window",
      direction="vertical", caption={"label." .. type}}

    local content_frame = window.add{type="frame", name="content_frame", direction="vertical",
      style="inside_shallow_frame_with_padding"}

    -- Labels and textbox
    content_frame.add{type="label", name="qbie_label_warning", caption={"label." .. type .. "_warning"},
      tooltip={"label." .. type .. "_warning_tooltip"}}

    local label_error = content_frame.add{type="label", name="qbie_label_error_message", caption=""}
    label_error.style.font_color = {r = 1, g = 0.2, b = 0.2}
    label_error.visible = false

    local textfield = content_frame.add{type="textfield", name="qbie_textfield_quickbar_string"}
    textfield.style.width = 400
    textfield.style.top_margin = 10

    if type == "export" then
        textfield.text = generate_export_string(player)
        textfield.select_all()
    end
    textfield.focus()

    -- Button bar
    local button_bar = window.add{type="flow", direction="horizontal", style="dialog_buttons_horizontal_flow"}

    button_bar.add{type="button", name="qbie_button_close_window", style="back_button", caption={"label.close"}}

    local pusher = button_bar.add{type="empty-widget", style="draggable_space"}
    pusher.style.horizontally_stretchable = true
    pusher.style.height = 32
    pusher.style.margin = {0, 4}

    if type == "import" then
        button_bar.add{type="button", name="qbie_button_submit_window", style="confirm_button", caption={"label.submit"}}
    end
end

function close_main_window(player, action)
    local content_frame = mod_gui.get_frame_flow(player)["qbie_frame_main_window"]["content_frame"]

    local error_message
    if action == "submit" then
        local encoded_string = content_frame["qbie_textfield_quickbar_string"].text
        if encoded_string == "" then
            error_message = {"label.error_invalid_string"}
        else
            local decoded_string = game.decode_string(encoded_string)
            if decoded_string == nil then
                error_message = {"label.error_invalid_string"}
            else
                for index, name in ipairs(game.json_to_table(decoded_string)) do
                    local status = pcall(import_item, player, index, name)
                    if not status then error_message = {"label.error_invalid_item"} end
                end
            end
        end

        if error_message ~= nil then
            local error_message_label = content_frame["qbie_label_error_message"]
            error_message_label.visible = true
            error_message_label.caption = error_message
            content_frame["qbie_label_warning"].visible = false

            content_frame["qbie_textfield_quickbar_string"].focus()
            return  -- Early return so the window doesn't close
        end
    end

    content_frame.parent.destroy()
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
    return game.encode_string(game.table_to_json(quickbar_names))
end

function import_item(player, index, name)
    if name ~= "" then
        player.set_quick_bar_slot(index, name)
    else
        player.set_quick_bar_slot(index, nil)
    end
end
