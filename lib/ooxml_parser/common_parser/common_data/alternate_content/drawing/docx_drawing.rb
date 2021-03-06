require_relative 'drawing_properties/docx_drawing_properties'
require_relative 'drawing_properties/size_relative_horizontal'
require_relative 'drawing_properties/size_relative_vertical'
require_relative 'graphic/docx_graphic'
# Docx Drawing Data
module OoxmlParser
  class DocxDrawing < OOXMLDocumentObject
    attr_accessor :type, :properties, :graphic

    alias picture graphic

    def initialize(properties = DocxDrawingProperties.new)
      @properties = properties
    end

    def self.parse(drawing_node, parent: nil)
      drawing = DocxDrawing.new
      drawing.parent = parent
      drawing_node.xpath('*').each do |drawing_node_child|
        case drawing_node_child.name
        when 'anchor'
          drawing.type = :flow
        when 'inline'
          drawing.type = :inline
        end
        drawing.properties.distance_from_text = DocxDrawingDistanceFromText.parse(drawing_node_child)
        drawing.properties.wrap = DocxWrapDrawing.parse(drawing_node_child)
        drawing_node_child.attributes.each do |key, value|
          case key
          when 'relativeHeight'
            drawing.properties.relative_height = value.value.to_i
          end
        end
        drawing_node_child.xpath('*').each do |content_node_child|
          case content_node_child.name
          when 'simplePos'
            drawing.properties.simple_position = OOXMLCoordinates.parse(content_node_child)
          when 'extent'
            drawing.properties.object_size = OOXMLCoordinates.parse(content_node_child, x_attr: 'cx', y_attr: 'cy', unit: :emu)
          when 'graphic'
            drawing.graphic = DocxGraphic.parse(content_node_child, parent: drawing)
          when 'positionV'
            drawing.properties.vertical_position = DocxDrawingPosition.parse(content_node_child)
          when 'positionH'
            drawing.properties.horizontal_position = DocxDrawingPosition.parse(content_node_child)
          when 'sizeRelH'
            drawing.properties.size_relative_horizontal = SizeRelativeHorizontal.new(parent: drawing).parse(content_node_child)
          when 'sizeRelV'
            drawing.properties.size_relative_vertical = SizeRelativeVertical.new(parent: drawing).parse(content_node_child)
          end
        end
      end
      drawing
    end
  end
end
