local this = {
    color_groups = {},
    color_groups_indices = {},
    valid_labels = {},
    search_and = {},
    search_or = {},
    num_colors = {},
}

function this.contains(array, search_for)
    for _, value in ipairs(array) do
        if value == search_for then
            return true
        end
    end
    return false
end
function this.is_valid_label(label)
    return this.contains(this.valid_labels, label)
end
function this.insert_if_valid_label_and_not_already_in_array(array, tag)
    if not this.is_valid_label(tag) then
        return
    end
    if this.contains(array, tag) then
        return
    end
    table.insert(array, tag)
end
function this.tag_search_string_to_list(tags_as_string)
    if #tags_as_string == 0 then
        return {}
    end
    local tags = {}
    for tag in string.gmatch(tags_as_string, "%S+") do
        this.insert_if_valid_label_and_not_already_in_array(tags, tag)
    end
    return tags
end
function this.calc_num_colors(num_colors_as_string)
    if num_colors_as_string == nil
        or #num_colors_as_string == 0
        or num_colors_as_string == ""
        or num_colors_as_string == "[ Any ]"
    then
        return nil
    end
    return tonumber(num_colors_as_string, 10)
end
function this.search(search_and, search_or, num_colors)
    this.color_groups_indices = {}
    this.valid_labels = this.get_all_labels()
    this.search_and = this.tag_search_string_to_list(search_and)
    this.search_or = this.tag_search_string_to_list(search_or)
    this.num_colors = this.calc_num_colors(num_colors)

    if #this.search_and == 0 and #this.search_or == 0 and this.num_colors == nil then
        this.clear_search()
        return
    end

    -- must fulfill clause: num_colors_matches ∨ ((and_1 ∧ and_2 ∧ ... ∧ and_N) ∧ (or_1 ∨ or_2 ∨ ... ∨ or_M))
    for i=1, #this.color_groups do
        local color_group_labels = this.color_groups[i].labels
        local color_group_num_colors = #this.color_groups[i].colors

        -- only allow the colors according to the number of colors
        if this.num_colors ~= nil then
            if color_group_num_colors ~= this.num_colors then
                goto skip_item
            end
            if #this.search_and == 0 and #this.search_or == 0 then
                goto or_clause_match
            end
        end

        -- search all and-clauses
        for j=1, #this.search_and do
            local label_check = this.search_and[j]
            for k=1, #color_group_labels do
                local label = color_group_labels[k]
                if label == label_check then
                    goto and_clause_member_matched
                end
            end
            -- at least one item in the and-clause di not match,
            -- otherwise we would have skipped to ::and_clause_member_matched::
            goto skip_item

            ::and_clause_member_matched::
        end

        -- search all or-clauses
        if #this.search_or == 0 then
            goto or_clause_match
        end
        for j=1, #this.search_or do
            local label_check = this.search_or[j]
            for k=1, #color_group_labels do
                local label = color_group_labels[k]
                if label == label_check then
                    goto or_clause_match
                end
            end
        end
        -- no item in the or-clause matched,
        -- otherwise we would have skipped to ::or_clause_match::
        goto skip_item

        ::or_clause_match::
        -- clause matched, add this index to the search results
        table.insert(this.color_groups_indices, i)

        ::skip_item::
    end
end

function this.clear_search()
    this.color_groups_indices = {}
    for i=1, #this.color_groups do
        table.insert(this.color_groups_indices, i)
    end
end


function this.set_color_groups(cg)
    this.color_groups = cg
end


function this.get_all_labels()
    local tbl = {}
    for i=1, #this.color_groups do
        local color_group = this.color_groups[i]
        for j=1, #color_group.labels do
            local label = color_group.labels[j]
            for k=1, #tbl do
                if tbl[k] == label then
                    goto skip_this_label
                end
            end
            table.insert(tbl, label)
            ::skip_this_label::
        end
    end
    return tbl
end

function this.get_all_color_group_lengths()
    local tbl = {}
    table.insert(tbl, "[ Any ]")
    for i=1, #this.color_groups do
        local color_group_size = #this.color_groups[i].colors
        for k=1, #tbl do
            if tbl[k] == tostring(color_group_size) then
                goto skip_this
            end
        end
        table.insert(tbl, tostring(color_group_size))
        ::skip_this::
    end
    return tbl
end

function this.get_labels_and()
    local as_str = ""
    for i=1, #this.search_and do
        as_str = as_str .. this.search_and[i]
        if i ~= #this.search_and then
            as_str = as_str .. " "
        end
    end
    return as_str
end

function this.get_labels_or()
    local as_str = ""
    for i=1, #this.search_or do
        as_str = as_str .. this.search_or[i]
        if i ~= #this.search_or then
            as_str = as_str .. " "
        end
    end
    return as_str
end

function this.get_search_num_colors()
    return this.num_colors
end


function this.get_color_group(i)
    local mapped_index = this.color_groups_indices[i]
    return this.color_groups[mapped_index]
end

function this.num_results()
    return #this.color_groups_indices
end

function this.empty()
    return #this.color_groups_indices == 0
end

return this