--[[
  https://github.com/Silverfeelin/Starbound-TechDirectives/blob/master/LICENSE

  Require this script inside the init function of a tech script!
  require "/scripts/techDirectives.lua"

  -- Some examples:
  tech.appendDirectives("white", "?setcolor=ffffff", 1)
  tech.appendDirectives("glow", "?border=2;ff0000ff;ff000000", 0)
  tech.applyDirectives()
  tech.updateDirectives("glow", "?border=2;0000ffff;0000ff00")
  tech.setDirectivesPriority("glow", 2)
  tech.applyDirectives()
]]

if not update then error("The update function was not yet defined by the game. The techDirectives script should be required inside the init function!") end

local private = {}
local public = {}
techDirectives = public

private.debugging = true
private.apply = false
private.enabledDirectives = {}
private.disabledDirectives = {}

--[[
  Gets a full directive string for all currently enabled directives after
  sorting them
  @see private.sortDirectives
  @return Directives string.
]]
function public.getParentDirectives()
  private.sortDirectives()

  local d = ""
  -- Only use enabled directives.
  for _,v in ipairs(private.enabledDirectives) do
    if v.enabled then
      d = d .. v.directives
    end
  end

  return d
end

--[[
  Appends new directives using the given parameters.
  This shouldn't be used to update, enable or disable directives that have
  already been appended.
  @param name - Identifier used to modify these directives. Should be
    unique to prevent conflicts and other issues when modifying.
  @param directives - Current directives string to append.
    EG. "?setcolor=ffffff"
  @param [priority=0] - Priority of the directives to append. Directives with a
    lower priority are applied before directives with a higher priority.
    Directives that share the same priority are sorted by name.
  @param [enabled=true] - Value indicating whether the directives are enabled
    or not.
  @return Identifier of the appended directives. If no identifier was given, a
    generated number as string.
]]
function public.appendDirectives(name, directives, priority, enabled)
  if type(name) ~= "string" then name = tostring(#private.enabledDirectives + 1) end
  if type(directives) ~= "string" then directives = "" end
  if type(enabled) ~= "boolean" then enabled = true end
  if type(priority) ~= "number" then priority = 0 end

  local d = { name = name, directives = directives, priority = priority, enabled = enabled }

  local ls = enabled and private.enabledDirectives or private.disabledDirectives
  table.insert(ls, d)

  if enabled then
    public.applyDirectives()
  end

  return name
end

--[[
  Updates the value of appended directives.
  @param name - Identifier used to modify these directives. Should be
    unique to prevent conflicts and other issues when modifying.
  @param directives - New directives string value.
    EG. "?setcolor=ffffff"
]]
function public.updateDirectives(name, directives)
  if type(directives) ~= "string" then directives = "" end
  local d = public.getDirectives(name)
  d.directives = directives

  public.applyDirectives()
end

--[[
  Enables or disables appended directives.
  @param name - Identifier used to modify these directives. Should be
    unique to prevent conflicts and other issues when modifying.
  @param enabled - Value indicating whether the directives are enabled
    or not.
]]
function public.toggleDirectives(name, enabled)
  local d = public.getDirectives(name)
  if type(enabled) ~= "boolean" then enabled = not d.enabled end

  if d.enabled == enabled then
    local str = enabled and "enable" or "disable"
    private.logWarn("Attempted to %s directives %s while they are already %s.",
      str,
      name,
      (str .. "d")
    )
  else
    d.enabled = enabled
    public.removeDirectives(name)
    local ls = d.enabled and private.enabledDirectives or private.disabledDirectives
    table.insert(ls, d)
    public.applyDirectives()
  end
end

--[[
  Enables the appended directives.
  @see public.toggleDirectives
]]
function public.enableDirectives(name) public.toggleDirectives(name, true) end

--[[
  Disables the appended directives.
  @see public.toggleDirectives
]]
function public.disableDirectives(name) public.toggleDirectives(name, false) end

--[[
  Sets the priority of appended directives. Updates the directives on
  the user's character if the directives are enabled.
  @param name - Name of the appended directives.
  @param priority - New priority for the directives.
]]
function public.setDirectivesPriority(name, priority)
  local d = public.getDirectives(name)
  d.priority = priority
  if d.enabled then public.applyDirectives() end
end

--[[
  Removes appended directives for a really, really long time.
  @param name - Identifier of the appended directives.
  @return - True if the appended directives were removed, false if they could
    not be found.
]]
function public.removeDirectives(name)
  for k,v in ipairs(private.enabledDirectives) do
    if v.name == name then
      table.remove(private.enabledDirectives, k)
      public.applyDirectives()
      return true
    end
  end
  for k,v in ipairs(private.disabledDirectives) do
    if v.name == name then
      table.remove(private.disabledDirectives, k)
      return true
    end
  end
  return false
end

--[[
  Sets an indicator for the script to apply all directives near the end of this
  update tick. Does not cause any issues when called multiple times in the same
  update tick.
]]
function public.applyDirectives()
  private.apply = true
end

--[[
  Logs info with a TechDirectives prefix.
  @param str - Message.
  @param [...] - String format arguments.
  @see sb.logInfo
]]
function private.logInfo(str, ...)
  sb.logInfo("TechDirectives: " .. str, ...)
end

--[[
  Logs a warning with a TechDirectives prefix.
  @param str - Message.
  @param [...] - String format arguments.
  @see sb.logInfo
]]
function private.logWarn(str, ...)
  sb.logWarn("TechDirectives: " .. str, ...)
end

--[[
  Logs an error with a TechDirectives prefix.
  @param str - Message.
  @param [...] - String format arguments.
  @see sb.logInfo
]]
function private.logError(str, ...)
  sb.logError("TechDirectives: " .. str, ...)
end

--[[
  Sorts the directives table.
  Directives are sorted by priority (lowest first). Directives with the same
  priority are sorted by name (alphabetically)
  @see private.enabledDirectives
]]
function private.sortDirectives()
  table.sort(private.enabledDirectives, function(a,b)
    if a.priority ~= b.priority then
      return a.priority < b.priority
    else
      return a.name:lower() < b.name:lower()
    end
  end)
end

--[[
  Returns the directives for the given name.
  Caution: Manually editing variables may have undesired results.
  @error Invalid directives name. Error in implementation that probably
    shouldn't be ignored.
]]
function public.getDirectives(name)
  for _,v in ipairs(private.enabledDirectives) do
    if v.name == name then return v end
  end
  for _,v in ipairs(private.disabledDirectives) do
    if v.name == name then return v end
  end
  error("Directives with the name '" .. name .. "' do not exist.")
end

--[[
  Logs the name of all enabled and disabled directives.
  @param [enabled=true] - Indicates whether enabled directives should be logged.
  @param [disabled=true] - Indicates whether disabled directives should be
    logged.
]]
function public.logDirectives(enabled, disabled)
  if type(enabled) ~= "boolean" then enabled = true end
  if type(disabled) ~= "boolean" then disabled = true end
  if not enabled and not disabled then return end

  local str = "\n--logDirectives--\n"
  if enabled then
    str = str .. "The following directives are enabled:\n"
    for _,v in ipairs(private.enabledDirectives) do
      str = str .. v.name .. "\n"
    end
  end
  if disabled then
    str = str .. "The following directives are disabled:\n"
    for _,v in ipairs(private.disabledDirectives) do
      str = str .. v.name .. "\n"
    end
  end
  str = str .. "--end logDirectives--"
  private.logInfo(str)
end

----
-- Inject directives handling.
----
local oldUpdate = update
update = function(args)
  oldUpdate(args)

  if private.apply then
    private.apply = false
    local dir = public.getParentDirectives()
    if private.debugging then private.logInfo("Set directives to %s", dir) end
    tech.setParentDirectives(dir)
  end
end

----
-- Aliases
----
for k,v in pairs(public) do
  if tech[k] then
    private.logWarn("TechDirectives could not create the following alias: tech.%s. You can still call techDirectives.%s.", k, k)
  else
    tech[k]=v
  end
end
