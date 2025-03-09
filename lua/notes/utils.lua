-- lua/notes/utils.lua

local M = {}
local io = io
local path = require("plenary.path")
local vim = vim

local function get_module_path()
  local info = debug.getinfo(1, "S")
  return info.source:sub(2, -1)
end

function M.load_template(template_name, config)
  local template_path = config.templates[template_name]
  local user_template_used = false

  if template_path and template_path ~= "" then
    -- User-provided template
    template_path = vim.fn.expand(template_path)
    user_template_used = true
  else
    -- Use plugin template
    local module_path = get_module_path()
    local module_dir = path:new(module_path):parent()
    template_path = module_dir .. "/templates/" .. template_name .. ".md"
  end

  local file, err = io.open(template_path, "r")
  if not file then
    if user_template_used then
      vim.notify(
        "User template not found: " .. config.templates[template_name] .. ". Falling back to default template.",
        vim.log.levels.WARN
      )
      -- Fallback to default plugin template
      local module_path = get_module_path()
      local module_dir = path:new(module_path):parent()
      template_path = module_dir .. "/templates/" .. template_name .. ".md"
      file, err = io.open(template_path, "r") -- Try to load the default template
      if not file then
        -- Fallback to error template
        template_path = module_dir .. "/templates/error.md"
        file, err = io.open(template_path, "r")
        if not file then
          vim.notify("Failed to load default template: " .. template_name .. " and error template - " .. (err or "unknown"), vim.log.levels.ERROR)
          return nil
        end
      end
    else
      -- Fallback to error template.
      local module_path = get_module_path()
      local module_dir = path:new(module_path):parent()
      template_path = module_dir .. "/templates/error.md"
      file, err = io.open(template_path, "r")
      if not file then
        vim.notify("Failed to load default template: " .. template_name .. " and error template - " .. (err or "unknown"), vim.log.levels.ERROR)
        return nil
      end
    end
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
