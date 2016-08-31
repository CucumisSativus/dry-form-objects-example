class CommandValidationFailed < StandardError
  attr_reader :messages
  def initialize(messages)
    super(readable_errors(messages))
    @messages = messages
  end

  private

  def readable_errors(messages)
    messages.map { |_,v| v }.flatten.join(' ')
  end
end
