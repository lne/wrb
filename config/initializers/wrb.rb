require 'timeout'
require 'base64'
require 'rb2html/factory'

JAILR='/jail/readonly'
JAILS='/jail/save'
JAILP='/jail/pub'

TIMEOUT = 5 #s

FORMATTER = Rb2HTML::Factory.get_formatter 'ruby'

