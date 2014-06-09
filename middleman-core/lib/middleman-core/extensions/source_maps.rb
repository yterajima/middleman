class Middleman::Extensions::SourceMaps < ::Middleman::Extension
  
  attr_reader :maps

  def initialize(app, options_hash={})
    super

    @maps = {}
  end

  def after_configuration
    app.use Rack, extension: self
  end

  def record_sourcemap(source_file, source_map)
    @maps[source_file] = source_map
  end

  class Rack
    # Init
    # @param [Class] app
    # @param [Hash] options
    def initialize(app, options={})
      @app = app
      @extension = options.fetch(:extension)
    end

    # Rack interface
    # @param [Rack::Environmemt] env
    # @return [Array]
    def call(env)
      p = env['PATH_INFO']

      if map = @extension.maps[p]
        src = File.join(@extension.app.source_dir, p.sub(/\.map$/, ''))
        output = map.to_json({ css_path: src, sourcemap_path: ::Sass::Util.sourcemap_name(src) })
        headers = { 'Content-Length' => ::Rack::Utils.bytesize(output).to_s }
        [200, headers, [output]]
      elsif p =~ /\.s[ac]ss$/
        output = File.read(File.join(@extension.app.source_dir, p))
        headers = { 'Content-Length' => ::Rack::Utils.bytesize(output).to_s }
        [200, headers, [output]]
      else
        @app.call(env)
      end
    end
  end

end
