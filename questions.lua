obs = obslua
source_name = ""
questions = {
    "What's your favorite food?",
    "Do you prefer coffee or tea?",
    "What's the most ridiculous rule you've ever had to follow?",
    "What's your dream vacation destination?",
    "Are you a morning person or a night owl?",
    "What's the most valuable life hack you've discovered by accident?",
    "What's your favorite season?",
    "If you were a kitchen utensil, which one would you be and why?",
    "Do you have any pets?",
    "What's your favorite hobby?",
    "What's the most ridiculous fact you've discovered by accident?",
    "Do you prefer books or movies?",
    "What's your favorite type of music?",
    "What's a common piece of advice that you think is actually terrible?",
    "If you could swap lives with anyone for a day, but it had to be someone within 1 mile of you right now, who would you choose?",
    "What's the best wrong answer you've ever given to a question?",
    "Are you an introvert or an extrovert?",
    "What's your favorite childhood memory?",
    "What's a skill you have that's useless now but might save the world someday?",
    "Do you prefer the city or the countryside?",
    "What's the worst piece of advice you've ever followed?",
    "What's your go-to comfort food?",
    "What's the most unexplainable photo on your phone?",
    "What's the creepiest 'coincidence' you've ever experienced?",
    "What's a question you're afraid to know the answer to?",
    "Are you a planner or spontaneous?",
    "What's the strangest thing you've done to impress someone?",
    "What's the most absurd thing you believed as a child?",
    "What's the most absurd thing you've convinced someone to believe?",
    "If you could rename yourself, what name would you choose?",
    "If you could read the group chat of any three historical figures, who would you choose?",
    "What's the most absurd conspiracy theory you can come up with on the spot?",
    "What's a seemingly innocent question that becomes creepy if you think about it too much?",
    "What's the biggest lie you've told to impress someone you liked?",
    "What's the strangest wrong number text you've ever received?",
    "What's a deal-breaker in a relationship that you'd never admit publicly?",
    "If Twitch chat could control your life for a day, what's the worst that could happen?",
    "What's a secret about the gaming industry that would shock most players?",
    "What's the weirdest way you've ever tried to get someone's attention online?",
    "If you could steal one skill from any streamer, whose would you take and why?",
    "What's the most embarrassing thing you've ever done for donations or subs?",
    "Are you in love right now, and does the person know?",
    "If you could make anyone in the world fall in love with you, would you do it? Who and why?",
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

    obs.obs_properties_add_button(props, "new_question", "New Question", new_question)
    obs.obs_properties_add_button(props, "next_question", "Next in History", next_question)
    obs.obs_properties_add_button(props, "prev_question", "Previous in History", previous_question)
    obs.obs_properties_add_int(props, "auto_change_interval", "Auto-change Interval (minutes)", 1, 120, 1)

    return props
end

function script_description()
    return "Generates new random questions and allows cycling through question history."
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")
    auto_change_interval = obs.obs_data_get_int(settings, "auto_change_interval") * 60 * 1000
    reset_auto_change_timer()
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
    
    auto_change_timer = obs.timer_add(auto_change_question, auto_change_interval)
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
