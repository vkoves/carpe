module CoreExtensions
  module String
    module Validators
      def valid_html?
        Nokogiri::XML(self).errors.empty?
      end
    end
  end
end

# This automatically includes this extension in every file. Alternatively,
# comment this line out and include the extension on a per-file basis.
String.include CoreExtensions::String::Validators
