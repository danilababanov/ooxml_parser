require 'securerandom'
require 'nokogiri'
require 'xmlsimple'
require 'zip'

module OoxmlParser
  class OOXMLDocumentObject
    DEFAULT_DIRECTORY_FOR_MEDIA = '/tmp'

    class << self
      attr_accessor :namespace_prefix
      attr_accessor :root_subfolder
      attr_accessor :theme
      attr_accessor :xmls_stack
      attr_accessor :path_to_folder

      def copy_file_and_rename_to_zip(path)
        file_name = File.basename(path)
        tmp_folder = "/tmp/office_open_xml_parser_#{SecureRandom.uuid}"
        file_path = "#{tmp_folder}/#{file_name}"
        FileUtils.rm_rf(tmp_folder) if File.directory?(tmp_folder)
        FileUtils.mkdir_p(tmp_folder)
        path = "#{Dir.pwd}/#{path}" unless path[0] == '/'
        fail "Cannot find file by path #{path}" unless File.exist?(path)
        FileUtils.cp path, tmp_folder
        file_path
      end

      def unzip_file(path_to_file, destination)
        Zip.warn_invalid_date = false
        Zip::File.open(path_to_file) do |zip_file|
          fail LoadError, "There is no files in zip #{path_to_file}" if zip_file.entries.length == 0
          zip_file.each do |file|
            file_path = File.join(destination, file.name)
            FileUtils.mkdir_p(File.dirname(file_path))
            zip_file.extract(file, file_path) unless File.exist?(file_path)
          end
        end
      end

      def dir
        OOXMLDocumentObject.path_to_folder + File.dirname(OOXMLDocumentObject.xmls_stack.last) + '/'
      end

      def current_xml
        OOXMLDocumentObject.path_to_folder + OOXMLDocumentObject.xmls_stack.last
      end

      def add_to_xmls_stack(path)
        if path.include?('..')
          OOXMLDocumentObject.xmls_stack << "#{File.dirname(OOXMLDocumentObject.xmls_stack.last)}/#{path}"
        else
          OOXMLDocumentObject.xmls_stack << path
        end
      end

      def get_link_from_rels(id)
        rels_path = dir + "_rels/#{File.basename(OOXMLDocumentObject.xmls_stack.last)}.rels"
        fail LoadError, "Cannot find .rels file by path: #{rels_path}" unless File.exist?(rels_path)
        relationships = XmlSimple.xml_in(File.open(rels_path))
        relationships['Relationship'].each { |relationship| return relationship['Target'] if id == relationship['Id'] }
      end

      def media_folder
        path = "#{DEFAULT_DIRECTORY_FOR_MEDIA}/media_from_#{@file_name}"
        FileUtils.mkdir(path) unless File.exist?(path)
        path + '/'
      end

      def option_enabled?(node, attribute_name = 'val')
        return true if node.to_s == '1'
        return false if node.to_s == '0'
        return false if node.attribute(attribute_name).nil?
        status = node.attribute(attribute_name).value
        status == 'true' || status == 'on' || status == '1'
      end

      def copy_media_file(path_to_file)
        folder_to_save_media = '/tmp/media_from_' + File.basename(OOXMLDocumentObject.path_to_folder)
        path_to_copied_file = folder_to_save_media + '/' + File.basename(path_to_file)
        FileUtils.mkdir(folder_to_save_media) unless File.exist?(folder_to_save_media)
        FileUtils.copy_file(OOXMLDocumentObject.path_to_folder + path_to_file, path_to_copied_file)
        path_to_copied_file
      end
    end
  end
end