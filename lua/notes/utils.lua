local M = {}
local io = io
local path = require("plenary.path")
local vim = vim

local function get_module_path()
	local info = debug.getinfo(1, "S")
	return info.source:sub(2, -1)
end

function M.load_template(template_name)
	local module_path = get_module_path()
	local module_dir = path:new(module_path):parent()
	local template_path = module_dir .. "/templates/" .. template_name

	local file, err = io.open(template_path, "r")
	if not file then
		vim.notify("Failed to load template: " .. template_name .. " - " .. (err or "unknown"), vim.log.levels.ERROR)
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

function M.replace_template_variables(template_content, variables)
	local replaced_content = template_content
	for variable, value in pairs(variables) do
		replaced_content = replaced_content:gsub("{{" .. variable .. "}}", value)
	end
	return replaced_content
end

return M
