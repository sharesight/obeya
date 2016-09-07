module Obeya
  class Ticket

    def initialize(title, description, format, ticket_type, bin)
      @title = title
      @description = description
      @format = format
      @ticket_type = ticket_type
      @bin = bin
    end

    def to_json
      {
        "name":           @title,
        "rtformat":       @format,
        "description":    normalise(@description),
        "bin_id":         @bin.id,
        "ticketType_id":  @ticket_type.id
      }.to_json
    end

    private

    def normalise(text)
      text.length > 40_000 ? (text[0...39_950] + '...[truncated]') : text
    end

  end
end
