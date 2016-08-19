module OoxmlParser
  # TODO: Rename to Size after renaming current Size to DocumentSize
  # Class for parsing `w:sz` object
  class RunSize < OOXMLDocumentObject
    # @return [Integer] value of size
    attr_accessor :value

    # Parse Size
    # @param [Nokogiri::XML:Node] node with Size
    # @return [Size] result of parsing
    def self.parse(node)
      index = RunSize.new
      node.attributes.each do |key, value|
        case key
        when 'val'
          index.value = value.value.to_f
        end
      end
      index
    end
  end
end
