module Obeya
  class Ticket

    # title, description, format, ticket_type, bin, id=nil
    def initialize(*params)
      if params.first.is_a?(Hash)
        @ticket_fields = params.first
      else
        @ticket_fields = {}
        [:title, :description, :format, :ticket_type, :bin, :id].each_with_index do |param_key, idx|
          break if idx>=params.size
          @ticket_fields[param_key] = params[idx]
        end
      end
    end

    def self.from_obeya(src_hash, ticket_types, bins)
      Obeya::Ticket.new Hash[
        src_hash.map do |obeya_name, field_value|
          case(obeya_name)
            when 'rtformat'
              [:format, field_value]
            when 'name'
              [:title, field_value]
            when 'ticketType_id'
              [:ticket_type, ticket_types[field_value.to_i]]
            when 'bin_id'
              [:bin, bins[field_value.to_i]]
            else
              [obeya_name.to_sym, field_value]
          end
        end
      ]
    end

    def to_obeya
      Hash[@ticket_fields.map do |field_name, field_value|
        case(field_name)
          when :format
            ['rtformat', field_value]
          when :title
            ['name', field_value]
          when :description
            ['description', normalise(field_value)]
          when :ticket_type
            ['ticketType_id', field_value.id]
          when :bin
            ['bin_id', field_value.id]
          else
            [field_name.to_s, field_value]
        end
      end]
    end

    def to_json
      to_obeya.to_json
    end

    def method_missing(name)
      return @ticket_fields[name] if @ticket_fields.key?(name)

      super
    end

    private

    def normalise(text)
      text.length > 40_000 ? (text[0...39_950] + '...[truncated]') : text
    end

  end
end
