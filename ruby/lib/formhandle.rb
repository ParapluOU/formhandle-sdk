# frozen_string_literal: true

require_relative "formhandle/output"
require_relative "formhandle/api"
require_relative "formhandle/config"
require_relative "formhandle/prompt"
require_relative "formhandle/cli"
require_relative "formhandle/commands/init"
require_relative "formhandle/commands/resend"
require_relative "formhandle/commands/status"
require_relative "formhandle/commands/cancel"
require_relative "formhandle/commands/snippet"
require_relative "formhandle/commands/test"
require_relative "formhandle/commands/whoami"
require_relative "formhandle/commands/open"

module FormHandle
  VERSION = "0.1.0"
end
