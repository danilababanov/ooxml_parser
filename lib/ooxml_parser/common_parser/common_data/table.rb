require_relative 'table/row/row'
require_relative 'table/table_properties'
require_relative 'table/table_grid'
require_relative 'table/margins/table_margins'
require_relative 'table/margins/paragraph_margins'
module OoxmlParser
  class Table < OOXMLDocumentObject
    attr_accessor :grid, :rows, :properties, :number

    def initialize(rows = [], parent: nil)
      @rows = rows
      @parent = parent
    end

    alias table_properties properties

    # Parse Table object
    # @param node [Nokogiri::XML:Element] node to parse
    # @return [Table] result of parsing
    def parse(node,
              number = 0,
              default_table_properties = TableProperties.new)
      table_properties = default_table_properties.copy
      table_properties.jc = :left
      node.xpath('*').each do |node_child|
        case node_child.name
        when 'tblGrid'
          @grid = TableGrid.parse(node_child)
        when 'tr'
          @rows << TableRow.new(parent: self).parse(node_child)
        when 'tblPr'
          @properties = TableProperties.new(parent: self).parse(node_child)
        end
      end
      @number = number
      self
    end
  end
end
