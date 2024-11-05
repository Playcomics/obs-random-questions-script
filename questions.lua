obs = obslua
source_name = ""
questions = {
    "What's your favorite food?",
    "What regrets do you have with making the show?",
    "Why don't you stream these games?",
    "What happened to the comic reviews?",
    "Can you get [insert name here] as a guest?",
    "What's your research process for each episode?",
    "What is the ideal snack for comics reading? (Scott Wachter)",
    "Will this question show up when I update the repository tonight?",
    "When the Battletech graphic novel comes out, can I bully you into letting me on for an episode of a comic based on a game? (Billy)",
}
question_history = {}
current_history_index = 0
new_hotkey_id = obs.OBS_INVALID_HOTKEY_ID
next_hotkey_id = obs.OBS_INVALID_HOTKEY_ID
prev_hotkey_id = obs.OBS_INVALID_HOTKEY_ID

auto_change_timer = nil
auto_change_interval = 15 * 60 * 1000 -- 15 minutes in milliseconds

function reset_auto_change_timer()
    if auto_change_timer ~= nil then
        obs.timer_remove(auto_change_timer)
    end
    auto_change_timer = obs.timer_add(auto_change_question, auto_change_interval)
end

function auto_change_question()
    new_question()
end

function get_random_question()
    local index = math.random(1, #questions)
    while #question_history > 0 and index == question_history[#question_history] do
        index = math.random(1, #questions)
    end
    return index
end

function set_question_text(index)
    local text = questions[index]
    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", text)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
    end
end

function new_question()
    local index = get_random_question()
    table.insert(question_history, index)
    current_history_index = #question_history
    set_question_text(index)
    reset_auto_change_timer()
end

function next_question()
    if current_history_index < #question_history then
        current_history_index = current_history_index + 1
        set_question_text(question_history[current_history_index])
        reset_auto_change_timer()
    end
end

function previous_question()
    if current_history_index > 1 then
        current_history_index = current_history_index - 1
        set_question_text(question_history[current_history_index])
        reset_auto_change_timer()
    end
end

function activate_signal(cd, activating)
    local source = obs.calldata_source(cd, "source")
    if source ~= nil then
        local name = obs.obs_source_get_name(source)
        if (name == source_name) then
            if activating then
                new_question()
            end
        end
    end
end

function source_activated(cd)
    activate_signal(cd, true)
end

function source_deactivated(cd)
    activate_signal(cd, false)
end

function script_properties()
    local props = obs.obs_properties_create()
    local p = obs.obs_properties_add_list(props, "source", "Text Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            source_id = obs.obs_source_get_unversioned_id(source)
            if source_id == "text_gdiplus" or source_id == "text_ft2_source" then
                local name = obs.obs_source_get_name(source)
                obs.obs_property_list_add_string(p, name, name)
            end
        end
    end
    obs.source_list_release(sources)

    obs.obs_properties_add_bool(props, "enable_auto_change", "Enable Auto-change")
    local auto_change_interval_prop = obs.obs_properties_add_int(props, "auto_change_interval", "Auto-change Interval (minutes)", 1, 120, 1)
    
    obs.obs_property_set_visible(auto_change_interval_prop, false)
    
    local function toggle_auto_change(props, property, settings)
        local enable_auto_change = obs.obs_data_get_bool(settings, "enable_auto_change")
        obs.obs_property_set_visible(auto_change_interval_prop, enable_auto_change)
        return true
    end
    
    obs.obs_property_set_modified_callback(obs.obs_properties_get(props, "enable_auto_change"), toggle_auto_change)

    return props
end

function script_description()
    return "Generates new random questions and allows cycling through question history."
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")
    local enable_auto_change = obs.obs_data_get_bool(settings, "enable_auto_change")
    if enable_auto_change then
        auto_change_interval = obs.obs_data_get_int(settings, "auto_change_interval") * 60 * 1000
        reset_auto_change_timer()
    else
        if auto_change_timer ~= nil then
            obs.timer_remove(auto_change_timer)
            auto_change_timer = nil
        end
    end
end

function script_load(settings)
    local sh = obs.obs_get_signal_handler()
    obs.signal_handler_connect(sh, "source_activate", source_activated)
    obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)
    
    new_hotkey_id = obs.obs_hotkey_register_frontend("new_random_question_hotkey", "New Random Question", new_question)
    next_hotkey_id = obs.obs_hotkey_register_frontend("next_question_history_hotkey", "Next in Question History", next_question)
    prev_hotkey_id = obs.obs_hotkey_register_frontend("previous_question_history_hotkey", "Previous in Question History", previous_question)
    
    local new_hotkey_save_array = obs.obs_data_get_array(settings, "new_random_question_hotkey")
    local next_hotkey_save_array = obs.obs_data_get_array(settings, "next_question_history_hotkey")
    local prev_hotkey_save_array = obs.obs_data_get_array(settings, "previous_question_history_hotkey")
    
    obs.obs_hotkey_load(new_hotkey_id, new_hotkey_save_array)
    obs.obs_hotkey_load(next_hotkey_id, next_hotkey_save_array)
    obs.obs_hotkey_load(prev_hotkey_id, prev_hotkey_save_array)
    
    obs.obs_data_array_release(new_hotkey_save_array)
    obs.obs_data_array_release(next_hotkey_save_array)
    obs.obs_data_array_release(prev_hotkey_save_array)
    
    local enable_auto_change = obs.obs_data_get_bool(settings, "enable_auto_change")
    if enable_auto_change then
        auto_change_timer = obs.timer_add(auto_change_question, auto_change_interval)
    end
end

function script_save(settings)
    local new_hotkey_save_array = obs.obs_hotkey_save(new_hotkey_id)
    local next_hotkey_save_array = obs.obs_hotkey_save(next_hotkey_id)
    local prev_hotkey_save_array = obs.obs_hotkey_save(prev_hotkey_id)
    
    obs.obs_data_set_array(settings, "new_random_question_hotkey", new_hotkey_save_array)
    obs.obs_data_set_array(settings, "next_question_history_hotkey", next_hotkey_save_array)
    obs.obs_data_set_array(settings, "previous_question_history_hotkey", prev_hotkey_save_array)
    
    obs.obs_data_array_release(new_hotkey_save_array)
    obs.obs_data_array_release(next_hotkey_save_array)
    obs.obs_data_array_release(prev_hotkey_save_array)
end
