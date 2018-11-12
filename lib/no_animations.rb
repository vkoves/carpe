# credits to https://gist.github.com/keithtom/8763169
# disables CSS3 and jQuery animations in test mode for speed,
# consistency, and avoiding timing issues.

DISABLE_ANIMATIONS_HTML = <<~HTML.freeze
  <script type="text/javascript">
    (typeof jQuery !== 'undefined') && (jQuery.fx.off = true);
  </script>

  <style>
    * {
      -o-transition: none !important;
      -moz-transition: none !important;
      -ms-transition: none !important;
      -webkit-transition: none !important;
      transition: none !important;

      -webkit-animation: none !important;
      -moz-animation: none !important;
      -o-animation: none !important;
      -ms-animation: none !important;
      animation: none !important;
    }
  </style>
HTML

module Rack
  class NoAnimations
    def initialize(app, _options = {})
      @app = app
    end

    def call(env)
      @status, @headers, @body = @app.call(env)
      return [@status, @headers, @body] unless html?

      response = Rack::Response.new([], @status, @headers)

      @body.each { |fragment| response.write inject(fragment) }
      @body.close if @body.respond_to?(:close)

      response.finish
    end

    private

    def html?
      @headers["Content-Type"] =~ /html/
    end

    # add html to the end of the head tag.
    def inject(fragment)
      fragment.gsub(%r{</head>}, DISABLE_ANIMATIONS_HTML + "</head>")
    end
  end
end
