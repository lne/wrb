require 'timeout'
require 'base64'
require 'rb2html/factory'
require 'net/http'

JAILS='/jail/save'
JAILP='/jail/pub'

TIMEOUT = 5 #s

FORMATTER = Rb2HTML::Factory.get_formatter 'ruby'

INTERPRETER = {:host => 'localhost', :port => 4000, :uri => '/interpret'}
