# Directory Indexes extension
class Middleman::Extensions::DirectoryIndexes < ::Middleman::Extension
  # This should run after most other sitemap manipulators so that it
  # gets a chance to modify any new resources that get added.
  self.resource_list_manipulator_priority = 100

  # Update the main sitemap resource list
  # @return Array<Middleman::Sitemap::Resource>
  Contract ResourceList => ResourceList
  def manipulate_resource_list(resources)
    resources.map(&method(:manipulate_single_resource))
  end

  def manipulate_single_resource(resource)
    index_file = app.config[:index_file]
    new_index_path = "/#{index_file}"

    # Check if it would be pointless to reroute
    return resource if resource.destination_path == index_file ||
                       resource.destination_path.end_with?(new_index_path) ||
                       File.extname(index_file) != resource.ext

    # Check if file metadata (options set by "page" in config.rb or frontmatter) turns directory_index off
    return resource if resource.options[:directory_index] == false

    resource.change_destination resource.destination_path.chomp(File.extname(index_file)) + new_index_path
  end
end
