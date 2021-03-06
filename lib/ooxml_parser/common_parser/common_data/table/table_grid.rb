require_relative 'table_grid/grid_column'
module OoxmlParser
  # Class for parsing `w:tblGrid` object
  class TableGrid < OOXMLDocumentObject
    # @return [Array, GridColumn] array of columns
    attr_accessor :columns

    def initialize(columns = [])
      @columns = columns
    end

    def ==(other)
      @columns.each_with_index do |cur_column, index|
        return false unless cur_column == other.columns[index]
      end
      true
    end

    # Parse TableGrid
    # @param [Nokogiri::XML:Node] node with TableGrid
    # @return [TableGrid] result of parsing
    def self.parse(node)
      grid = TableGrid.new
      node.xpath('*').each do |grid_child|
        case grid_child.name
        when 'gridCol'
          grid.columns << GridColumn.new(parent: grid).parse(grid_child)
        end
      end
      grid
    end
  end
end
