class HttpRequestService
  def initialize(url)
    @connection = faraday_connection
    @base_uri = url
  end

  def post(endpoint:, body:)
    Rails.logger.info "#" * 100
    Rails.logger.info "url: #{full_url(endpoint)}"
    Rails.logger.info "params: #{body}"
    Rails.logger.info "#" * 100

    response = @connection.post(full_url(endpoint), body)

    Rails.logger.info "#" * 100
    Rails.logger.info "Body: #{response.body}"
    Rails.logger.info "Status: #{response.status}"
    Rails.logger.info "#" * 100

    raise_api_exception(api_errors: response.body) if response.status != 200

    response
  rescue Faraday::ConnectionFailed => e
    raise_api_exception(api_errors: e.message)
  end

  def get(endpoint:, params: {})
    Rails.logger.info "#" * 100
    Rails.logger.info "url: #{full_url(endpoint)}"
    Rails.logger.info "params: #{params}"
    Rails.logger.info "#" * 100

    response = @connection.get(full_url(endpoint), params)

    Rails.logger.info "#" * 100
    Rails.logger.info "Body: #{response.body}"
    Rails.logger.info "Status: #{response.status}"
    Rails.logger.info "#" * 100

    raise_api_exception(api_errors: response.body) if response.status != 200

    response
  rescue Faraday::ConnectionFailed => e
    raise_api_exception(api_errors: e.message)
  end

  def delete(endpoint:)
    Rails.logger.info "#" * 100
    Rails.logger.info "url: #{full_url(endpoint)}"
    Rails.logger.info "#" * 100

    response = @connection.delete(full_url(endpoint))

    Rails.logger.info "#" * 100
    Rails.logger.info "Body: #{response.body}"
    Rails.logger.info "Status: #{response.status}"
    Rails.logger.info "#" * 100

    raise_api_exception(api_errors: response.body) if response.status != 200

    response
  rescue Faraday::ConnectionFailed => e
    raise_api_exception(api_errors: e.message)
  end

  private
  def faraday_connection
    Faraday.new do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests and responses to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def full_url(endpoint)
    URI.join(@base_uri, endpoint).to_s
  end

  def raise_api_exception(api_errors:)
    raise ApiException.new(api_errors: api_errors)
  end
end
