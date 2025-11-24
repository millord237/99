local LoggerLevel = require("logger.level")

--- @class SRSOptions
--- @field logger_level? number
--- @field logger_path? string

--- @class SRSConfig
--- @field logger_level number
--- @field logger_path string

--- @param opts SRSOptions
local function init(opts)
    local config = opts or {
        logger_level = LoggerLevel.FATAL,
    }

end

return init
