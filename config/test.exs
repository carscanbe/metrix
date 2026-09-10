import Config

# Streamline logger output to just the message for easier testing
config :logger, :default_formatter,
  format: "$message\n",
  colors: [enabled: false]
