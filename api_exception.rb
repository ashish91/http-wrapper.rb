class ApiException < StandardError
  attr_reader :api_errors

  def initialize(api_errors: "")
    self.api_errors = parse_error(api_errors)
    super
  end

  private
  attr_writer :api_errors
  def parse_error(errors)
    return JSON.parse(errors) if valid_json?(errors)

    errors
  end

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError => e
    false
  end
end
