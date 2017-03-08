module TeamworkScrapeClient
  class Project
    attr_accessor :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def [](key)
      attributes[key]
    end

    def start_date
      Date.parse(attributes['startDate'])
    end

    # Returns the date offset needed when using this project as a template
    def days_offset
      (Date.today - start_date).to_i
    end
  end
end