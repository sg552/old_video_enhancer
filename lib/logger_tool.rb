require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

# logger = LoggerTool.get_logger
# logger.info "lalala"
class LoggerTool
  include Log4r

  def self.get_logger

    log4r_config= YAML.load_file(File.join(File.dirname(__FILE__), '..', "config", "log4r.yml"))
    temp = log4r_config['log4r_config']

    YamlConfigurator.decode_yaml(temp)

    return Log4r::Logger['development']
  end
end
